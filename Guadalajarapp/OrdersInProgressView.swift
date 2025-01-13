import SwiftUI

struct OrdersInProgressView: View {
    @State private var orders: [Order] = []
    @State private var expandedOrderId: UUID? // Track which order is expanded

    var body: some View {
        VStack {
            Text("Orden en Progreso")
                .font(.largeTitle)
                .padding()

            List {
                ForEach(orders) { order in
                    // Collapsible row for each order
                    DisclosureGroup(isExpanded: Binding<Bool>(
                        get: { expandedOrderId == order.id },
                        set: { expandedOrderId = $0 ? order.id : nil }
                    )) {
                        // Show only items with quantity > 0 when expanded
                        ForEach(order.items.filter { $0.quantity > 0 }) { item in
                            HStack {
                                Text(item.name)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("Cantidad: \(item.quantity)")
                                Text("Total: $\(item.totalItemPrice, specifier: "%.2f")")
                            }
                            .padding(.leading, 20)
                        }
                    } label: {
                        // Order summary with date and total price
                        HStack {
                            Text("Fecha: \(order.date, formatter: orderDateFormatter)")
                            Spacer()
                            Text("Total: $\(order.totalPrice, specifier: "%.2f")")
                        }
                        .font(.headline)
                    }
                }
            }
            .onAppear(perform: loadOrders) // Load orders when the view appears
        }
    }

    private func loadOrders() {
        self.orders = DataManager.shared.loadOrders()
    }
}

// Date formatter for display purposes
// Updated name to avoid redeclaration conflict
let orderDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()
