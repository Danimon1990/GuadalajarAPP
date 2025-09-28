//
//  Order.swift
//  Guadalajarapp
//
//  Created by Daniel Moreno on 10/12/24.
// 
import Foundation
import FirebaseFirestore // For @DocumentID

struct Order: Identifiable, Codable {
    @DocumentID var id: String? // Firestore document ID
    let date: Date // Stores the date of the order
    var items: [OrderedItem] // Only the items that were ordered
    var totalPrice: Double // The total price for the order
    var status: String?      // e.g., "pending", "completed"
    var clientName: String?  // Client's name
    var clientPhone: String? // Client's phone number
    var clientAddress: String? // Client's address
    var orderType: String?   // Type of order (Restaurante, Domicilio, Para llevar)
    var userId: String?      // ID of the authenticated user who placed the order

    // Default initializer if needed, especially if you create instances manually
    init(id: String? = nil, date: Date = Date(), items: [OrderedItem], totalPrice: Double, status: String? = "pending", clientName: String? = nil, clientPhone: String? = nil, clientAddress: String? = nil, orderType: String? = nil, userId: String? = nil) {
        self.id = id
        self.date = date
        self.items = items
        self.totalPrice = totalPrice
        self.status = status
        self.clientName = clientName
        self.clientPhone = clientPhone
        self.clientAddress = clientAddress
        self.orderType = orderType
        self.userId = userId
    }

    // Add CodingKeys to map Firestore field names to Swift property names
    enum CodingKeys: String, CodingKey {
        case id
        case date = "timestamp" // Map "timestamp" from Firestore to "date"
        case items
        case totalPrice // Expects "totalPrice" directly from Firestore
        case status
        case clientName
        case clientPhone
        case clientAddress
        case orderType
        case userId
    }
}

// Represents each ordered item in an order
struct OrderedItem: Identifiable, Codable {
    var id = UUID().uuidString // Keep as String for Codable, Identifiable uses it.
    let name: String
    var quantity: Int
    let pricePerItem: Double
    
    var totalItemPrice: Double {
        return pricePerItem * Double(quantity)
    }

    // Add CodingKeys to map Firestore field names to Swift property names
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case quantity = "portions"     // Map "portions" from Firestore to "quantity"
        case pricePerItem = "price"    // Map "price" from Firestore to "pricePerItem"
        // The "total" field from Firestore for each item is not directly decoded here,
        // as `totalItemPrice` is a computed property. If you needed to store it, you'd add it.
    }
}
