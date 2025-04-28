import SwiftUI

struct ProfileView_LT: View {
    @State private var showLoginView = false

    var body: some View {
        VStack {
            Text("Hello, LabTech! Welcome to your Profile.")
                .font(.title)
                .padding()

            // Logout Button
            Button(action: {
                showLoginView = true 
            }) {
                Text("Logout")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 20)
        }
        .fullScreenCover(isPresented: $showLoginView) {
            LoginView() // Present LoginView in full-screen mode
        }
    }
}

#Preview {
    ProfileView_LT()
}
