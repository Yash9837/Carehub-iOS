import SwiftUI

struct SplashView: View {
    @State private var showOnboarding = false
    @Environment(\.colorScheme) private var colorScheme // To detect light/dark mode
    
    var body: some View {
        ZStack {
            (colorScheme == .light ? Color.white : Color.black)
                .edgesIgnoringSafeArea(.all)
            LinearGradient(
                colors: colorScheme == .light ? [
                    Color.green.opacity(0.2),
                    Color.white.opacity(0.8),
                    Color.green.opacity(0.2)
                ] : [
                    Color.green.opacity(0.2),
                    Color.black.opacity(0.2),
                    Color.green.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            if let image = UIImage(named: "splash_logo") {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(UIScreen.main.bounds.width * 0.5, 300))
                    .accessibilityLabel("CareHub Logo")
            } else {
                VStack(spacing: 8) { // Stack SF Symbol and text
                    Image(systemName: "cross.fill") // Health-related cross icon
                        .font(.system(size: 50, weight: .bold)) // Larger and bold for prominence
                        .foregroundColor(colorScheme == .light ? Color.red.opacity(0.8) : Color.white.opacity(0.9))
                    
                    Text("CareHub")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .light ? Color.blue.opacity(0.8) : Color.white.opacity(0.9))
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("CareHub Title with Cross Icon")
                .onAppear {
                    print("DEBUG: splash_logo image not found in Assets.xcassets")
                }
            }
        }
        .onAppear {
            print("DEBUG: SplashView appeared")
            // Navigate to Onboarding after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showOnboarding = true
                print("DEBUG: Navigating to OnboardingView")
            }
        }
        .navigationDestination(isPresented: $showOnboarding) {
            OnboardingView()
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SplashView()
                .preferredColorScheme(.light) // Preview in light mode
            SplashView()
                .preferredColorScheme(.dark) // Preview in dark mode
        }
    }
}
