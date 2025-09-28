import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AuthenticationViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var isUserApproved = true // Always true to bypass approval
    @Published var approvalStatus: ApprovalStatus = .approved // Always approved
    
    private var db = Firestore.firestore()
    
    enum ApprovalStatus {
        case pending
        case approved
        case rejected
        case notFound
    }
    
    init() {
        // Listen for authentication state changes
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.isAuthenticated = user != nil
                // Bypass approval check - all authenticated users are approved
                if user != nil {
                    self?.isUserApproved = true
                    self?.approvalStatus = .approved
                } else {
                    self?.isUserApproved = false
                    self?.approvalStatus = .pending
                }
            }
        }
    }
    
    // MARK: - Check User Approval (Bypassed)
    private func checkUserApproval(userId: String) {
        // Skip approval check - all users are automatically approved
        DispatchQueue.main.async {
            self.approvalStatus = .approved
            self.isUserApproved = true
        }
    }
    
    // MARK: - Sign Up
    func signUp(email: String, password: String, name: String, phone: String) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                    return
                }
                
                guard let user = result?.user else {
                    self?.errorMessage = "Error creating user account"
                    self?.showError = true
                    return
                }
                
                // Save additional user information to Firestore
                self?.saveUserProfile(userId: user.uid, email: email, name: name, phone: phone)
                
                // Show success message (no approval needed)
                self?.errorMessage = "Cuenta creada exitosamente. ¡Bienvenido!"
                self?.showError = true
            }
        }
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                    return
                }
                
                // Automatically approve user after successful sign in
                if result?.user != nil {
                    self?.isUserApproved = true
                    self?.approvalStatus = .approved
                }
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            isUserApproved = false
            approvalStatus = .pending
        } catch {
            errorMessage = "Error signing out: \(error.localizedDescription)"
            showError = true
        }
    }
    
    // MARK: - Reset Password
    func resetPassword(email: String) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                } else {
                    self?.errorMessage = "Se ha enviado un enlace de restablecimiento a tu correo electrónico."
                    self?.showError = true
                }
            }
        }
    }
    
    // MARK: - Save User Profile
    private func saveUserProfile(userId: String, email: String, name: String, phone: String) {
        let userData: [String: Any] = [
            "email": email,
            "name": name,
            "phone": phone,
            "createdAt": Timestamp(date: Date()),
            "platform": "iOS"
        ]
        
        db.collection("users").document(userId).setData(userData) { [weak self] error in
            if let error = error {
                print("❌ Error saving user profile: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.errorMessage = "Account created but failed to save profile information"
                    self?.showError = true
                }
            } else {
                print("✅ User profile saved successfully")
            }
        }
    }
    
    // MARK: - Get User Profile
    func getUserProfile(completion: @escaping ([String: Any]?) -> Void) {
        guard let userId = user?.uid else {
            completion(nil)
            return
        }
        
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                completion(document.data())
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: - Update User Profile
    func updateUserProfile(name: String, phone: String, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else {
            completion(false)
            return
        }
        
        let updateData: [String: Any] = [
            "name": name,
            "phone": phone,
            "updatedAt": Timestamp(date: Date())
        ]
        
        db.collection("users").document(userId).updateData(updateData) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error updating user profile: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("✅ User profile updated successfully")
                    completion(true)
                }
            }
        }
    }
}
