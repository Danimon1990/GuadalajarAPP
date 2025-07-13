import SwiftUI
import FirebaseFirestore

class OrdersInProgressViewModel: ObservableObject {
    @Published var pendingOrders: [Order] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?

    init() {
        fetchPendingOrders()
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
}
