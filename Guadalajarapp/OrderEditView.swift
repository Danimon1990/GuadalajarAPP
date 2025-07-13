import SwiftUI

struct OrderEditView: View {
    let order: Order
    let viewModel: OrdersInProgressViewModel
    
    @State private var editableItems: [OrderedItem]
    @State private var clientName: String
    @State private var clientPhone: String
    @State private var clientAddress: String
    @State private var searchText: String = ""
    @State private var showingSaveAlert = false
    @State private var showingAddItemSheet = false
    @Environment(\.dismiss) private var dismiss
    
    init(order: Order, viewModel: OrdersInProgressViewModel) {
        self.order = order
        self.viewModel = viewModel
        // Initialize editable items with current order items
        self._editableItems = State(initialValue: order.items)
        self._clientName = State(initialValue: order.clientName ?? "")
        self._clientPhone = State(initialValue: order.clientPhone ?? "")
        self._clientAddress = State(initialValue: order.clientAddress ?? "")
    }
    
    var updatedTotalPrice: Double {
        editableItems.reduce(0) { $0 + $1.totalItemPrice }
    }
    
    var filteredMenuItems: [MenuItem] {
        if searchText.isEmpty {
            return viewModel.menuItems
        } else {
            return viewModel.menuItems.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Client information editing section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Información del Cliente")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        TextField("Nombre del Cliente", text: $clientName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Teléfono del Cliente", text: $clientPhone)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.phonePad)
                        
                        TextField("Dirección (si es Domicilio)", text: $clientAddress)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
                
                // Order items section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Productos en la Orden")
                            .font(.headline)
                        Spacer()
                        Button("Agregar Producto") {
                            showingAddItemSheet = true
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    
                    if editableItems.isEmpty {
                        Text("No hay productos en esta orden")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        List {
                            ForEach($editableItems) { $item in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.name)
                                            .font(.headline)
                                        Text("$\(item.pricePerItem, specifier: "%.0f") c/u")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Stepper(value: $item.quantity, in: 0...20) {
                                            Text("\(item.quantity)")
                                                .font(.headline)
                                                .frame(minWidth: 30)
                                        }
                                        
                                        Text("$\(item.totalItemPrice, specifier: "%.0f")")
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .onDelete(perform: deleteItems)
                        }
                        .frame(maxHeight: 300)
                    }
                }
                
                // Total and save section
                VStack(spacing: 16) {
                    HStack {
                        Text("Total Original:")
                            .font(.headline)
                        Spacer()
                        Text("$\(order.totalPrice, specifier: "%.0f")")
                            .font(.headline)
                            .strikethrough()
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Total Actualizado:")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Text("$\(updatedTotalPrice, specifier: "%.0f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(updatedTotalPrice != order.totalPrice ? .green : .primary)
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(errorMessage.hasPrefix("✅") ? .green : .red)
                            .font(.caption)
                    }
                    
                    Button(action: {
                        if let orderId = order.id {
                            viewModel.updateOrder(
                                orderId: orderId,
                                updatedItems: editableItems.filter { $0.quantity > 0 },
                                newTotalPrice: updatedTotalPrice,
                                clientName: clientName,
                                clientPhone: clientPhone,
                                clientAddress: clientAddress
                            )
                            showingSaveAlert = true
                        }
                    }) {
                        Text("Guardar Cambios")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .disabled(updatedTotalPrice == order.totalPrice && 
                             clientName == (order.clientName ?? "") &&
                             clientPhone == (order.clientPhone ?? "") &&
                             clientAddress == (order.clientAddress ?? ""))
                }
                .padding()
            }
            .navigationTitle("Editar Orden")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddItemSheet) {
            AddItemView(
                menuItems: filteredMenuItems,
                searchText: $searchText,
                onAddItem: { menuItem in
                    addItemToOrder(menuItem)
                }
            )
        }
        .alert("Orden Actualizada", isPresented: $showingSaveAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Los cambios han sido guardados exitosamente.")
        }
    }
    
    private func addItemToOrder(_ menuItem: MenuItem) {
        // Check if item already exists in order
        if let existingIndex = editableItems.firstIndex(where: { $0.name == menuItem.name }) {
            // Increment quantity if item already exists
            editableItems[existingIndex].quantity += 1
        } else {
            // Add new item to order
            let newOrderedItem = OrderedItem(
                name: menuItem.name,
                quantity: 1,
                pricePerItem: menuItem.pricePerPortion
            )
            editableItems.append(newOrderedItem)
        }
        showingAddItemSheet = false
    }
    
    private func deleteItems(offsets: IndexSet) {
        editableItems.remove(atOffsets: offsets)
    }
}

// Add Item Sheet View
struct AddItemView: View {
    let menuItems: [MenuItem]
    @Binding var searchText: String
    let onAddItem: (MenuItem) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Buscar productos...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                
                if menuItems.isEmpty {
                    Text("No se encontraron productos")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List {
                        ForEach(menuItems) { menuItem in
                            Button(action: {
                                onAddItem(menuItem)
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(menuItem.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text("$\(menuItem.pricePerPortion, specifier: "%.0f")")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Agregar Producto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
} 