import SwiftUI

// MARK: - Onboarding View
struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showRegister = false
    @Environment(\.colorScheme) private var colorScheme
    @State private var cardOffset: CGSize = .zero
    @State private var rotationAngle: Double = 0.0

    let pages = [
        OnboardingPage(
            icon: "stethoscope",
            title: "Talk to a Doctor",
            description: "Connects patients with doctors who share their language and ethnicity.",
            buttonTitle: "Next"
        ),
        OnboardingPage(
            icon: "cross.fill",
            title: "Call an Ambulance",
            description: "Request for an ambulance 24/7 through MyDoctor app.",
            buttonTitle: "Next"
        ),
        OnboardingPage(
            icon: "calendar",
            title: "Schedule an Appointment",
            description: "Schedule an appointment with a certified doctor on MyDoctor app.",
            buttonTitle: "Get Started"
        )
    ]
    
    var body: some View {
        ZStack {
            // Base background (white for both modes)
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            // Gradient overlay with purple shade #6D57FC (same for light and dark)
            LinearGradient(
                colors: [
                    Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.4), // #6D57FC
                    Color.white.opacity(0.9),
                    Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            // Stack of cards with Tinder-style swipe
            ForEach(Array(pages.enumerated().reversed()), id: \.offset) { index, page in
                if index >= currentPage {
                    OnboardingCard(
                        page: page,
                        isLastPage: index == pages.count - 1,
                        currentPage: .constant(index)
                    )
                    .offset(index == currentPage ? cardOffset : .zero)
                    .rotationEffect(.degrees(index == currentPage ? Double(cardOffset.width / 20) : 0))
                    .gesture(index == currentPage ? dragGesture : nil)
                    .animation(.spring(), value: cardOffset)
                }
            }

            // Button at the bottom of the screen
            VStack {
                Spacer() // Pushes the button to the bottom
                Button(action: {
                    withAnimation {
                        if currentPage == pages.count - 1 {
                            showRegister = true
                        } else {
                            currentPage += 1
                        }
                        resetDrag()
                    }
                }) {
                    Text(pages[currentPage].buttonTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.8))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
                .accessibilityLabel("\(pages[currentPage].buttonTitle) Button")
            }
        }
        .navigationDestination(isPresented: $showRegister) {
            LoginView()
        }
        .navigationBarBackButtonHidden(true)
    }

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                cardOffset = gesture.translation
                rotationAngle = Double(cardOffset.width / 20)
            }
            .onEnded { gesture in
                let threshold: CGFloat = 100
                if abs(gesture.translation.width) > threshold {
                    withAnimation {
                        cardOffset = CGSize(width: gesture.translation.width * 5, height: gesture.translation.height * 2)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            if currentPage < pages.count - 1 {
                                currentPage += 1
                            } else {
                                showRegister = true
                            }
                            resetDrag()
                        }
                    }
                } else {
                    withAnimation {
                        resetDrag()
                    }
                }
            }
    }

    func resetDrag() {
        cardOffset = .zero
        rotationAngle = 0.0
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let buttonTitle: String
}

// MARK: - Reusable Card View
struct OnboardingCard: View {
    let page: OnboardingPage
    let isLastPage: Bool
    let currentPage: Binding<Int>
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 20) {
            Spacer() // Pushes content to the top
            
            Image(systemName: page.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.8)) // #6D57FC
                .accessibilityLabel("\(page.title) Icon")

            Text(page.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black) // Consistent black text
                .multilineTextAlignment(.center)
                .accessibilityLabel("\(page.title) Title")

            Text(page.description)
                .font(.body)
                .foregroundColor(.gray) // Consistent gray text
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .accessibilityLabel("\(page.title) Description")

            Spacer() // Pushes dots to the bottom
            
            // Pagination dots if not the last page
            if !isLastPage {
                HStack(spacing: 5) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .frame(width: index == currentPage.wrappedValue ? 10 : 6,
                                   height: index == currentPage.wrappedValue ? 10 : 6)
                            .foregroundColor(index == currentPage.wrappedValue ? .black : .gray) // Consistent colors
                    }
                }
                .padding(.top, 10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 400) // Reduced height
        .background(Color.white) // Consistent white background
        .cornerRadius(20)
        .padding(.horizontal, 30)
    }
}

// MARK: - Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                OnboardingView()
            }
            .preferredColorScheme(.light)

            NavigationStack {
                OnboardingView()
            }
            .preferredColorScheme(.dark)
        }
    }
}
