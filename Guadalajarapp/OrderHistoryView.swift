import SwiftUI

struct OrderHistoryView: View {
    @State private var orders: [Order] = []
    @State private var searchQuery: String = ""
    @State private var filterDate: Date = Date()
    @State private var isFilteringByDate = false

    var filteredOrders: [Order] {
        orders.filter { order in
            // Updated filter criteria to match available properties
            let matchesDate = !isFilteringByDate || Calendar.current.isDate(order.date, inSameDayAs: filterDate)
            let matchesItems = searchQuery.isEmpty || order.items.contains { $0.name.localizedCaseInsensitiveContains(searchQuery) }
            return matchesDate && matchesItems
        }
    }
    
    var body: some View {
        VStack {
            Text("Registro de Órdenes")
                .font(.largeTitle)
                .padding()

            TextField("Buscar por nombre del item...", text: $searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Toggle(isOn: $isFilteringByDate) {
                Text("Filtrar por fecha")
            }
            .padding()
            
            if isFilteringByDate {
                DatePicker("Seleccionar Fecha", selection: $filterDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .padding()
            }

            List(filteredOrders) { order in
                VStack(alignment: .leading) {
                    Text("Fecha: \(order.date, formatter: orderDateFormatter)")
                    Text("Total: $\(order.totalPrice, specifier: "%.2f")")
                    
                    ForEach(order.items) { item in
                        Text("Item: \(item.name), Cantidad: \(item.quantity), Precio total: $\(item.totalItemPrice, specifier: "%.2f")")
                    }
                }
                .padding()
            }
            .onAppear(perform: loadOrders)
        }
        .padding()
    }

    private func loadOrders() {
        self.orders = DataManager.shared.loadOrders()
    }
}

// Date formatter for display purposes
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()
