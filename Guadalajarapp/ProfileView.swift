import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showingEditProfile = false
    @State private var userProfile: [String: Any]?
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView("Cargando perfil...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Profile Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.orange)
                        
                        Text(userProfile?["name"] as? String ?? "Usuario")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(userProfile?["email"] as? String ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Profile Information
                    VStack(spacing: 16) {
                        ProfileInfoRow(title: "Nombre", value: userProfile?["name"] as? String ?? "")
                        ProfileInfoRow(title: "Teléfono", value: userProfile?["phone"] as? String ?? "")
                        ProfileInfoRow(title: "Miembro desde", value: formatDate(userProfile?["createdAt"]))
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        Button("Editar Perfil") {
                            showingEditProfile = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        
                        Button("Cerrar Sesión") {
                            authViewModel.signOut()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationTitle("Mi Perfil")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(userProfile: userProfile ?? [:]) { updatedProfile in
                self.userProfile = updatedProfile
            }
        }
        .onAppear {
            loadUserProfile()
        }
    }
    
    private func loadUserProfile() {
        authViewModel.getUserProfile { profile in
            DispatchQueue.main.async {
                self.userProfile = profile
                self.isLoading = false
            }
        }
    }
    
    private func formatDate(_ timestamp: Any?) -> String {
        guard let timestamp = timestamp as? Timestamp else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: timestamp.dateValue())
    }
}

struct ProfileInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct EditProfileView: View {
    let userProfile: [String: Any]
    let onUpdate: ([String: Any]) -> Void
    
    @State private var name: String
    @State private var phone: String
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    init(userProfile: [String: Any], onUpdate: @escaping ([String: Any]) -> Void) {
        self.userProfile = userProfile
        self.onUpdate = onUpdate
        self._name = State(initialValue: userProfile["name"] as? String ?? "")
        self._phone = State(initialValue: userProfile["phone"] as? String ?? "")
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nombre Completo")
                            .font(.headline)
                        
                        TextField("Tu nombre", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Teléfono")
                            .font(.headline)
                        
                        TextField("Tu teléfono", text: $phone)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.phonePad)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Button("Guardar Cambios") {
                    saveChanges()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .disabled(isLoading || name.isEmpty || phone.isEmpty)
            }
            .padding(.top, 20)
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Error", isPresented: $authViewModel.showError) {
            Button("OK") { }
        } message: {
            Text(authViewModel.errorMessage ?? "An error occurred")
        }
    }
    
    private func saveChanges() {
        isLoading = true
        
        authViewModel.updateUserProfile(name: name, phone: phone) { success in
            isLoading = false
            if success {
                var updatedProfile = userProfile
                updatedProfile["name"] = name
                updatedProfile["phone"] = phone
                updatedProfile["updatedAt"] = Timestamp(date: Date())
                onUpdate(updatedProfile)
                dismiss()
            }
        }
    }
}
