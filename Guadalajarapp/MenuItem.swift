//
//  MenuItem.swift
//  Guadalajarapp
//
//  Created by Daniel Moreno on 10/12/24.
//
import FirebaseFirestore // Required for @DocumentID

// Define the structure of an Item
struct MenuItem: Identifiable, Codable, Hashable {
    @DocumentID var id: String? // Automatically populated by Firestore if the document has an ID
    var name: String            // Changed to var to allow modification if needed, though typically 'let' for fetched data
    var pricePerPortion: Double // This will map to "price" in Firestore
    var quantity: Int = 0
    
    // Computed property for total price of this item in the current order
    var totalPrice: Double {
        // Ensure pricePerPortion is finite before calculation
        guard pricePerPortion.isFinite else { return 0.0 }
        return Double(quantity) * pricePerPortion
    }

    // Maps Swift property names to Firestore field names
    enum CodingKeys: String, CodingKey {
        case id // Though @DocumentID handles this, it's good practice to list it
    case name = "Nombre"             // Maps 'name' in Swift to 'Nombre' in Firestore
    case pricePerPortion = "Precio" // Maps 'pricePerPortion' in Swift to 'Precio' in Firestore
        // 'quantity' is a local state for the order, not typically stored in the "menu_items" collection,
        // so it's not included here for fetching menu items. It will be encoded if you save a MenuItem instance directly.
    }
    
    // Custom initializer to allow creating items programmatically (e.g., for Friday specials or testing)
    init(id: String? = UUID().uuidString, name: String, pricePerPortion: Double, quantity: Int = 0) {
        self.id = id // Assign a UUID string if no Firestore ID is provided
        self.name = name
        self.pricePerPortion = pricePerPortion
        self.quantity = quantity
    }
}
