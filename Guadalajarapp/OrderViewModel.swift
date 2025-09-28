import SwiftUI
import FirebaseFirestore
import FirebaseAuth // For Codable enhancements like .data(as:)

class OrderViewModel: ObservableObject {
    @Published var menuItems: [MenuItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""

    // Order specific details
    @Published var orderType: String = "Restaurante" // Default, matches web app
    let orderTypes = ["Restaurante", "Domicilio", "Para llevar"]
    @Published var clientName: String = ""
    @Published var clientPhone: String = ""
    @Published var clientAddress: String = ""
    @Published var huesoPriceString: String = "" // Use String for TextField

    private var db = Firestore.firestore()
    @Published var currentUser: User?
    
    init() {
        fetchMenuItems()
        // Get current authenticated user
        currentUser = Auth.auth().currentUser
        if let user = currentUser {
            loadUserProfile(userId: user.uid)
        }
    }

    var huesoPrice: Double {
        let parsedValue = Double(huesoPriceString) ?? 0
        // Ensure the price is a finite number. If NaN or infinity, treat as 0.
        return parsedValue.isFinite ? parsedValue : 0
    }

    var totalOrderCost: Double {
        let itemsTotal = menuItems.reduce(0) { $0 + $1.totalPrice }
        let huesoContribution = (huesoPrice >= 20000) ? huesoPrice : 0
        return itemsTotal + huesoContribution
    }
    
    var filteredMenuItems: [MenuItem] {
        if searchText.isEmpty {
            return menuItems
        } else {
            return menuItems.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    func fetchMenuItems() {
        isLoading = true
        errorMessage = nil
        db.collection("menu_items").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Error fetching menu items: \(error.localizedDescription)"
                    print("❌ Error fetching menu items: \(error.localizedDescription)")
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    self.errorMessage = "No menu items found."
                    print("No menu items found.")
                    return
                }

                var fetchedItems = documents.compactMap { queryDocumentSnapshot -> MenuItem? in
                    try? queryDocumentSnapshot.data(as: MenuItem.self)
                }

                // Handle Friday specials (client-side, similar to the web app)
                let calendar = Calendar.current
                let todayWeekday = calendar.component(.weekday, from: Date()) // Sunday = 1, ..., Saturday = 7

                if todayWeekday == 6 { // Friday
                    // Add items if they don't already exist from the DB fetch
                    // (Assumes these might not be in the main menu_items collection or are special additions)
                    if !fetchedItems.contains(where: { $0.name == "Cocido Boyacense" }) {
                        fetchedItems.append(MenuItem(name: "Cocido Boyacense", pricePerPortion: 18000))
                    }
                    if !fetchedItems.contains(where: { $0.name == "Chanfaina" }) {
                        fetchedItems.append(MenuItem(name: "Chanfaina", pricePerPortion: 13000))
                    }
                }
                // Sort items alphabetically by name for consistent display
                self.menuItems = fetchedItems.sorted(by: { $0.name < $1.name })
                print("✅ Menu items fetched successfully: \(self.menuItems.count) items")
            }
        }
    }

    func sendOrderToFirebase() {
        errorMessage = nil
        var orderItemsPayload: [[String: Any]] = []

        // Add regular menu items
        for item in menuItems where item.quantity > 0 {
            orderItemsPayload.append([
                "id": UUID().uuidString, // Add a unique ID for each ordered item
                "name": item.name,
                "portions": item.quantity, // Matching web app's "portions"
                "price": item.pricePerPortion, // Unit price
                "total": item.totalPrice
            ])
        }

        // Add "Hueso de cerdo" if price is valid
        if huesoPrice >= 20000 {
            orderItemsPayload.append([
                "id": UUID().uuidString, // Add a unique ID for the Hueso de cerdo item
                "name": "Hueso de cerdo",
                "portions": 1,
                "price": huesoPrice,
                "total": huesoPrice
            ])
        }

        guard !orderItemsPayload.isEmpty else {
            print("⚠️ Order is empty. Not sending to Firebase.")
            self.errorMessage = "La orden está vacía. Agrega productos para continuar."
            return
        }

        let orderData: [String: Any] = [
            "timestamp": Timestamp(date: Date()),
            "orderType": orderType,
            "clientName": clientName,
            "clientPhone": clientPhone,
            "clientAddress": clientAddress,
            "items": orderItemsPayload,
            "totalPrice": totalOrderCost, // Save as "totalPrice"
            "platform": "iOS", // Good to distinguish order source
            "status": "pending", // Initial status for new orders
            "userId": currentUser?.uid ?? "" // Link order to authenticated user
        ]

        db.collection("orders").addDocument(data: orderData) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error al enviar la orden: \(error.localizedDescription)")
                    self?.errorMessage = "Error al enviar la orden: \(error.localizedDescription)"
                } else {
                    print("✅ Orden enviada correctamente")
                    self?.errorMessage = "✅ Orden enviada correctamente!" // Provide feedback
                    self?.resetOrderForm()
                    // Potentially navigate away or show a success message
                }
            }
        }
    }

    func resetOrderForm() {
        // Reset quantities for all menu items
        for index in menuItems.indices {
            menuItems[index].quantity = 0
        }
        // Reset other order details
        orderType = "Restaurante"
        clientName = ""
        clientPhone = ""
        clientAddress = ""
        huesoPriceString = ""
        searchText = ""
        errorMessage = nil // Clear any previous messages
    }
    
    private func loadUserProfile(userId: String) {
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            if let document = document, document.exists {
                DispatchQueue.main.async {
                    self?.clientName = document.data()?["name"] as? String ?? ""
                    self?.clientPhone = document.data()?["phone"] as? String ?? ""
                }
            }
        }
    }
}

// Make sure you also have the MenuItem struct defined, either in this file or a separate one.
// (MenuItem struct provided in the previous step)
