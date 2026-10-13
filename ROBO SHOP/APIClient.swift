
import Foundation
import UIKit

struct APIProduct: Decodable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let price: Double
    let category: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, price, category
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        if let stringID = try? values.decode(String.self, forKey: .id) {
            id = stringID
        } else {
            id = String(try values.decode(Int.self, forKey: .id))
        }

        name = try values.decode(String.self, forKey: .name)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        category = try values.decodeIfPresent(String.self, forKey: .category)

        if let number = try? values.decode(Double.self, forKey: .price) {
            price = number
        } else if let string = try? values.decode(String.self, forKey: .price),
                  let number = Double(string) {
            price = number
        } else {
            price = 0
        }
    }
}

struct APIOrder: Decodable, Identifiable {
    let id: String
    let productName: String?
    let amount: Double?
    let status: String?
    let paymentStatus: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, amount, status
        case productName = "product_name"
        case paymentStatus = "payment_status"
        case createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        if let stringID = try? values.decode(String.self, forKey: .id) {
            id = stringID
        } else {
            id = String(try values.decode(Int.self, forKey: .id))
        }

        productName = try values.decodeIfPresent(String.self, forKey: .productName)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        paymentStatus = try values.decodeIfPresent(String.self, forKey: .paymentStatus)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)

        if let number = try? values.decode(Double.self, forKey: .amount) {
            amount = number
        } else if let string = try? values.decode(String.self, forKey: .amount) {
            amount = Double(string)
        } else {
            amount = nil
        }
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case server(String)
    case missingToken
    case invalidImage

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The API URL is invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .server(let message):
            return message
        case .missingToken:
            return "Please sign in again."
        case .invalidImage:
            return "The payment screenshot could not be prepared."
        }
    }
}

private struct TokenResponse: Decodable {
    let token: String?
    let access_token: String?
    let data: NestedToken?

    struct NestedToken: Decodable {
        let token: String?
        let access_token: String?
    }
}

private struct ProductEnvelope: Decodable {
    let data: [APIProduct]?
    let products: [APIProduct]?
}

private struct OrderEnvelope: Decodable {
    let data: [APIOrder]?
    let orders: [APIOrder]?
}

final class APIClient {
    static let shared = APIClient()

    private let baseURL =
        "https://project--aa8a6a4b-7f70-4cfc-9a0c-cb14a59039e2.lovable.app/api/public/v1"

    private let session: URLSession

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        session = URLSession(configuration: configuration)
    }

    private func makeURL(_ path: String) throws -> URL {
        guard let url = URL(string: baseURL + "/" + path) else {
            throw APIError.invalidURL
        }
        return url
    }

    private func request(
        _ path: String,
        method: String = "GET",
        body: Data? = nil,
        authenticated: Bool = true
    ) async throws -> Data {
        let url = try makeURL(path)
        var request = URLRequest(url: url)

        request.httpMethod = method
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if authenticated {
            guard let token = KeychainTokenStore.shared.read(),
                  !token.isEmpty else {
                throw APIError.missingToken
            }

            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization"
            )
        }

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200..<300).contains(http.statusCode) else {
            let message = Self.readableServerMessage(from: data)
            let bodyText = String(data: data, encoding: .utf8) ?? ""

            let errorMessage: String

            if !message.isEmpty {
                errorMessage = "\(message) (HTTP \(http.statusCode))"
            } else if !bodyText.isEmpty {
                errorMessage = "Server error (\(http.statusCode)): \(bodyText)"
            } else {
                errorMessage = "Server error (\(http.statusCode))."
            }

            throw APIError.server(errorMessage)
        }

        return data
    }

    private static func readableServerMessage(from data: Data) -> String {
        guard let object = try? JSONSerialization.jsonObject(with: data)
                as? [String: Any] else {
            return ""
        }

        for key in ["message", "error", "detail", "details"] {
            if let value = object[key] as? String, !value.isEmpty {
                return value
            }

            if let values = object[key] as? [String], !values.isEmpty {
                return values.joined(separator: ", ")
            }
        }

        return ""
    }

    func login(identifier: String, password: String) async throws {
        let payload: [String: String] = [
            "identifier": identifier,
            "email": identifier,
            "username": identifier,
            "password": password
        ]

        let body = try JSONEncoder().encode(payload)

        let data = try await request(
            "auth/login",
            method: "POST",
            body: body,
            authenticated: false
        )

        let decoded = try JSONDecoder().decode(TokenResponse.self, from: data)

        let token = decoded.access_token
            ?? decoded.token
            ?? decoded.data?.access_token
            ?? decoded.data?.token

        guard let token, !token.isEmpty else {
            throw APIError.server(
                "Login response did not contain an access token."
            )
        }

        try KeychainTokenStore.shared.save(token)
    }

    func register(
        username: String,
        email: String,
        password: String
    ) async throws {
        let payload: [String: String] = [
            "username": username,
            "email": email,
            "password": password
        ]

        let body = try JSONEncoder().encode(payload)

        _ = try await request(
            "auth/register",
            method: "POST",
            body: body,
            authenticated: false
        )
    }

    func products() async throws -> [APIProduct] {
        let data = try await request("products")

        if let array = try? JSONDecoder().decode([APIProduct].self, from: data) {
            return array
        }

        if let envelope = try? JSONDecoder().decode(
            ProductEnvelope.self,
            from: data
        ) {
            if let products = envelope.products {
                return products
            }

            if let products = envelope.data {
                return products
            }
        }

        throw APIError.server("Products response format is not supported.")
    }

    func orders() async throws -> [APIOrder] {
        let data = try await request("orders")

        if let array = try? JSONDecoder().decode([APIOrder].self, from: data) {
            return array
        }

        if let envelope = try? JSONDecoder().decode(
            OrderEnvelope.self,
            from: data
        ) {
            if let orders = envelope.orders {
                return orders
            }

            if let orders = envelope.data {
                return orders
            }
        }

        throw APIError.server("Orders response format is not supported.")
    }

    func createOrder(productID: String) async throws {
        let body = try JSONSerialization.data(
            withJSONObject: ["product_id": productID]
        )

        _ = try await request(
            "orders",
            method: "POST",
            body: body
        )
    }

    func uploadPaymentProof(
        orderID: String,
        transactionReference: String,
        image: UIImage
    ) async throws {
        guard let imageData = image.jpegData(compressionQuality: 0.8),
              imageData.count <= 5 * 1024 * 1024 else {
            throw APIError.invalidImage
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        let url = try makeURL("orders/\(orderID)/payment")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60

        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        guard let token = KeychainTokenStore.shared.read(),
              !token.isEmpty else {
            throw APIError.missingToken
        }

        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )

        var body = Data()

        func append(_ value: String) {
            body.append(Data(value.utf8))
        }

        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"transaction_reference\"\r\n\r\n")
        append("\(transactionReference)\r\n")

        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"proof\"; filename=\"payment.jpg\"\r\n")
        append("Content-Type: image/jpeg\r\n\r\n")

        body.append(imageData)
        append("\r\n--\(boundary)--\r\n")

        request.httpBody = body

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200..<300).contains(http.statusCode) else {
            let message = Self.readableServerMessage(from: data)
            let bodyText = String(data: data, encoding: .utf8) ?? ""

            throw APIError.server(
                !message.isEmpty
                    ? "\(message) (HTTP \(http.statusCode))"
                    : (!bodyText.isEmpty
                        ? bodyText
                        : "Payment proof upload failed (\(http.statusCode)).")
            )
        }
    }

    func logout() {
        KeychainTokenStore.shared.delete()
    }
}
