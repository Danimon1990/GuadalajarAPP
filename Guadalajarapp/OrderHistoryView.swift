import SwiftUI

struct OrderHistoryView: View {
    @StateObject private var viewModel = OrderHistoryViewModel()
    
    var body: some View {
        VStack {
            Text("Registro de Órdenes")
                .font(.largeTitle)
                .padding()
            
            if viewModel.isLoading {
                ProgressView("Cargando historial...")
            } else if let errorMessage = viewModel.errorMessage, viewModel.allOrders.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if viewModel.allOrders.isEmpty {
                Text("No hay órdenes en el historial.")
                    .padding()
            } else {
                List(viewModel.allOrders) { order in
                    VStack(alignment: .leading) {
                        Text("Fecha: \(order.date, formatter: orderHistoryDateFormatter)") // Use the renamed formatter
                            .font(.headline)
                        Text("Total: $\(order.totalPrice, specifier: "%.0f")") // Assuming COP, no decimals
                        Text("Estado: \(order.status ?? "N/A")") // Display status
                            .font(.subheadline)
                        
                        // Optionally, show items if needed, can be within a DisclosureGroup
                        DisclosureGroup("Ver Items") {
                            ForEach(order.items.filter { $0.quantity > 0 }) { item in
                                HStack {
                                    Text("• \(item.name)")
                                    Spacer()
                                    Text("Cant: \(item.quantity)")
                                    Text("$\(item.totalItemPrice, specifier: "%.0f")")
                                }
                                .font(.caption)
                                .padding(.leading, 10)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .padding()
        // .onAppear is handled by the ViewModel's init
    }
}

// Date formatter for display purposes
// Renamed to avoid conflict with the one in OrdersInProgressView
let orderHistoryDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()
