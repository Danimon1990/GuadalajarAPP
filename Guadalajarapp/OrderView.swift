import SwiftUI
import FirebaseFirestore
// FirebaseCore is not directly needed here if initialized in AppDelegate
// MenuItem struct should be defined (e.g., in OrderViewModel.swift or its own file)

struct OrderView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @StateObject private var viewModel = OrderViewModel() // Use the ViewModel

    var body: some View {
        VStack {
            Text("Nueva Orden")
                .font(.largeTitle)
                .padding()
            
            // Form for order details
            Form {
                Section(header: Text("Detalles del Cliente y Orden")) {
                    Picker("Tipo de orden", selection: $viewModel.orderType) {
                        ForEach(viewModel.orderTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                    TextField("Nombre del Cliente", text: $viewModel.clientName)
                    TextField("Teléfono del Cliente", text: $viewModel.clientPhone)
                        .keyboardType(.phonePad)
                    TextField("Dirección (si es Domicilio)", text: $viewModel.clientAddress)
                    
                    HStack {
                        Text("Huesos de cerdo (precio):")
                        TextField("min $20000", text: $viewModel.huesoPriceString)
                            .keyboardType(.numberPad)
                    }
                }
                
                Section(header: Text("Productos")) {
                    if viewModel.isLoading {
                        ProgressView("Cargando menú...")
                    } else if viewModel.menuItems.isEmpty && viewModel.errorMessage == nil {
                        Text("No hay productos en el menú en este momento.")
                    } else {
                        List {
                            ForEach($viewModel.menuItems) { $item in // Use $viewModel.menuItems
                                if horizontalSizeClass == .compact {
                                    // Multi-line (vertical) layout for iPhone
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(item.name)
                                            Spacer()
                                            Stepper(value: $item.quantity, in: 0...20) { // Increased max quantity
                                                Text("\(item.quantity)")
                                            }
                                        }
                                        HStack {
                                            Text("Unit: $\(item.pricePerPortion, specifier: "%.0f")") // No decimals for COP
                                            Spacer()
                                            Text("Total: $\(item.totalPrice, specifier: "%.0f")")
                                        }
                                    }
                                    .padding(.vertical, 4)
                                } else {
                                    // Single-row layout for iPad
                                    HStack {
                                        Text(item.name)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text("$\(item.pricePerPortion, specifier: "%.0f")")
                                            .frame(width: 100, alignment: .trailing) // Wider for price
                                        Stepper(value: $item.quantity, in: 0...20) {
                                            Text("\(item.quantity)")
                                        }
                                        .frame(width: 120, alignment: .center) // Wider for stepper
                                        // The separate quantity text was redundant with the stepper
                                        Text("$\(item.totalPrice, specifier: "%.0f")")
                                            .frame(width: 100, alignment: .trailing)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            HStack {
                Text("Total: $\(viewModel.totalOrderCost, specifier: "%.0f")")
                    .font(.title2)
                    .padding()
                
                Spacer()
                
                // NavigationLink to ConfirmationView needs to be updated
                // For now, let's focus on sending the order.
                // You might pass the viewModel or relevant data to ConfirmationView.
                /*
                NavigationLink(destination: ConfirmationView(viewModel: viewModel)) {
                    Text("Siguiente")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                */
                
                Button(action: {
                    viewModel.sendOrderToFirebase()
                }) {
                    Text("Enviar a Firebase")
                        .font(.title2)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .toolbar {
            Button("Reset") {
                viewModel.resetOrderForm()
            }
        }
    }
}
