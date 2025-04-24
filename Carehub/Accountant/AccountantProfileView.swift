import SwiftUI

struct AccountantProfileView: View {
    let accountantId: String
    @StateObject private var viewModel = AccountantViewModel()
    let primaryColor = Color(red: 109/255, green: 87/255, blue: 252/255)
    @State private var isEditingProfile = false
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.isLoading {
                    ProgressView("Loading profile...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                } else if let accountant = viewModel.accountant {
                    // Profile Header Section
                    Section {
                        VStack(alignment: .center, spacing: 16) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(primaryColor)
                                .symbolRenderingMode(.hierarchical)
                            
                            VStack(spacing: 4) {
                                Text(accountant.name)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text(accountant.accountantId)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color(.systemGroupedBackground))
                    
                    // Contact Information Section
                    Section(header: Text("Contact Information")) {
                        LabeledContent("Phone", value: accountant.phoneNo)
                        LabeledContent("Email", value: accountant.email)
                    }
                    
                    // Shift Information Section
                    Section(header: Text("Shift Information")) {
                        LabeledContent("Start Time", value: accountant.shift.startTime)
                        LabeledContent("End Time", value: accountant.shift.endTime)
                    }
                    
                    // Account Details Section
                    Section(header: Text("Account Details")) {
                        LabeledContent("Employee ID", value: accountant.accountantId)
                        
                        if let createdAt = accountant.createdAt {
                            LabeledContent("Account Created", value: createdAt.dateValue().formatted(date: .abbreviated, time: .shortened))
                        } else {
                            LabeledContent("Account Created", value: "N/A")
                        }
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
                                viewModel.fetchAccountant(byAccountantId: accountantId)
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
                    if isEditingProfile {
                        Button("Done") {
//                            saveChanges()
                            isEditingProfile = false
                        }
                    } else {
                        Button("Edit") {
                            isEditingProfile = true
                        }
                        .foregroundStyle(primaryColor)
                    }
                }
            }
            .refreshable {
                viewModel.fetchAccountant(byAccountantId: accountantId)
            }
            .sheet(isPresented: $isEditingProfile) {
                AccountantEditProfile(accountant: $viewModel.accountant)
            }
        }
        .onAppear {
            viewModel.fetchAccountant(byAccountantId: accountantId)
        }
    }
}

// Preview with sample data
struct AccountantProfileView_Previews: PreviewProvider {
    static var previews: some View {
        AccountantProfileView(accountantId: "ACC001")
    }
}
