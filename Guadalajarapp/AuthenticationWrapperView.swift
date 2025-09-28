import SwiftUI
import FirebaseAuth

struct AuthenticationWrapperView: View {
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainAppView()
                    .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
        .onAppear {
            if let user = Auth.auth().currentUser {
                authViewModel.user = user
                authViewModel.isAuthenticated = true
            }
        }
    }
}

// Main app content view that includes the sign out functionality
struct MainAppView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        TabView {
            // Orders Tab
            NavigationView {
                OrderView()
                    .navigationTitle("Nueva Orden")
            }
            .tabItem {
                Image(systemName: "plus.circle")
                Text("Nueva Orden")
            }
            
            // Orders in Progress Tab
            NavigationView {
                OrdersInProgressView()
                    .navigationTitle("Órdenes en Progreso")
            }
            .tabItem {
                Image(systemName: "clock")
                Text("Órdenes")
            }
            
            // Order History Tab
            NavigationView {
                OrderHistoryView()
                    .navigationTitle("Historial")
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Historial")
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cerrar Sesión") {
                    authViewModel.signOut()
                }
                .foregroundColor(.red)
            }
        }
    }
}
