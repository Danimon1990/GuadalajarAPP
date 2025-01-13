//
//  Order.swift
//  Guadalajarapp
//
//  Created by Daniel Moreno on 10/12/24.
//
import Foundation

struct Order: Identifiable, Codable {
    var id = UUID()
    let date: Date // Stores the date of the order
    var items: [OrderedItem] // Only the items that were ordered
    var totalPrice: Double // The total price for the order
}

// Represents each ordered item in an order
struct OrderedItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let quantity: Int
    let pricePerItem: Double
    
    var totalItemPrice: Double {
        return pricePerItem * Double(quantity)
    }
}
