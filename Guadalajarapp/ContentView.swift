import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Title
                Text("Restaurante Guadalajara")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image("logo")
                    .resizable()
                    .scaledToFit()
                
                Spacer()
                
                // Button for Nueva Orden
                NavigationLink(destination: OrderView()) {
                    Text("Nueva Orden")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                // Button for Órdenes en Proceso
                NavigationLink(destination: OrdersInProgressView()) {
                    Text("Órdenes en Proceso")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                // Button for Registro de Órdenes
                NavigationLink(destination: OrderHistoryView()) {
                    Text("Registro de Órdenes")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
