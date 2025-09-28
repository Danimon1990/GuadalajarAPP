import SwiftUI

struct SignUpView: View {
    @StateObject private var authViewModel = AuthenticationViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var phone = ""
    @Environment(\.dismiss) private var dismiss
    
    private var isFormValid: Bool {
        !email.isEmpty && 
        !password.isEmpty && 
        !name.isEmpty && 
        !phone.isEmpty && 
        password == confirmPassword && 
        password.count >= 6
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 16) {
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .cornerRadius(10)
                        
                        Text("Crear Cuenta")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Únete a Guadalajara")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Sign Up Form
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nombre Completo")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Tu nombre completo", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.words)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Teléfono")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Tu número de teléfono", text: $phone)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.phonePad)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Correo Electrónico")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("tu@email.com", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Contraseña")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            SecureField("Mínimo 6 caracteres", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirmar Contraseña")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            SecureField("Repite tu contraseña", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Password validation
                        if !password.isEmpty && password.count < 6 {
                            Text("La contraseña debe tener al menos 6 caracteres")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        if !confirmPassword.isEmpty && password != confirmPassword {
                            Text("Las contraseñas no coinciden")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // Sign Up Button
                    Button(action: {
                        authViewModel.signUp(
                            email: email,
                            password: password,
                            name: name,
                            phone: phone
                        )
                    }) {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.2)
                        } else {
                            Text("Crear Cuenta")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.orange : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 30)
                    .disabled(!isFormValid || authViewModel.isLoading)
                    
                    // Login Link
                    HStack {
                        Text("¿Ya tienes cuenta?")
                            .foregroundColor(.secondary)
                        
                        Button("Inicia Sesión") {
                            dismiss()
                        }
                        .foregroundColor(.orange)
                        .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Registro")
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
        .onChange(of: authViewModel.isAuthenticated) { oldValue, newValue in
            if newValue {
                dismiss()
            }
        }
    }
}

