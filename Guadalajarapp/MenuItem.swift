//
//  MenuItem.swift
//  Guadalajarapp
//
//  Created by Daniel Moreno on 10/12/24.
//
import Foundation

// Define the structure of an Item
struct MenuItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let pricePerPortion: Double
    var quantity: Int = 0
    
    var totalPrice: Double {
        return pricePerPortion * Double(quantity)
    }
}
