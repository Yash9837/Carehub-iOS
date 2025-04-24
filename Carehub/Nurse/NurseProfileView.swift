//
//  NurseProfileView.swift
//  Carehub
//
//  Created by user@87 on 21/04/25.
//

import SwiftUI

struct NurseProfileView: View {
    let nurseId: String
    @StateObject private var viewModel = NurseViewModel()
    let primaryColor = Color(red: 109/255, green: 87/255, blue: 252/255)
    @State private var isEditingProfile = false

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
                        LabeledContent("Phone", value: nurse.phoneNo)
                        LabeledContent("Email", value: nurse.email)
                    }

                    // Shift Info
                    Section(header: Text("Shift Information")) {
                        LabeledContent("Start Time", value: nurse.shift.startTime)
                        LabeledContent("End Time", value: nurse.shift.endTime)
                    }

                    // Account Info
                    Section(header: Text("Account Details")) {
                        LabeledContent("Nurse ID", value: nurse.nurseld)
                        if let createdAt = nurse.createdAt {
                            LabeledContent("Created", value: createdAt.dateValue().formatted(date: .abbreviated, time: .shortened))
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
                viewModel.fetchNurse(byNurseId: nurseId)
            }
            .sheet(isPresented: $isEditingProfile) {
                Text("Edit sheet coming soon!") // Replace with NurseEditProfile if implemented
            }
        }
        .onAppear {
            viewModel.fetchNurse(byNurseId: nurseId)
        }
    }
}

// Preview
struct NurseProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NurseProfileView(nurseId: "NUR001")
    }
}

