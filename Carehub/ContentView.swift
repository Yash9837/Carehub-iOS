import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            LinearGradient(
                colors: [
                    Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.4),
                    Color.white.opacity(0.9),
                    Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            Image(systemName: "cross.fill")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
        }
        .onAppear {
            // Automatically hide splash after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    // This will reveal either onboarding or main app view
                    // based on appState.shouldShowOnboarding
                }
            }
        }
    }
}
