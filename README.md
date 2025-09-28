# 🍖 Guadalajara App

**A comprehensive restaurant order management system built with SwiftUI and Firebase**

[![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org/)
[![Firebase](https://img.shields.io/badge/Firebase-10.0+-yellow.svg)](https://firebase.google.com/)
[![App Store](https://img.shields.io/badge/App%20Store-Available-green.svg)](https://apps.apple.com/app/guadalajara-app)

## 📱 App Store

**The Guadalajara App is now available on the App Store!**

Download it from the [App Store](https://apps.apple.com/app/guadalajara-app) to manage your restaurant orders efficiently.

## 🎯 Overview

Guadalajara App is a modern, user-friendly restaurant order management system designed specifically for food service businesses. The app streamlines the entire order process from creation to completion, providing restaurant staff with powerful tools to manage orders efficiently.

## ✨ Key Features

### 🔐 **Secure Authentication**
- **Firebase Authentication** for secure user login and registration
- **User account management** with profile information
- **Password reset functionality** for user convenience

### 📋 **Order Management**
- **Create new orders** with customer details and menu items
- **Real-time order tracking** with status updates
- **Order editing capabilities** - modify items, quantities, and customer information
- **Search functionality** to quickly find menu items
- **Order history** with complete transaction records

### 🍽️ **Menu Management**
- **Dynamic menu system** with Firebase Firestore integration
- **Product search and filtering** for quick item selection
- **Quantity management** with intuitive stepper controls
- **Price calculation** with automatic total updates

### 📊 **Business Intelligence**
- **Order status tracking** (Pending → In Progress → Completed)
- **Complete order history** for business analytics
- **Customer information management** for better service
- **Real-time data synchronization** across all devices

## 🏗️ Technical Architecture

### **Frontend**
- **SwiftUI** - Modern, declarative UI framework
- **iOS 15.0+** - Latest iOS features and capabilities
- **MVVM Architecture** - Clean separation of concerns

### **Backend**
- **Firebase Firestore** - NoSQL cloud database
- **Firebase Authentication** - Secure user management
- **Real-time listeners** - Live data synchronization

### **Key Components**

```
📁 Guadalajarapp/
├── 🔐 Authentication/
│   ├── AuthenticationViewModel.swift
│   ├── AuthenticationWrapperView.swift
│   ├── LoginView.swift
│   └── SignUpView.swift
├── 📋 Order Management/
│   ├── OrderView.swift
│   ├── OrderViewModel.swift
│   ├── OrderEditView.swift
│   ├── OrdersInProgressView.swift
│   ├── OrdersInProgressViewModel.swift
│   ├── OrderHistoryView.swift
│   └── OrderHistoryViewModel.swift
├── 🍽️ Data Models/
│   ├── Order.swift
│   └── MenuItem.swift
└── 🎨 UI Components/
    ├── ConfirmationView.swift
    └── ProfileView.swift
```

## 🚀 Getting Started

### **Prerequisites**
- Xcode 14.0 or later
- iOS 15.0 or later
- Firebase project setup
- Apple Developer Account (for App Store deployment)

### **Installation**

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/guadalajarapp.git
   cd guadalajarapp
   ```

2. **Open in Xcode**
   ```bash
   open Guadalajarapp.xcodeproj
   ```

3. **Configure Firebase**
   - Add your `GoogleService-Info.plist` to the project
   - Ensure Firebase is properly configured in your Firebase Console

4. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

### **Firebase Setup**

The app requires the following Firebase services:
- **Authentication** - User login and registration
- **Firestore Database** - Order and menu data storage

Refer to `SETUP_INSTRUCTIONS.md` for detailed Firebase configuration.

## 📱 App Screenshots

### **Authentication Flow**
- Clean login interface with app branding
- Secure registration process
- Password reset functionality

### **Order Management**
- Intuitive order creation interface
- Real-time menu item search
- Comprehensive order editing capabilities

### **Business Dashboard**
- Orders in progress tracking
- Complete order history
- Status management tools

## 🔧 Configuration

### **Environment Setup**
- Firebase project configuration
- App Store Connect setup
- Push notification configuration (if needed)

### **Customization**
- Menu items can be managed through Firebase Console
- App branding and colors can be customized in `Assets.xcassets`
- Business logic can be modified in respective ViewModels

## 📊 Data Structure

### **Order Model**
```swift
struct Order {
    var id: String?
    var date: Date
    var items: [OrderedItem]
    var totalPrice: Double
    var status: String
    var clientName: String?
    var clientPhone: String?
    var clientAddress: String?
    var orderType: String?
    var userId: String?
}
```

### **MenuItem Model**
```swift
struct MenuItem {
    var id: String
    var name: String
    var pricePerPortion: Double
    var quantity: Int
}
```

## 🔒 Privacy & Security

- **User data encryption** through Firebase security rules
- **Secure authentication** with Firebase Auth
- **Privacy compliance** with App Store guidelines
- **No third-party tracking** or data sharing

## 🛠️ Development

### **Code Style**
- SwiftUI best practices
- MVVM architecture pattern
- Clean, documented code
- Error handling and user feedback

### **Testing**
- Unit tests for business logic
- UI tests for critical user flows
- Firebase integration testing

## 📈 Future Enhancements

- [ ] Push notifications for order updates
- [ ] Advanced analytics and reporting
- [ ] Multi-location support
- [ ] Inventory management integration
- [ ] Customer loyalty program
- [ ] Payment processing integration

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Developer

**Daniel Moreno**
- GitHub: [@danimore](https://github.com/danimore)
- Email: [your-email@example.com]

## 🙏 Acknowledgments

- Firebase team for excellent backend services
- Apple for SwiftUI framework
- The open-source community for inspiration and tools

## 📞 Support

For support, email [your-email@example.com] or create an issue in this repository.

---

**Made with ❤️ for the restaurant industry**

*Last updated: December 2024*
