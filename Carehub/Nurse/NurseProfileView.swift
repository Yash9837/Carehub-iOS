import SwiftUI

struct NurseProfileView: View {
    let nurseId: String
    @StateObject private var viewModel = NurseViewModel()
    let primaryColor = Color(red: 109/255, green: 87/255, blue: 252/255)
    @State private var isEditingProfile = false
    @State private var showLoginView = false

    var body: some View {
        NavigationView {
            List {
                if viewModel.isLoading && !showLoginView { // Only show loading if not logging out
                    ProgressView("Loading profile...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                } else if let nurse = viewModel.nurse, !showLoginView { // Only show profile if not logging out
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
                        LabeledContent(label: "Phone", content: nurse.phoneNo ?? "N/A")
                        LabeledContent(label: "Email", content: nurse.email)
                    }
                    
                    // Shift Info
                    Section(header: Text("Shift Information")) {
                        LabeledContent(
                            label: "Start Time",
                            content: formattedTime(from: nurse.shift?.startTime)
                        )
                        LabeledContent(
                            label: "End Time",
                            content: formattedTime(from: nurse.shift?.endTime)
                        )
                    }
                    
                    // Logout Button
                    Section {
                        Button("Logout") {
                            // Perform logout and immediately trigger LoginView
                            AuthManager.shared.logout()
                            // Reset viewModel to prevent error state
                            viewModel.nurse = nil
                            viewModel.error = nil
                            viewModel.isLoading = false
                            showLoginView = true
                        }
                        .foregroundColor(.red)
                    }
                }
//                } else if let error = viewModel.error, !showLoginView { // Only show error if not logging out
//                    Section {
//                        VStack(spacing: 16) {
//                            Image(systemName: "exclamationmark.triangle")
//                                .font(.system(size: 40))
//                                .foregroundColor(.orange)
//                                .symbolRenderingMode(.hierarchical)
//
//                            VStack(spacing: 4) {
//                                Text("Error loading profile")
//                                    .font(.headline)
//
//                                Text(error.localizedDescription)
//                                    .font(.subheadline)
//                                    .foregroundColor(.secondary)
//                                    .multilineTextAlignment(.center)
//                            }
//
//                            Button {
//                                viewModel.fetchNurse(byNurseId: nurseId)
//                            } label: {
//                                Label("Try Again", systemImage: "arrow.clockwise")
//                            }
//                            .buttonStyle(.bordered)
//                            .tint(primaryColor)
//                        }
//                        .padding(.vertical, 16)
//                        .frame(maxWidth: .infinity, alignment: .center)
//                    }
//                    .listRowSeparator(.hidden)
//                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .fullScreenCover(isPresented: $showLoginView) {
                LoginView()
            }
            .onAppear {
                if !showLoginView { // Only fetch if not logging out
                    viewModel.fetchNurse(byNurseId: nurseId)
                }
            }
            .onChange(of: showLoginView) { newValue in
                if newValue {
                    // Ensure viewModel is reset when logging out
                    viewModel.nurse = nil
                    viewModel.error = nil
                    viewModel.isLoading = false
                }
            }
        }
    }
}

func formattedTime(from date: Date?) -> String {
    guard let date = date else { return "N/A" }
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.dateStyle = .none
    return formatter.string(from: date)
}

#Preview {
    NurseProfileView(nurseId: "xg318OgdXaZSY4M3HSlnBsvajeY2")
}
