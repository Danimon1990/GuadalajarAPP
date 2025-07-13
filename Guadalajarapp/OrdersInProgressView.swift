import SwiftUI

struct OrdersInProgressView: View {
    @StateObject private var viewModel = OrdersInProgressViewModel()
    @State private var expandedOrderId: String? // Track which order is expanded, using String for Firestore ID

    var body: some View {
        VStack {
            Text("Órdenes en Progreso")
                .font(.largeTitle)
                .padding()

            if viewModel.isLoading {
                ProgressView("Cargando órdenes...")
            } else if let errorMessage = viewModel.errorMessage, viewModel.pendingOrders.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if viewModel.pendingOrders.isEmpty {
                Text("No hay órdenes en progreso.")
                    .padding()
            } else {
                List {
                    ForEach(viewModel.pendingOrders) { order in
                        DisclosureGroup(
                            isExpanded: Binding<Bool>(
                                get: { expandedOrderId == order.id },
                                set: { expandedOrderId = $0 ? order.id : nil }
                            ),
                            content: {
                                ForEach(order.items.filter { $0.quantity > 0 }) { item in
                                    HStack {
                                        Text(item.name)
                                        Spacer()
                                        Text("Cant: \(item.quantity)")
                                        Text("$\(item.totalItemPrice, specifier: "%.0f")")
                                    }
                                    .padding(.leading, 20)
                                }
                                Button(action: {
                                    if let orderId = order.id {
                                        viewModel.markOrderAsCompleted(orderId: orderId)
                                    }
                                }) {
                                    Text("Marcar como Completada")
                                        .foregroundColor(.green)
                                }
                                .padding(.top, 5)
                            },
                            label: {
                                HStack {
                                    Text("Fecha: \(order.date, formatter: orderDateFormatter)")
                                    Spacer()
                                    Text("Total: $\(order.totalPrice, specifier: "%.0f")")
                                }
                                .font(.headline)
                            }
                        )
                    }
                }
            }
        }
        // .onAppear will be handled by the ViewModel's init
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
