# Guadalajara App - Setup Instructions

## User Approval System Setup

### 1. Firebase Console Setup

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `guadalajara-picadas`
3. Navigate to **Firestore Database**

### 2. Create the Approved Users Collection

1. In Firestore, create a new collection called `approved_users`
2. Each document in this collection should have:
   - **Document ID**: The user's Firebase UID (automatically generated when they sign up)
   - **Fields**:
     - `status` (string): "approved", "rejected", or "pending"
     - `approvedAt` (timestamp): When the user was approved
     - `approvedBy` (string): Who approved the user (optional)

### 3. Example Document Structure

```
Collection: approved_users
Document ID: [user_firebase_uid]
{
  "status": "approved",
  "approvedAt": [timestamp],
  "approvedBy": "admin@guadalajara.com"
}
```

### 4. How to Approve Users

#### Option A: Manual Approval (Recommended)
1. When a user signs up, they'll see a "pending approval" message
2. Go to Firebase Console → Firestore → `approved_users` collection
3. Create a new document with the user's UID as the document ID
4. Set `status` to "approved"
5. The user will automatically get access when they next open the app

#### Option B: Programmatic Approval
You can also approve users programmatically by adding a document to the `approved_users` collection with the user's UID.

### 5. User States

- **Pending**: User has signed up but not yet approved
- **Approved**: User has access to the app
- **Rejected**: User's access has been denied
- **Not Found**: User exists but no approval record exists

### 6. Security Rules (Optional)

Add these Firestore security rules to ensure only admins can modify approval status:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Only allow admins to modify approved_users collection
    match /approved_users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Allow users to read their own user data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow authenticated users to read/write orders
    match /orders/{orderId} {
      allow read, write: if request.auth != null;
    }
    
    // Allow authenticated users to read menu items
    match /menu_items/{itemId} {
      allow read: if request.auth != null;
    }
  }
}
```

## App Features

### 1. User Management
- ✅ **User Registration**: Users can create accounts
- ✅ **Approval System**: Only approved users can access the app
- ✅ **Status Tracking**: Real-time approval status updates

### 2. Order Management
- ✅ **Create Orders**: Approved users can create new orders
- ✅ **View Pending Orders**: See all orders with "pending" status
- ✅ **Mark as Completed**: Change order status from "pending" to "completed"
- ✅ **Order History**: View all completed orders

### 3. Order Editing
- ✅ **Edit Client Information**: Name, phone, address
- ✅ **Edit Order Items**: Add, remove, or modify quantities
- ✅ **Real-time Updates**: Changes are immediately saved to Firebase

### 4. Navigation
- ✅ **Nueva Orden**: Create new orders
- ✅ **Órdenes**: View and manage pending orders
- ✅ **Historial**: View completed orders
- ✅ **Sign Out**: Secure logout functionality

## Troubleshooting

### User Can't Access App
1. Check if user exists in `approved_users` collection
2. Verify the document ID matches the user's Firebase UID
3. Ensure `status` field is set to "approved"

### Orders Not Showing
1. Check if orders have the correct `status` field ("pending" or "completed")
2. Verify Firebase connection and permissions
3. Check console logs for error messages

### Firebase Configuration
- Ensure `GoogleService-Info.plist` is properly configured
- Verify Firebase project settings match your app
- Check that Firestore is enabled in your Firebase project

