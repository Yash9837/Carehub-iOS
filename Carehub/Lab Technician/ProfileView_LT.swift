
import SwiftUI

// Lab Technician Model
struct LabTechnician1: Codable {
    let fullName: String
    let id: String
    let department: String
    let email: String
    let phoneNumber: String
    let joinDate: Date

    enum CodingKeys: String, CodingKey {
        case fullName
        case id
        case department
        case email
        case phoneNumber
        case joinDate
    }
}

// ViewModel for fetching Lab Technician data
class LabTechViewModel: ObservableObject {
    @Published var labTech: LabTechnician1?
    @Published var isLoading = false
    @Published var error: Error?

    func fetchLabTech(byId: String) {
        isLoading = true
        error = nil

        // Simulated API call (replace with actual API call or Firestore fetch)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            // Mock data based on your screenshot
            let mockLabTech = LabTechnician1(
                fullName: "Sanyog",
                id: "WFQ7R40YZICIGLXRJDYOHDXDLKD3",
                department: "Pathology",
                email: "t1@gmail.com",
                phoneNumber: "9816578234",
                joinDate: {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMMM d, yyyy 'at' h:mm:ss a 'UTC'Z"
                    formatter.timeZone = TimeZone(secondsFromGMT: 5 * 3600 + 30 * 60) // UTC+5:30
                    return formatter.date(from: "April 26, 2025 at 10:32 PM") ?? Date()
                }()
            )
            self.labTech = mockLabTech
        }
    }
}

// AuthManager1 (mocked for logout functionality)
class AuthManager1 {
    static let shared = AuthManager1()
    func logout() {
        // Implement logout logic here (e.g., clear user session)
    }
}

struct ProfileView_LT: View {
    let labTechId: String
    @StateObject private var viewModel = LabTechViewModel()
    let primaryColor = Color(red: 109/255, green: 87/255, blue: 252/255) // Same as NurseProfileView
    @State private var isEditingProfile = false
    @State private var showLoginView = false
    @State private var isLoggingOut = false

    var body: some View {
        NavigationView {
            List {
                if viewModel.isLoading {
                    ProgressView("Loading profile...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                } else if let labTech = viewModel.labTech {
                    // Profile Header
                    Section {
                        VStack(alignment: .center, spacing: 16) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(primaryColor)

                            VStack(spacing: 4) {
                                Text(labTech.fullName)
                                    .font(.title2)
                                    .fontWeight(.semibold)

                                Text(labTech.id)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.clear)
                    }
                    .listRowBackground(Color.clear)

                    // Contact Info
                    Section(header: Text("Contact Information")) {
                        LabeledContent("Phone", value: labTech.phoneNumber)
                        LabeledContent("Email", value: labTech.email)
                    }

                    // Account Details
                    Section(header: Text("Account Details")) {
                        LabeledContent("Technician ID", value: labTech.id)
                        LabeledContent("Department", value: labTech.department)
                        LabeledContent("Last Login", value: labTech.joinDate.formatted(date: .abbreviated, time: .shortened))
                    }

                    // Logout Button
                    Section {
                        Button("Logout") {
                            isLoggingOut = true
                            AuthManager1.shared.logout()
                            showLoginView = true
                        }
                        .foregroundColor(.red)
                    }
                } else if let error = viewModel.error {
                    Section {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                                .symbolRenderingMode(.hierarchical)

                            VStack(spacing: 4) {
                                Text("Error loading profile")
                                    .font(.headline)

                                Text(error.localizedDescription)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }

                            Button {
                                viewModel.fetchLabTech(byId: labTechId)
                            } label: {
                                Label("Try Again", systemImage: "arrow.clockwise")
                            }
                            .buttonStyle(.bordered)
                            .tint(primaryColor)
                        }
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .listRowSeparator(.hidden)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                if !isLoggingOut {
                    viewModel.fetchLabTech(byId: labTechId)
                }
            }
            .sheet(isPresented: $isEditingProfile) {
                Text("Edit sheet coming soon!") // Replace with actual edit view if implemented
            }
            .fullScreenCover(isPresented: $showLoginView) {
                LoginView() // Present LoginView in full-screen mode
            }
        }
        .onAppear {
            if !isLoggingOut {
                viewModel.fetchLabTech(byId: labTechId)
            }
        }
    }
}

struct ProfileView_LT_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView_LT(labTechId: "WFQ7R40YZICIGLXRJDYOHDXDLKD3")
    }
}
