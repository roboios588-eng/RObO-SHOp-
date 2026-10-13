
import SwiftUI
import PhotosUI

struct RootView: View {
    @State private var isLoggedIn = KeychainTokenStore.shared.read() != nil
    @State private var selectedTab = 0
    @State private var identifier = ""
    @State private var password = ""
    @State private var username = ""
    @State private var email = ""
    @State private var isRegistering = false
    @State private var products: [APIProduct] = []
    @State private var orders: [APIOrder] = []
    @State private var selectedOrder: APIOrder?
    @State private var transactionReference = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var proofImage: UIImage?
    @State private var searchText = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var isBusy = false

    private var filteredProducts: [APIProduct] {
        guard !searchText.isEmpty else { return products }
        return products.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
            || ($0.description ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        Group {
            if isLoggedIn {
                shopTabs
            } else {
                loginView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoboTheme.background.ignoresSafeArea())
        .preferredColorScheme(.light)
        .alert("ROBO SHOP", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    private var loginView: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 24)

                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 88, height: 88)
                        .background(RoboTheme.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 25))

                    VStack(spacing: 6) {
                        Text("ROBO SHOP")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundStyle(RoboTheme.navy)

                        Text("Your digital store")
                            .font(.subheadline)
                            .foregroundStyle(RoboTheme.secondaryText)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text(isRegistering ? "Create account" : "Welcome back")
                            .font(.title2.bold())
                            .foregroundStyle(RoboTheme.text)

                        if isRegistering {
                            textField("Username", text: $username, icon: "person")
                            textField("Email", text: $email, icon: "envelope", isEmail: true)
                        } else {
                            textField("Username or email", text: $identifier, icon: "person")
                        }

                        HStack(spacing: 12) {
                            Image(systemName: "lock")
                                .foregroundStyle(RoboTheme.secondaryText)
                            SecureField("Password", text: $password)
                                .textContentType(isRegistering ? .newPassword : .password)
                        }
                        .padding(15)
                        .background(RoboTheme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 13))

                        Button {
                            Task { await authenticate() }
                        } label: {
                            HStack {
                                if isBusy {
                                    ProgressView().tint(.white)
                                }
                                Text(isBusy ? "Please wait…" :
                                     (isRegistering ? "Create Account" : "Sign In"))
                            }
                        }
                        .buttonStyle(RoboPrimaryButtonStyle())
                        .disabled(isBusy)

                        Button(isRegistering
                               ? "Already registered? Sign in"
                               : "New here? Create an account") {
                            isRegistering.toggle()
                        }
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                    }
                    .padding(22)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .shadow(color: RoboTheme.navy.opacity(0.06), radius: 18, y: 6)
                    .padding(.horizontal, 20)

                    Text("Secure access to your store account")
                        .font(.caption)
                        .foregroundStyle(RoboTheme.secondaryText)

                    Spacer(minLength: 24)
                }
                .frame(maxWidth: 500)
                .frame(maxWidth: .infinity)
            }
            .background(RoboTheme.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func textField(
        _ title: String,
        text: Binding<String>,
        icon: String,
        isEmail: Bool = false
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(RoboTheme.secondaryText)

            TextField(title, text: text)
                .keyboardType(isEmail ? .emailAddress : .default)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(15)
        .background(RoboTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: 13))
    }

    private var shopTabs: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                productsView
            }
            .tabItem { Label("Shop", systemImage: "bag.fill") }
            .tag(0)

            NavigationStack {
                ordersView
            }
            .tabItem { Label("Orders", systemImage: "list.clipboard.fill") }
            .tag(1)

            NavigationStack {
                accountView
            }
            .tabItem { Label("Account", systemImage: "person.crop.circle.fill") }
            .tag(2)
        }
        .toolbarBackground(.white, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .task { await refreshData() }
    }

    private var productsView: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("ROBO SHOP")
                        .font(.caption.bold())
                        .tracking(1.4)
                        .foregroundStyle(.white.opacity(0.75))
                    Text("Find your next deal")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
                Spacer()
                Image(systemName: "bag.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            .padding(20)
            .background(RoboTheme.navy)

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(RoboTheme.secondaryText)
                TextField("Search products", text: $searchText)
            }
            .padding(13)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 13))
            .padding(16)

            if filteredProducts.isEmpty {
                ContentUnavailableView(
                    products.isEmpty ? "No Products" : "No Results",
                    systemImage: "shippingbox",
                    description: Text(
                        products.isEmpty
                        ? "Pull down to try loading products again."
                        : "Try a different search."
                    )
                )
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredProducts) { product in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "cube.box.fill")
                                        .font(.title2)
                                        .foregroundStyle(RoboTheme.blue)
                                        .frame(width: 50, height: 50)
                                        .background(RoboTheme.paleBlue)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(product.name)
                                            .font(.headline)
                                            .foregroundStyle(RoboTheme.text)

                                        if let category = product.category,
                                           !category.isEmpty {
                                            Text(category.uppercased())
                                                .font(.caption2.bold())
                                                .foregroundStyle(RoboTheme.blue)
                                        }

                                        if let description = product.description,
                                           !description.isEmpty {
                                            Text(description)
                                                .font(.subheadline)
                                                .foregroundStyle(RoboTheme.secondaryText)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                    Spacer(minLength: 0)
                                }

                                Divider()

                                HStack {
                                    Text(product.price, format: .currency(code: "USD"))
                                        .font(.title3.bold())
                                        .foregroundStyle(RoboTheme.navy)

                                    Spacer()

                                    Button {
                                        Task { await createOrder(product) }
                                    } label: {
                                        Label("Order", systemImage: "arrow.right")
                                            .font(.subheadline.bold())
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .foregroundStyle(.white)
                                            .background(RoboTheme.blue)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(16)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 19))
                            .overlay {
                                RoundedRectangle(cornerRadius: 19)
                                    .stroke(RoboTheme.paleBlue, lineWidth: 1)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .refreshable { await loadProducts() }
            }
        }
        .background(RoboTheme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await loadProducts() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }

    private var ordersView: some View {
        Group {
            if orders.isEmpty {
                ContentUnavailableView(
                    "No Orders Yet",
                    systemImage: "shippingbox",
                    description: Text("Your orders will appear here.")
                )
            } else {
                List(orders) { order in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(order.productName ?? "Order \(order.id)")
                            .font(.headline)
                            .foregroundStyle(RoboTheme.text)

                        Text("Order ID: \(order.id)")
                            .font(.caption)
                            .foregroundStyle(RoboTheme.secondaryText)

                        if let amount = order.amount {
                            Text(amount, format: .currency(code: "USD"))
                                .font(.title3.bold())
                        }

                        Text("Order status: \(order.status ?? "Pending")")
                            .font(.subheadline)

                        Text("Payment status: \(order.paymentStatus ?? "Pending")")
                            .font(.subheadline)
                            .foregroundStyle(RoboTheme.secondaryText)

                        Button {
                            selectedOrder = order
                        } label: {
                            Label("Upload Payment Proof", systemImage: "photo")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(.white)
                }
                .scrollContentBackground(.hidden)
                .refreshable { await loadOrders() }
            }
        }
        .background(RoboTheme.background.ignoresSafeArea())
        .navigationTitle("My Orders")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await loadOrders() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .sheet(item: $selectedOrder) { order in
            paymentView(order: order)
        }
    }

    private func paymentView(order: APIOrder) -> some View {
        NavigationStack {
            Form {
                Section("Order") {
                    Text(order.productName ?? "Order \(order.id)")
                    Text("Order ID: \(order.id)")
                }

                Section("Payment proof") {
                    TextField("Transaction reference", text: $transactionReference)
                        .textInputAutocapitalization(.never)

                    PhotosPicker(
                        "Select payment screenshot",
                        selection: $selectedPhoto,
                        matching: .images
                    )

                    if let proofImage {
                        Image(uiImage: proofImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 220)
                    }

                    Button(isBusy ? "Uploading…" : "Submit Payment Proof") {
                        Task { await uploadProof(order) }
                    }
                    .disabled(
                        isBusy
                        || proofImage == nil
                        || transactionReference.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    )
                }
            }
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { closePayment() }
                }
            }
            .task(id: selectedPhoto) {
                guard let selectedPhoto,
                      let data = try? await selectedPhoto.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else {
                    return
                }
                proofImage = image
            }
        }
    }

    private var accountView: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 58))
                        .foregroundStyle(RoboTheme.blue)

                    Text("ROBO SHOP")
                        .font(.title2.bold())
                        .foregroundStyle(RoboTheme.navy)

                    Text("Your account")
                        .foregroundStyle(RoboTheme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(26)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 22))

                Button {
                    Task { await refreshData() }
                } label: {
                    Label("Refresh Store Data", systemImage: "arrow.clockwise")
                }
                .buttonStyle(RoboPrimaryButtonStyle())

                Button(role: .destructive) {
                    APIClient.shared.logout()
                    isLoggedIn = false
                    products = []
                    orders = []
                    password = ""
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        .frame(maxWidth: .infinity)
                        .padding(14)
                }
                .buttonStyle(.bordered)
            }
            .padding(16)
        }
        .background(RoboTheme.background.ignoresSafeArea())
        .navigationTitle("Account")
    }

    @MainActor
    private func authenticate() async {
        guard !isBusy else { return }

        let user = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isRegistering || !user.isEmpty else {
            showMessage("Enter your username or email.")
            return
        }

        guard !password.isEmpty else {
            showMessage("Enter your password.")
            return
        }

        isBusy = true
        defer { isBusy = false }

        do {
            if isRegistering {
                try await APIClient.shared.register(
                    username: username,
                    email: email,
                    password: password
                )
                isRegistering = false
                showMessage("Registration submitted. Sign in to continue.")
            } else {
                try await APIClient.shared.login(
                    identifier: user,
                    password: password
                )
                isLoggedIn = true
                await refreshData()
            }
        } catch {
            showMessage(error.localizedDescription)
        }
    }

    @MainActor
    private func refreshData() async {
        await loadProducts()
        await loadOrders()
    }

    @MainActor
    private func loadProducts() async {
        do {
            products = try await APIClient.shared.products()
        } catch {
            showMessage(error.localizedDescription)
        }
    }

    @MainActor
    private func loadOrders() async {
        do {
            orders = try await APIClient.shared.orders()
        } catch {
            showMessage(error.localizedDescription)
        }
    }

    @MainActor
    private func createOrder(_ product: APIProduct) async {
        do {
            try await APIClient.shared.createOrder(productID: product.id)
            showMessage("Order submitted. Check My Orders.")
            await loadOrders()
            selectedTab = 1
        } catch {
            showMessage(error.localizedDescription)
        }
    }

    @MainActor
    private func uploadProof(_ order: APIOrder) async {
        guard let proofImage else { return }

        isBusy = true
        defer { isBusy = false }

        do {
            try await APIClient.shared.uploadPaymentProof(
                orderID: order.id,
                transactionReference: transactionReference,
                image: proofImage
            )
            closePayment()
            showMessage("Payment proof submitted.")
            await loadOrders()
        } catch {
            showMessage(error.localizedDescription)
        }
    }

    private func closePayment() {
        selectedOrder = nil
        selectedPhoto = nil
        proofImage = nil
        transactionReference = ""
    }

    @MainActor
    private func showMessage(_ text: String) {
        alertMessage = text
        showAlert = true
    }
}
