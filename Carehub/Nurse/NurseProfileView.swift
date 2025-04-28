
import SwiftUI

struct NurseProfileView: View {
    let nurseId: String
    @StateObject private var viewModel = NurseViewModel()
    let primaryColor = Color(red: 109/255, green: 87/255, blue: 252/255)
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
                } else if let nurse = viewModel.nurse {
                    // Profile Header
                    Section {
                        VStack(alignment: .center, spacing: 16) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(primaryColor)

                            VStack(spacing: 4) {
                                Text(nurse.name)
                                    .font(.title2)
                                    .fontWeight(.semibold)

                                Text(nurse.nurseld)
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
                        LabeledContent("Phone", value: nurse.phoneNo ?? "N/A")
                        LabeledContent("Email", value: nurse.email)
                    }
                    Section(header: Text("Account Details")) {
                        LabeledContent("Nurse ID", value: nurse.nurseld)
                        if let createdAt = nurse.createdAt {
                            LabeledContent("Created", value: createdAt.dateValue().formatted(date: .abbreviated, time: .shortened))
                        }
                    }

                    // Logout Button
                    Section {
                        Button("Logout") {
                            isLoggingOut = true
                            AuthManager.shared.logout()
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
                                viewModel.fetchNurse(byNurseId: nurseId)
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        isEditingProfile = true
                    }
                    .foregroundStyle(primaryColor)
                }
            }
            .refreshable {
                if !isLoggingOut {
                    viewModel.fetchNurse(byNurseId: nurseId)
                }
            }
            .sheet(isPresented: $isEditingProfile) {
                Text("Edit sheet coming soon!") // Replace with NurseEditProfile if implemented
            }
            .fullScreenCover(isPresented: $showLoginView) {
                LoginView() // Present LoginView in full-screen mode
            }
        }
        .onAppear {
            if !isLoggingOut {
                viewModel.fetchNurse(byNurseId: nurseId)
            }
        }
    }
}

struct NurseProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NurseProfileView(nurseId: "NUR001")
    }
}
