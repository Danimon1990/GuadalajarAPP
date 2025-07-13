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
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Buscar productos...", text: $viewModel.searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.vertical, 4)
                    
                    if viewModel.isLoading {
                        ProgressView("Cargando menú...")
                    } else if viewModel.menuItems.isEmpty && viewModel.errorMessage == nil {
                        Text("No hay productos en el menú en este momento.")
                    } else if viewModel.filteredMenuItems.isEmpty && !viewModel.searchText.isEmpty {
                        Text("No se encontraron productos que coincidan con '\(viewModel.searchText)'")
                            .foregroundColor(.secondary)
                    } else {
                        List {
                            ForEach(viewModel.filteredMenuItems.indices, id: \.self) { index in
                                let itemIndex = viewModel.menuItems.firstIndex(where: { $0.id == viewModel.filteredMenuItems[index].id }) ?? 0
                                
                                if horizontalSizeClass == .compact {
                                    // Multi-line (vertical) layout for iPhone
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(viewModel.menuItems[itemIndex].name)
                                            Spacer()
                                            Stepper(value: $viewModel.menuItems[itemIndex].quantity, in: 0...20) { // Increased max quantity
                                                Text("\(viewModel.menuItems[itemIndex].quantity)")
                                            }
                                        }
                                        HStack {
                                            Text("Unit: $\(viewModel.menuItems[itemIndex].pricePerPortion, specifier: "%.0f")") // No decimals for COP
                                            Spacer()
                                            Text("Total: $\(viewModel.menuItems[itemIndex].totalPrice, specifier: "%.0f")")
                                        }
                                    }
                                    .padding(.vertical, 4)
                                } else {
                                    // Single-row layout for iPad
                                    HStack {
                                        Text(viewModel.menuItems[itemIndex].name)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text("$\(viewModel.menuItems[itemIndex].pricePerPortion, specifier: "%.0f")")
                                            .frame(width: 100, alignment: .trailing) // Wider for price
                                        Stepper(value: $viewModel.menuItems[itemIndex].quantity, in: 0...20) {
                                            Text("\(viewModel.menuItems[itemIndex].quantity)")
                                        }
                                        .frame(width: 120, alignment: .center) // Wider for stepper
                                        // The separate quantity text was redundant with the stepper
                                        Text("$\(viewModel.menuItems[itemIndex].totalPrice, specifier: "%.0f")")
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
