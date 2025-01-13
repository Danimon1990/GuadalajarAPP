import SwiftUI

struct OrderView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var items = [
        MenuItem(name: "Rellena", pricePerPortion: 2500),
        MenuItem(name: "Longaniza", pricePerPortion: 3500),
        MenuItem(name: "papa Criolla", pricePerPortion: 5000),
        MenuItem(name: "Papa Salada", pricePerPortion: 5000),
        MenuItem(name: "Arepa", pricePerPortion: 2500),
        MenuItem(name: "Envuelto", pricePerPortion: 3000),
        MenuItem(name: "Yuca", pricePerPortion: 3500),
        MenuItem(name: "Guacamole", pricePerPortion: 3500),
        MenuItem(name: "Lomo de cerdo", pricePerPortion: 13000),
        MenuItem(name: "Sobrebarriga", pricePerPortion: 13000),
        MenuItem(name: "Costilla de cerdo", pricePerPortion: 13000),
        MenuItem(name: "Gallina", pricePerPortion: 70000),
        MenuItem(name: "Ala", pricePerPortion: 7000),
        MenuItem(name: "Sopa del dia", pricePerPortion: 5000),
        MenuItem(name: "Guacamole", pricePerPortion: 3500),
        MenuItem(name: "Chicharron", pricePerPortion: 5000)
    ]
    
    private var totalOrderCost: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }

    var body: some View {
        VStack {
            Text("Nueva Orden")
                .font(.largeTitle)
                .padding()

            List {
                ForEach($items) { $item in
                    if horizontalSizeClass == .compact {
                        // Multi-line (vertical) layout for iPhone
                        VStack(alignment: .leading, spacing: 8) {
                            // First row (Name and Stepper)
                            HStack {
                                Text(item.name)
                                Spacer()
                                Stepper(value: $item.quantity, in: 0...10) {
                                    Text("\(item.quantity)")
                                }
                            }
                            
                            // Second row (Price + total)
                            HStack {
                                Text("Unit: $\(item.pricePerPortion, specifier: "%.2f")")
                                Spacer()
                                Text("Total: $\(item.totalPrice, specifier: "%.2f")")
                            }
                        }
                        .padding(.vertical, 4)
                    } else {
                        // Original single-row layout for iPad
                        HStack {
                            Text(item.name)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("$\(item.pricePerPortion, specifier: "%.2f")")
                                .frame(width: 80, alignment: .trailing)
                            
                            Stepper(value: $item.quantity, in: 0...10) {
                                Text("\(item.quantity)")
                            }
                            .frame(width: 80, alignment: .center)
                            
                            Text("\(item.quantity)")
                                .frame(width: 80, alignment: .center)
                                .foregroundColor(.gray)
                            
                            Text("$\(item.totalPrice, specifier: "%.2f")")
                                .frame(width: 80, alignment: .trailing)
                        }
                    }
                }
            }
            
            HStack {
                Text("Total: $\(totalOrderCost, specifier: "%.2f")")
                    .font(.title2)
                    .padding()
                
                Spacer()
                
                NavigationLink(destination: ConfirmationView(items: $items)) {
                    Text("Siguiente")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .toolbar {
            Button("Reset") {
                // Reset all item quantities to zero
                for i in items.indices {
                    items[i].quantity = 0
                }
            }
        }
    }
}
