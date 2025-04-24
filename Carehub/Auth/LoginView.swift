import SwiftUI

enum Role {
    case patient
    case staff
}

struct CustomTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var isSecure: Bool = false

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.textAlignment = .natural
        textField.borderStyle = .roundedRect
        textField.textColor = .black
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1.0
        textField.backgroundColor = .white
        updatePlaceholder(textField)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.textColor = .black
        uiView.layer.borderColor = UIColor.lightGray.cgColor
        uiView.layer.borderWidth = 1.0
        uiView.backgroundColor = .white
        updatePlaceholder(uiView)
    }

    private func updatePlaceholder(_ textField: UITextField) {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        let parent: CustomTextField

        init(_ parent: CustomTextField) {
            self.parent = parent
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
            textField.textColor = .black
            textField.backgroundColor = .white
        }
    }
}

struct LoginView: View {
    @State private var animateButtons = false
    @State private var showRegister = false
    @State private var selectedRole: Role = .patient
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var navigateToTab = false
    @State private var tabDestination: AnyView?
    @State private var showInvalidStaffAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)

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

                LoginFormView(
                    selectedRole: $selectedRole,
                    username: $username,
                    password: $password,
                    animateButtons: $animateButtons,
                    showRegister: $showRegister,
                    loginAction: {
                        if username.isEmpty || password.isEmpty {
                            return
                        }
                        switch selectedRole {
                        case .patient:
                            let patient = Patient(
                                fullName: username,
                                username: username, // Added username parameter
                                generatedID: "P000000",
                                age: "",
                                previousProblems: "",
                                allergies: "",
                                medications: ""
                            )
                            tabDestination = AnyView(PatientTabView(username: username, patient: patient))
                            navigateToTab = true
                        case .staff:
                            AuthManager.shared.login(username: username, password: password) { success in
                                if success {
                                    if username.uppercased().hasPrefix("D") {
                                        tabDestination = AnyView(DoctorTabView())
                                    } else if username.uppercased().hasPrefix("A") {
                                        tabDestination = AnyView(AdminTabView())
                                    }
                                    navigateToTab = true
                                } else {
                                    showInvalidStaffAlert = true
                                }
                            }
                        }
                    }
                )
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
                    animateButtons = true
                }
            }
            .navigationDestination(isPresented: $navigateToTab) {
                tabDestination
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
            .alert("Invalid Staff Username", isPresented: $showInvalidStaffAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Staff username should start with 'D' for Doctor or 'A' for Admin.")
            }
        }
    }
}

struct LoginFormView: View {
    @Binding var selectedRole: Role
    @Binding var username: String
    @Binding var password: String
    @Binding var animateButtons: Bool
    @Binding var showRegister: Bool
    let loginAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("CareHub")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundColor(.black)
                .padding(.top, 40)
                .shadow(radius: 2)

            Text("Login to Your Account")
                .font(.system(.title, design: .rounded, weight: .semibold))
                .foregroundColor(.black)

            Picker("Select Role", selection: $selectedRole) {
                Text("Patient").tag(Role.patient)
                Text("Staff").tag(Role.staff)
            }
            .pickerStyle(SegmentedPickerStyle())
            .tint(Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.8))
            .padding(.horizontal, 20)

            VStack(spacing: 15) {
                CustomTextField(text: $username, placeholder: "Username or Email")
                    .frame(height: 40)
                    .padding(.horizontal, 20)

                CustomTextField(text: $password, placeholder: "Password", isSecure: true)
                    .frame(height: 40)
                    .padding(.horizontal, 20)
            }
            .padding(.top, 20)

            LoginButton(
                title: "Login",
                color: Color(red: 0.427, green: 0.341, blue: 0.988),
                icon: "arrow.right.circle.fill",
                animate: animateButtons,
                action: loginAction
            )

            HStack {
                Text("If you don't have an account, then ")
                    .foregroundColor(.black)
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
            }
            .padding(.horizontal, 10)

            Spacer()
        }
        .padding(.horizontal, 20)
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
        LoginView()
    }
}

