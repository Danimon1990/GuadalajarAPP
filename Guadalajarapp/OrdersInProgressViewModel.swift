import SwiftUI
import FirebaseFirestore

class OrdersInProgressViewModel: ObservableObject {
    @Published var pendingOrders: [Order] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var menuItems: [MenuItem] = []

    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?

    init() {
        fetchPendingOrders()
        fetchMenuItems()
    }

    deinit {
        listenerRegistration?.remove() // Stop listening when the ViewModel is deallocated
    }

    func fetchPendingOrders() {
        isLoading = true
        errorMessage = nil

        // Remove previous listener if any, to avoid multiple listeners
        listenerRegistration?.remove()

        listenerRegistration = db.collection("orders")
            // .whereField("status", isEqualTo: "pending") // Temporarily removed to show all orders
            .order(by: "timestamp", descending: true) // Show newest pending orders first
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = "Error fetching pending orders: \(error.localizedDescription)"
                        print("❌ Error fetching pending orders: \(error.localizedDescription)")
                        return
                    }

                    guard let documents = querySnapshot?.documents else {
                        self.errorMessage = "No pending orders found."
                        print("No pending orders found.")
                        self.pendingOrders = []
                        return
                    }

                    self.pendingOrders = documents.compactMap { document -> Order? in
                        do {
                            return try document.data(as: Order.self)
                        } catch {
                            print("❌ Failed to decode order document \(document.documentID): \(error)")
                            return nil
                        }
                    }
                    print("✅ Pending orders fetched/updated: \(self.pendingOrders.count) items")
                }
            }
    }

    func markOrderAsCompleted(orderId: String) {
        guard !orderId.isEmpty else { return }
        db.collection("orders").document(orderId).updateData(["status": "completed"]) { error in
            if let error = error {
                print("❌ Error updating order status: \(error.localizedDescription)")
                // Optionally, set an error message for the UI
                // self.errorMessage = "Error updating order: \(error.localizedDescription)"
            } else {
                print("✅ Order \(orderId) marked as completed.")
                // The snapshot listener should automatically update the pendingOrders list
            }
        }
    }
    
    func fetchMenuItems() {
        db.collection("menu_items").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error fetching menu items: \(error.localizedDescription)")
                    return
                }

                guard let documents = querySnapshot?.documents else {
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
    
    func updateOrder(orderId: String, updatedItems: [OrderedItem], newTotalPrice: Double, clientName: String, clientPhone: String, clientAddress: String) {
        guard !orderId.isEmpty else { return }
        
        // Convert OrderedItems to Firestore format
        let itemsPayload = updatedItems.map { item in
            [
                "id": item.id,
                "name": item.name,
                "portions": item.quantity,
                "price": item.pricePerItem,
                "total": item.totalItemPrice
            ]
        }
        
        let updateData: [String: Any] = [
            "items": itemsPayload,
            "totalPrice": newTotalPrice,
            "clientName": clientName,
            "clientPhone": clientPhone,
            "clientAddress": clientAddress
        ]
        
        db.collection("orders").document(orderId).updateData(updateData) { error in
            if let error = error {
                print("❌ Error updating order: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "Error updating order: \(error.localizedDescription)"
                }
            } else {
                print("✅ Order \(orderId) updated successfully.")
                DispatchQueue.main.async {
                    self.errorMessage = "✅ Order updated successfully!"
                }
            }
        }
    }
}
