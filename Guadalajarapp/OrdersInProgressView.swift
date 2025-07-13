import SwiftUI

struct OrdersInProgressView: View {
    @StateObject private var viewModel = OrdersInProgressViewModel()
    @State private var expandedOrderId: String? // Track which order is expanded, using String for Firestore ID
    @State private var editingOrderId: String? // Track which order is being edited
    @State private var showingEditSheet = false

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
                                set: { isExpanded in
                                    expandedOrderId = isExpanded ? order.id : nil
                                }
                            ),
                            content: {
                                // Client information
                                VStack(alignment: .leading, spacing: 8) {
                                    if let clientName = order.clientName, !clientName.isEmpty {
                                        HStack {
                                            Text("Cliente:")
                                                .fontWeight(.semibold)
                                            Text(clientName)
                                        }
                                    }
                                    
                                    if let clientPhone = order.clientPhone, !clientPhone.isEmpty {
                                        HStack {
                                            Text("Teléfono:")
                                                .fontWeight(.semibold)
                                            Text(clientPhone)
                                        }
                                    }
                                    
                                    if let clientAddress = order.clientAddress, !clientAddress.isEmpty {
                                        HStack {
                                            Text("Dirección:")
                                                .fontWeight(.semibold)
                                            Text(clientAddress)
                                        }
                                    }
                                }
                                .padding(.leading, 20)
                                .padding(.bottom, 8)
                                
                                // Order items
                                ForEach(order.items.filter { $0.quantity > 0 }) { item in
                                    HStack {
                                        Text(item.name)
                                        Spacer()
                                        Text("Cant: \(item.quantity)")
                                        Text("$\(item.totalItemPrice, specifier: "%.0f")")
                                    }
                                    .padding(.leading, 20)
                                }
                                
                                HStack {
                                    Button(action: {
                                        if let orderId = order.id {
                                            editingOrderId = orderId
                                            showingEditSheet = true
                                        }
                                    }) {
                                        Text("Editar Orden")
                                            .foregroundColor(.blue)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        if let orderId = order.id {
                                            viewModel.markOrderAsCompleted(orderId: orderId)
                                        }
                                    }) {
                                        Text("Marcar como Completada")
                                            .foregroundColor(.green)
                                    }
                                }
                                .padding(.top, 5)
                            },
                            label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(order.clientName ?? "Sin nombre")
                                            .font(.headline)
                                        if let orderType = order.orderType {
                                            Text(orderType)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("Total: $\(order.totalPrice, specifier: "%.0f")")
                                            .font(.headline)
                                        Text(orderDateFormatter.string(from: order.date))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        )
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            if let orderId = editingOrderId,
               let order = viewModel.pendingOrders.first(where: { $0.id == orderId }) {
                OrderEditView(order: order, viewModel: viewModel)
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
