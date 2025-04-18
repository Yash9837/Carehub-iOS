import SwiftUI

// Enum for role selection
enum Role {
    case patient
    case doctor
    case admin
}

struct LoginView: View {
    @State private var animateButtons = false
    @State private var showRegister = false
    @State private var selectedRole: Role = .patient // Default role
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var loginSuccess = false // To handle login action (for demo purposes)
    @State private var navigateToTab = false // State to trigger navigation to tab view
    @State private var tabDestination: AnyView? // Dynamic destination for role-based navigation
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
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
            
            VStack(spacing: 20) {
                // App name
                Text("CareHub")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.top, 40)
                    .shadow(radius: 2)
                
                // Existing title
                Text("Login to Your Account")
                    .font(.system(.title, design: .rounded, weight: .semibold))
                    .foregroundColor(.primary)
                
                // Role selection
                Picker("Select Role", selection: $selectedRole) {
                    Text("Patient").tag(Role.patient)
                    Text("Doctor").tag(Role.doctor)
                    Text("Admin").tag(Role.admin)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
                .accessibilityLabel("Select Role")
                
                // Text fields
                VStack(spacing: 15) {
                    TextField("Username or Email", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 20)
                        .accessibilityLabel("Username or Email")
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 20)
                        .accessibilityLabel("Password")
                    
                    // Optional role-specific field (e.g., License for Doctor)
                    if selectedRole == .doctor {
                        TextField("License Number", text: .constant(""))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 20)
                            .disabled(true) // Placeholder, enable if needed
                            .accessibilityLabel("License Number")
                    }
                }
                .padding(.top, 20)
                
                // Single Login button
                LoginButton(
                    title: "Login",
                    color: .green,
                    icon: "arrow.right.circle.fill",
                    animate: animateButtons,
                    action: {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        // Add login logic here (e.g., validate username/password)
                        loginSuccess = !username.isEmpty && !password.isEmpty // Demo condition
                        if loginSuccess {
                            // Set the appropriate tab view based on role
                            switch selectedRole {
                            case .patient:
                                tabDestination = AnyView(Patient.PatientTabView())
                            case .doctor:
                                tabDestination = AnyView(Doctor.DoctorTabView())
                            case .admin:
                                tabDestination = AnyView(Admin.AdminTabView())
                            }
                            navigateToTab = true
                        }
                    }
                )
                
                // Register text link
                HStack {
                    Text("If you don't have an account, then ")
                        .foregroundColor(.primary)
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        showRegister = true
                    }) {
                        Text("Register")
                            .foregroundColor(.blue)
                            .underline()
                            .fontWeight(.semibold)
                    }
                    .accessibilityLabel("Register Link")
                }
                .padding(.horizontal, 10)
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
                animateButtons = true
            }
        }
        .background(
            NavigationLink(
                destination: tabDestination,
                isActive: $navigateToTab
            ) {
                EmptyView()
            }
        )
        .navigationDestination(isPresented: $showRegister) {
            RegisterView()
        }
    }
}

struct LoginButton: View {
    let title: String
    let color: Color
    let icon: String
    let animate: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            action()
        }) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(color)
                    .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
            )
            .padding(.horizontal, 10)
        }
        .scaleEffect(animate ? 1 : 0.9)
        .opacity(animate ? 1 : 0)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LoginView()
        }
    }
}
