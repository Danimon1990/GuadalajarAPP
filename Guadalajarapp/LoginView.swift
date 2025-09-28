import SwiftUI

struct LoginView: View {
    @StateObject private var authViewModel = AuthenticationViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    @State private var showingPasswordReset = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // App Logo/Title
                VStack(spacing: 16) {
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .cornerRadius(12)
                    
                    Text("Guadalajara")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Inicia sesión para continuar")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 50)
                
                // Login Form
                VStack(spacing: 20) {
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
                        
                        SecureField("Tu contraseña", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Forgot Password Button
                    Button("¿Olvidaste tu contraseña?") {
                        showingPasswordReset = true
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal, 30)
                
                // Login Button
                Button(action: {
                    authViewModel.signIn(email: email, password: password)
                }) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                    } else {
                        Text("Iniciar Sesión")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal, 30)
                .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)
                
                // Sign Up Link
                HStack {
                    Text("¿No tienes cuenta?")
                        .foregroundColor(.secondary)
                    
                    Button("Regístrate") {
                        showingSignUp = true
                    }
                    .foregroundColor(.orange)
                    .fontWeight(.semibold)
                }
                .font(.subheadline)
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingSignUp) {
            SignUpView()
        }
        .alert("Error", isPresented: $authViewModel.showError) {
            Button("OK") { }
        } message: {
            Text(authViewModel.errorMessage ?? "An error occurred")
        }
        .alert("Restablecer Contraseña", isPresented: $showingPasswordReset) {
            TextField("Correo electrónico", text: $email)
            Button("Cancelar", role: .cancel) { }
            Button("Enviar") {
                authViewModel.resetPassword(email: email)
            }
        } message: {
            Text("Ingresa tu correo electrónico para recibir un enlace de restablecimiento")
        }
    }
}

