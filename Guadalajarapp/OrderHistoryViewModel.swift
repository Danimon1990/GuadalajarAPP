import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class OrderHistoryViewModel: ObservableObject {
    @Published var allOrders: [Order] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    init() {
        fetchAllOrders()
    }
    
    deinit {
        listenerRegistration?.remove()
    }
    
    func fetchAllOrders() {
        isLoading = true
        errorMessage = nil

        listenerRegistration?.remove()
        
        // Fetch ALL completed orders (not just user-specific ones)
        listenerRegistration = db.collection("orders")
            .whereField("status", isEqualTo: "completed")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = "Error fetching orders: \(error.localizedDescription)"
                        print("❌ Error fetching completed orders: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        self?.allOrders = []
                        return
                    }
                    
                    self?.allOrders = documents.compactMap { document in
                        do {
                            var order = try document.data(as: Order.self)
                            order.id = document.documentID
                            return order
                        } catch {
                            print("❌ Error decoding order: \(error.localizedDescription)")
                            return nil
                        }
                    }
                    
                    print("✅ Fetched \(self?.allOrders.count ?? 0) completed orders")
                }
            }
    }
}