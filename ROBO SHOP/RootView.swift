
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
        guard !searchText.isEmpty else {
            return products
        }

        return products.filter { product in
            product.name.localizedCaseInsensitiveContains(searchText)
            || (product.description ?? "")
                .localizedCaseInsensitiveContains(searchText)
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
        .background {
            RoboTheme.background
                .ignoresSafeArea()
        }
        .preferredColorScheme(.light)
        .alert("ROBO SHOP", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Login and Registration

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
                        .clipShape(
                            RoundedRectangle(cornerRadius: 25)
                        )

                    VStack(spacing: 6) {
                        Text("ROBO SHOP")
                            .font(
                                .system(
                                    size: 30,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(RoboTheme.navy)

                        Text("Your digital store")
                            .font(.subheadline)
                            .foregroundStyle(RoboTheme.secondaryText)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text(
                            isRegistering
                            ? "Create account"
                            : "Welcome back"
                        )
                        .font(.title2.bold())
                        .foregroundStyle(RoboTheme.text)

                        if isRegistering {
                            textField(
                                "Username",
                                text: $username,
                                icon: "person"
                            )

                            textField(
                                "Email",
                                text: $email,
                                icon: "envelope",
                                isEmail: true
                            )
                        } else {
                            textField(
                                "Username or email",
                                text: $identifier,
                                icon: "person"
                            )
                        }

                        HStack(spacing: 12) {
                            Image(systemName: "lock")
                                .foregroundStyle(
                                    RoboTheme.secondaryText
                                )

                            SecureField(
                                "Password",
                                text: $password
                            )
                            .textContentType(
                                isRegistering
                                ? .newPassword
                                : .password
                            )
                        }
                        .padding(15)
                        .background(RoboTheme.background)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 13)
                        )

                        Button {
                            Task {
                                await authenticate()
                            }
                        } label: {
                            HStack {
                                if isBusy {
                                    ProgressView()
                                        .tint(.white)
                                }

                                Text(
                                    isBusy
                                    ? "Please wait…"
                                    : (
                                        isRegistering
                                        ? "Create Account"
                                        : "Sign In"
                                    )
                                )
                            }
                        }
                        .buttonStyle(RoboPrimaryButtonStyle())
                        .disabled(isBusy)

                        Button {
                            isRegistering.toggle()
                        } label: {
                            Text(
                                isRegistering
                                ? "Already registered? Sign in"
                                : "New here? Create an account"
                            )
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                        }
                        .disabled(isBusy)
                    }
                    .padding(22)
                    .frame(maxWidth: 500)
                    .background(.white)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 22)
                    )
                    .shadow(
                        color: RoboTheme.navy.opacity(0.06),
                        radius: 18,
                        y: 6
                    )
                    .padding(.horizontal, 20)

                    Text("Secure access to your store account")
                        .font(.caption)
                        .foregroundStyle(RoboTheme.secondaryText)

                    Spacer(minLength: 24)
                }
                .frame(maxWidth: 500)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                RoboTheme.background
                    .ignoresSafeArea()
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                .keyboardType(
                    isEmail ? .emailAddress : .default
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(15)
        .background(RoboTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: 13))
    }

    // MARK: - Main Tabs

    private var shopTabs: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                productsView
            }
            .tabItem {
                Label("Shop", systemImage: "bag.fill")
            }
            .tag(0)

            NavigationStack {
                ordersView
            }
            .tabItem {
                Label(
                    "Orders",
                    systemImage: "list.clipboard.fill"
                )
            }
            .tag(1)

            NavigationStack {
                accountView
            }
            .tabItem {
                Label(
                    "Account",
                    systemImage: "person.crop.circle.fill"
                )
            }
            .tag(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbarBackground(.white, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .task {
            await refreshData()
        }
    }

    // MARK: - Products

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

                TextField(
                    "Search products",
                    text: $searchText
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            }
            .padding(13)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 13))
            .padding(16)

            if filteredProducts.isEmpty {
                emptyStateView(
                    title: products.isEmpty
                        ? "No Products"
                        : "No Results",
                    message: products.isEmpty
                        ? "Pull down to try loading products again."
                        : "Try a different search.",
                    systemImage: "shippingbox"
                )

                Spacer(minLength: 0)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredProducts) { product in
                            productCard(product)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .refreshable {
                    await loadProducts()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            RoboTheme.background
                .ignoresSafeArea()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing: Button {
                Task {
                    await loadProducts()
                }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .disabled(isBusy)
        )
    }

    private func productCard(
        _ product: APIProduct
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "cube.box.fill")
                    .font(.title2)
                    .foregroundStyle(RoboTheme.blue)
                    .frame(width: 50, height: 50)
                    .background(RoboTheme.paleBlue)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 14)
                    )

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
                            .foregroundStyle(
                                RoboTheme.secondaryText
                            )
                            .fixedSize(
                                horizontal: false,
                                vertical: true
                            )
                    }
                }

                Spacer(minLength: 0)
            }

            Divider()

            HStack {
                Text(
                    product.price,
                    format: .currency(code: "USD")
                )
                .font(.title3.bold())
                .foregroundStyle(RoboTheme.navy)

                Spacer()

                Button {
                    Task {
                        await createOrder(product)
                    }
                } label: {
                    Label(
                        "Order",
                        systemImage: "arrow.right"
                    )
                    .font(.subheadline.bold())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .foregroundStyle(.white)
                    .background(RoboTheme.blue)
                    .clipShape(Capsule())
                }
                .disabled(isBusy)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 19))
        .overlay {
            RoundedRectangle(cornerRadius: 19)
                .stroke(
                    RoboTheme.paleBlue,
                    lineWidth: 1
                )
        }
    }

    // MARK: - Orders

    private var ordersView: some View {
        VStack(spacing: 0) {
            if orders.isEmpty {
                emptyStateView(
                    title: "No Orders Yet",
                    message: "Your orders will appear here.",
                    systemImage: "shippingbox"
                )
            } else {
                List {
                    ForEach(orders) { order in
                        VStack(
                            alignment: .leading,
                            spacing: 10
                        ) {
                            Text(
                                order.productName
                                ?? "Order \(order.id)"
                            )
                            .font(.headline)
                            .foregroundStyle(RoboTheme.text)

                            Text("Order ID: \(order.id)")
                                .font(.caption)
                                .foregroundStyle(
                                    RoboTheme.secondaryText
                                )

                            if let amount = order.amount {
                                Text(
                                    amount,
                                    format: .currency(code: "USD")
                                )
                                .font(.title3.bold())
                            }

                            Text(
                                "Order status: "
                                + (order.status ?? "Pending")
                            )
                            .font(.subheadline)

                            Text(
                                "Payment status: "
                                + (order.paymentStatus ?? "Pending")
                            )
                            .font(.subheadline)
                            .foregroundStyle(
                                RoboTheme.secondaryText
                            )

                            Button {
                                selectedOrder = order
                            } label: {
                                Label(
                                    "Upload Payment Proof",
                                    systemImage: "photo"
                                )
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical, 8)
                        .listRowBackground(.white)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .refreshable {
                    await loadOrders()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            RoboTheme.background
                .ignoresSafeArea()
        }
        .navigationTitle("My Orders")
        .navigationBarItems(
            trailing: Button {
                Task {
                    await loadOrders()
                }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .disabled(isBusy)
        )
        .sheet(item: $selectedOrder) { order in
            paymentView(order: order)
        }
    }

    // MARK: - Payment Proof

    private func paymentView(
        order: APIOrder
    ) -> some View {
        NavigationStack {
            Form {
                Section("Order") {
                    Text(
                        order.productName
                        ?? "Order \(order.id)"
                    )

                    Text("Order ID: \(order.id)")
                }

                Section("Payment proof") {
                    TextField(
                        "Transaction reference",
                        text: $transactionReference
                    )
                    .textInputAutocapitalization(.never)

                    PhotosPicker(
                        "Select payment screenshot",
                        selection: $selectedPhoto,
                        matching: .images
                    )

                    if let proofImage = proofImage {
                        Image(uiImage: proofImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 220)
                    }

                    Button {
                        Task {
                            await uploadProof(order)
                        }
                    } label: {
                        HStack {
                            if isBusy {
                                ProgressView()
                            }

                            Text(
                                isBusy
                                ? "Uploading…"
                                : "Submit Payment Proof"
                            )
                        }
                    }
                    .disabled(
                        isBusy
                        || proofImage == nil
                        || transactionReference
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            .isEmpty
                    )
                }
            }
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Close") {
                    closePayment()
                }
            )
            .task(id: selectedPhoto) {
                guard let selectedPhoto else {
                    return
                }

                guard let data = try? await selectedPhoto
                    .loadTransferable(type: Data.self),
                    let image = UIImage(data: data) else {
                    return
                }

                await MainActor.run {
                    proofImage = image
                }
            }
        }
    }

    // MARK: - Account

    private var accountView: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(spacing: 12) {
                    Image(
                        systemName: "person.crop.circle.fill"
                    )
                    .font(.system(size: 58))
                    .foregroundStyle(RoboTheme.blue)

                    Text("ROBO SHOP")
                        .font(.title2.bold())
                        .foregroundStyle(RoboTheme.navy)

                    Text("Your account")
                        .foregroundStyle(
                            RoboTheme.secondaryText
                        )
                }
                .frame(maxWidth: .infinity)
                .padding(26)
                .background(.white)
                .clipShape(
                    RoundedRectangle(cornerRadius: 22)
                )

                Button {
                    Task {
                        await refreshData()
                    }
                } label: {
                    Label(
                        "Refresh Store Data",
                        systemImage: "arrow.clockwise"
                    )
                }
                .buttonStyle(RoboPrimaryButtonStyle())
                .disabled(isBusy)

                Button(role: .destructive) {
                    APIClient.shared.logout()

                    isLoggedIn = false
                    selectedTab = 0
                    products = []
                    orders = []
                    password = ""
                    identifier = ""
                } label: {
                    Label(
                        "Sign Out",
                        systemImage:
                            "rectangle.portrait.and.arrow.right"
                    )
                    .frame(maxWidth: .infinity)
                    .padding(14)
                }
                .buttonStyle(.bordered)
                .disabled(isBusy)
            }
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
            .padding(16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            RoboTheme.background
                .ignoresSafeArea()
        }
        .navigationTitle("Account")
    }

    // MARK: - Empty State

    private func emptyStateView(
        title: String,
        message: String,
        systemImage: String
    ) -> some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 42))
                .foregroundStyle(RoboTheme.blue)

            Text(title)
                .font(.title3.bold())
                .foregroundStyle(RoboTheme.text)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(RoboTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .padding(24)
    }

    // MARK: - Authentication

    @MainActor
    private func authenticate() async {
        guard !isBusy else {
            return
        }

        let user = identifier.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if isRegistering {
            guard !username.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty else {
                showMessage("Enter a username.")
                return
            }

            guard !email.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty else {
                showMessage("Enter your email address.")
                return
            }
        } else {
            guard !user.isEmpty else {
                showMessage("Enter your username or email.")
                return
            }
        }

        guard !password.isEmpty else {
            showMessage("Enter your password.")
            return
        }

        isBusy = true
        defer {
            isBusy = false
        }

        do {
            if isRegistering {
                try await APIClient.shared.register(
                    username: username.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ),
                    email: email.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ),
                    password: password
                )

                isRegistering = false
                password = ""

                showMessage(
                    "Registration submitted. Sign in to continue."
                )
            } else {
                try await APIClient.shared.login(
                    identifier: user,
                    password: password
                )

                isLoggedIn = true
                selectedTab = 0

                await refreshData()
            }
        } catch {
            showMessage(error.localizedDescription)
        }
    }

    // MARK: - Data Loading

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

    // MARK: - Create Order

    @MainActor
    private func createOrder(
        _ product: APIProduct
    ) async {
        guard !isBusy else {
            return
        }

        isBusy = true
        defer {
            isBusy = false
        }

        do {
            try await APIClient.shared.createOrder(
                productID: product.id
            )

            showMessage(
                "Order submitted. Check My Orders."
            )

            await loadOrders()
            selectedTab = 1
        } catch {
            showMessage(error.localizedDescription)
        }
    }

    // MARK: - Upload Payment Proof

    @MainActor
    private func uploadProof(
        _ order: APIOrder
    ) async {
        guard !isBusy else {
            return
        }

        guard let proofImage = proofImage else {
            showMessage("Select a payment screenshot first.")
            return
        }

        let reference = transactionReference.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !reference.isEmpty else {
            showMessage("Enter the transaction reference.")
            return
        }

        isBusy = true
        defer {
            isBusy = false
        }

        do {
            try await APIClient.shared.uploadPaymentProof(
                orderID: order.id,
                transactionReference: reference,
                image: proofImage
            )

            closePayment()
            showMessage("Payment proof submitted.")

            await loadOrders()
        } catch {
            showMessage(error.localizedDescription)
        }
    }

    // MARK: - Helpers

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
