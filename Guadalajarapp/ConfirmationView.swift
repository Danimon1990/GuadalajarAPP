//
//  ConfirmationView.swift
//  Guadalajarapp
//
//  Created by Daniel Moreno on 10/12/24.
//
import SwiftUI
struct ConfirmationView: View {
    @Binding var items: [MenuItem]
    @State private var orderName: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Su pedido está confirmado")
                    .font(.largeTitle)
                    .padding()

                TextField("Nombre del pedido (opcional)", text: $orderName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    // Filter items to include only those with a quantity > 0
                    let orderedItems = items.filter { $0.quantity > 0 }.map {
                        OrderedItem(name: $0.name, quantity: $0.quantity, pricePerItem: $0.pricePerPortion)
                    }
                    
                    let totalPrice = orderedItems.reduce(0) { $0 + $1.totalItemPrice }
                    
                    let newOrder = Order(
                        date: Date(),
                        items: orderedItems,
                        totalPrice: totalPrice
                    )
                    
                    DataManager.shared.saveOrder(newOrder) // Save to JSON
                    
                    // Reset items quantity to 0
                    for i in items.indices {
                        items[i].quantity = 0
                    }
                    
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Confirmar")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancelar")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("Confirmación")
    }
}
