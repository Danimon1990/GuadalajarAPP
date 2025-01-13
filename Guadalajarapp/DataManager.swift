//
//  DataManager.swift
//  Guadalajarapp
//
//  Created by Daniel Moreno on 10/12/24.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    private let ordersFile = "orders.json"
    
    private var ordersURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(ordersFile)
    }
    
    // Save an order to the JSON file
    func saveOrder(_ order: Order) {
        var orders = loadOrders() // Load existing orders
        orders.append(order) // Add the new order
        
        do {
            let data = try JSONEncoder().encode(orders)
            try data.write(to: ordersURL)
            print("Order saved successfully at \(ordersURL)")
        } catch {
            print("Failed to save order: \(error.localizedDescription)")
        }
    }
    
    // Load orders from the JSON file
    func loadOrders() -> [Order] {
        guard let data = try? Data(contentsOf: ordersURL) else {
            print("No data found at \(ordersURL)")
            return [] // Return empty array if the file doesn't exist
        }
        
        do {
            let orders = try JSONDecoder().decode([Order].self, from: data)
            return orders
        } catch {
            print("Failed to decode orders: \(error.localizedDescription)")
            return []
        }
    }
}
