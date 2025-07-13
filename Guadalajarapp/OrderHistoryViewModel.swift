import SwiftUI
import FirebaseFirestore

class OrderHistoryViewModel: ObservableObject {
    @Published var allOrders: [Order] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?

    init() {
        fetchAllOrders()
    }

    deinit {
        listenerRegistration?.remove() // Stop listening when the ViewModel is deallocated
    }

    func fetchAllOrders() {
        isLoading = true
        errorMessage = nil

        listenerRegistration?.remove()

        listenerRegistration = db.collection("orders")
            .order(by: "timestamp", descending: true) // Show newest orders first
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = "Error fetching order history: \(error.localizedDescription)"
                        print("❌ Error fetching order history: \(error.localizedDescription)")
                        return
                    }

                    guard let documents = querySnapshot?.documents else {
                        self.errorMessage = "No orders found in history."
                        print("No orders found in history.")
                        self.allOrders = []
                        return
                    }

                    self.allOrders = documents.compactMap { document -> Order? in
                        do {
                            return try document.data(as: Order.self)
                        } catch {
                            print("❌ Failed to decode order history document \(document.documentID): \(error)")
                            return nil
                        }
                    }
                    print("✅ Order history fetched/updated: \(self.allOrders.count) items")
                }
            }
    }
}