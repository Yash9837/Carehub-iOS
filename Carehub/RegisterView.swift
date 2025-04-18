import SwiftUI
import CryptoKit

struct RegisterView: View {
    @State private var name = ""
    @State private var password = ""
    @State private var selectedRole = "Patient"
    @State private var animateForm = false
    @State private var generatedID = ""
    @State private var showIDCard = false
    @State private var showPasswordAlert = false
    @State private var previousProblems = "" // Optional field for Patient
    @State private var allergies = ""       // Optional field for Patient
    @State private var medications = ""     // Optional field for Patient
    @State private var navigateToLogin = false // Added state for navigation to LoginView
    @State private var heightFt = ""        // New field for Height in feet
    @State private var heightCm = ""        // New field for Height in centimeters
    @State private var bodyWeight = ""      // New field for Body Weight
    @State private var age = ""             // New field for Age
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    let roles = ["Patient", "Admin"]

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

            ScrollView {
                VStack(spacing: 15) {
                    Text("CareHub")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundColor(colorScheme == .light ? .primary : .white)
                        .padding(.top, 40)
                        .shadow(radius: 2)

                    Text("Register")
                        .font(.system(.title, design: .rounded, weight: .semibold))
                        .foregroundColor(colorScheme == .light ? .primary : .white)
                        .padding(.bottom, 10)

                    // Picker at the top of the form
                    Picker("Role", selection: $selectedRole) {
                        ForEach(roles, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 20)
                    .accessibilityLabel("Select Role")

                    TextField("Full Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 20)
                        .accessibilityLabel("Full Name")

                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 20)
                        .accessibilityLabel("Password")

                    // Additional fields for Patient role
                    if selectedRole == "Patient" {
                        HStack {
                            TextField("Height (ft)", text: $heightFt)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal, 10)
                                .keyboardType(.decimalPad)
                                .accessibilityLabel("Height in feet")

                            TextField("Height (cm)", text: $heightCm)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal, 10)
                                .keyboardType(.decimalPad)
                                .accessibilityLabel("Height in centimeters")
                        }
                        .padding(.horizontal, 20)

                        TextField("Body Weight", text: $bodyWeight)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 20)
                            .keyboardType(.decimalPad)
                            .accessibilityLabel("Body Weight")

                        TextField("Age", text: $age)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 20)
                            .keyboardType(.numberPad)
                            .accessibilityLabel("Age")

                        TextField("Any Previous Problems (Optional)", text: $previousProblems)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 20)
                            .accessibilityLabel("Previous Problems")

                        TextField("Allergies (Optional)", text: $allergies)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 20)
                            .accessibilityLabel("Allergies")

                        TextField("Current Medications (Optional)", text: $medications)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 20)
                            .accessibilityLabel("Medications")
                    }

                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()

                        if password.trimmingCharacters(in: .whitespaces).isEmpty ||
                           name.trimmingCharacters(in: .whitespaces).isEmpty ||
                           (selectedRole == "Patient" && (heightFt.trimmingCharacters(in: .whitespaces).isEmpty ||
                                                         heightCm.trimmingCharacters(in: .whitespaces).isEmpty ||
                                                         bodyWeight.trimmingCharacters(in: .whitespaces).isEmpty ||
                                                         age.trimmingCharacters(in: .whitespaces).isEmpty)) {
                            showPasswordAlert = true
                        } else {
                            generatedID = generateUniqueID(name: name, role: selectedRole)
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showIDCard = true
                            }
                        }
                    }) {
                        Text("Sign Up")
                            .font(.system(.title3, design: .rounded, weight: .semibold))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.green)
                                    .shadow(radius: 5)
                            )
                            .padding(.horizontal)
                    }

                    // New text link for Login Page
                    HStack {
                        Text("If you have an account, go to ")
                            .foregroundColor(colorScheme == .light ? .primary : .white)
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            navigateToLogin = true // Trigger navigation to LoginView
                        }) {
                            Text("Login Page")
                                .foregroundColor(.blue)
                                .underline()
                                .fontWeight(.semibold)
                        }
                        .accessibilityLabel("Login Page Link")
                    }
                    .navigationDestination(isPresented: $navigateToLogin) {
                        LoginView()
                    }
                    .padding(.horizontal, 10)

                    if showIDCard && !generatedID.isEmpty {
                        IDCardView(id: generatedID, onCopy: {
                            withAnimation(.easeOut(duration: 0.5)) {
                                showIDCard = false
                            }
                        })
                        .transition(.opacity.combined(with: .scale))
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.blue)
                }
            }
        }
        .alert("Required Fields Missing", isPresented: $showPasswordAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please fill in all required fields (Full Name, Password, and for Patient: Height, Body Weight, and Age).")
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                animateForm = true
            }
        }
        .scaleEffect(animateForm ? 1 : 0.95)
        .opacity(animateForm ? 1 : 0)
    }

    private func generateUniqueID(name: String, role: String) -> String {
        let cleanedName = name.trimmingCharacters(in: .whitespaces).lowercased()
        let cleanedRole = role.trimmingCharacters(in: .whitespaces).lowercased()
        if cleanedName.isEmpty || cleanedRole.isEmpty {
            return ""
        }
        let input = "\(cleanedName)_\(cleanedRole)"
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        let numericHash = Int(hashString.prefix(10), radix: 16) ?? 0
        let sixDigitNumber = String(format: "%06d", numericHash % 1_000_000)
        let rolePrefix = cleanedRole.prefix(1).uppercased()
        return "\(rolePrefix)\(sixDigitNumber)"
    }
}

struct IDCardView: View {
    let id: String
    let onCopy: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Your ID: \(id)")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(colorScheme == .light ? .primary : .white)

                Button(action: {
                    UIPasteboard.general.string = id
                    onCopy()
                }) {
                    HStack {
                        Image(systemName: "doc.on.doc")
                        Text("Copy")
                    }
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue)
                            .shadow(radius: 3)
                    )
                }
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .light ? Color.white.opacity(0.9) : Color(.systemGray5))
                .shadow(radius: 5)
        )
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RegisterView()
        }
    }
}
