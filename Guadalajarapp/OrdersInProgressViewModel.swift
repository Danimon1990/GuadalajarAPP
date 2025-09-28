import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class OrdersInProgressViewModel: ObservableObject {
    @Published var pendingOrders: [Order] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var menuItems: [MenuItem] = []
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    init() {
        fetchPendingOrders()
        fetchMenuItems()
    }
    
    deinit {
        listenerRegistration?.remove()
    }
    
    func fetchPendingOrders() {
        isLoading = true
        errorMessage = nil
        
        listenerRegistration?.remove()
        
        // Fetch ALL pending orders (not just user-specific ones)
        listenerRegistration = db.collection("orders")
            .whereField("status", isEqualTo: "pending")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = "Error fetching orders: \(error.localizedDescription)"
                        print("❌ Error fetching pending orders: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        self?.pendingOrders = []
                        return
                    }
                    
                    self?.pendingOrders = documents.compactMap { document in
                        do {
                            var order = try document.data(as: Order.self)
                            order.id = document.documentID
                            return order
                        } catch {
                            print("❌ Error decoding order: \(error.localizedDescription)")
                            return nil
                        }
                    }
                    
                    print("✅ Fetched \(self?.pendingOrders.count ?? 0) pending orders")
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

                // Handle Friday specials
                let calendar = Calendar.current
                let todayWeekday = calendar.component(.weekday, from: Date())

                if todayWeekday == 6 { // Friday
                    if !fetchedItems.contains(where: { $0.name == "Cocido Boyacense" }) {
                        fetchedItems.append(MenuItem(name: "Cocido Boyacense", pricePerPortion: 18000))
                    }
                    if !fetchedItems.contains(where: { $0.name == "Chanfaina" }) {
                        fetchedItems.append(MenuItem(name: "Chanfaina", pricePerPortion: 13000))
                    }
                }
                
                self.menuItems = fetchedItems.sorted(by: { $0.name < $1.name })
                print("✅ Menu items fetched successfully: \(self.menuItems.count) items")
            }
        }
    }
    
    func markOrderAsCompleted(orderId: String) {
        guard !orderId.isEmpty else { return }
        
        let updateData: [String: Any] = [
            "status": "completed",
            "completedAt": Timestamp(date: Date())
        ]
        
        db.collection("orders").document(orderId).updateData(updateData) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Error marking order as completed: \(error.localizedDescription)"
                    print("❌ Error marking order as completed: \(error.localizedDescription)")
                } else {
                    self?.errorMessage = "✅ Orden marcada como completada"
                    print("✅ Order marked as completed successfully")
                    
                    // Remove the order from pending orders after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self?.errorMessage = nil
                    }
                }
            }
        }
    }
    
    func updateOrder(orderId: String, updatedItems: [OrderedItem], newTotalPrice: Double, clientName: String, clientPhone: String, clientAddress: String) {
        guard !orderId.isEmpty else { return }
        
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
            "clientAddress": clientAddress,
            "updatedAt": Timestamp(date: Date())
        ]
        
        db.collection("orders").document(orderId).updateData(updateData) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Error updating order: \(error.localizedDescription)"
                    print("❌ Error updating order: \(error.localizedDescription)")
                } else {
                    self?.errorMessage = "✅ Orden actualizada correctamente"
                    print("✅ Order updated successfully")
                    
                    // Clear success message after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self?.errorMessage = nil
                    }
                }
            }
        }
    }
}
