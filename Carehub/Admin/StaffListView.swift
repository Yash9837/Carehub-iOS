//
//  StaffListView.swift
//  Carehub
//
//  Created by Yash's Mackbook on 19/04/25.
//

import SwiftUI
// StaffListView.swift
struct StaffListView: View {
    @ObservedObject var staffManager: StaffManager
    @State private var searchText = ""
    @State private var showingAddStaff = false
    @State private var selectedRole: StaffRole? = nil
    
    var filteredStaff: [Staff] {
        let roleFiltered = selectedRole == nil ? staffManager.staffList : staffManager.staffList.filter { $0.role == selectedRole }
        
        if searchText.isEmpty {
            return roleFiltered
        } else {
            return roleFiltered.filter {
                $0.fullName.localizedCaseInsensitiveContains(searchText) ||
                $0.id.localizedCaseInsensitiveContains(searchText) ||
                $0.department.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(filteredStaff) { staff in
                        NavigationLink(destination: StaffDetailView(staff: staff, staffManager: staffManager)) {
                            StaffRowView(staff: staff)
                        }
                    }
                    .onDelete(perform: deleteStaff)
                } header: {
                    VStack(alignment: .leading, spacing: 10) {
                        SearchBar(text: $searchText, placeholder: "Search staff...")
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                RoleFilterButton(role: nil, selectedRole: $selectedRole)
                                
                                ForEach(StaffRole.allCases) { role in
                                    RoleFilterButton(role: role, selectedRole: $selectedRole)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.bottom, 8)
                    .background(Color(.systemGroupedBackground))
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Staff Management")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddStaff = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline)
                    }
                }
            }
            .sheet(isPresented: $showingAddStaff) {
                AddStaffView(staffManager: staffManager)
            }
        }
    }
    
    private func deleteStaff(at offsets: IndexSet) {
        offsets.forEach { index in
            let staff = filteredStaff[index]
            staffManager.deleteStaff(staff)
        }
    }
}

// StaffRowView.swift
struct StaffRowView: View {
    let staff: Staff
    
    var roleColor: Color {
        switch staff.role {
        case .doctor: return .green
        case .nurse: return .orange
        case .labTechnician: return .purple
        case .admin: return .blue
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Role icon
            ZStack {
                Circle()
                    .fill(roleColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: staff.role == .doctor ? "stethoscope" : 
                      staff.role == .nurse ? "cross.case.fill" : 
                      staff.role == .labTechnician ? "testtube.2" : "person.fill")
                    .foregroundColor(roleColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(staff.fullName)
                    .font(.headline)
                
                HStack(spacing: 6) {
                    Text(staff.role.rawValue)
                        .font(.subheadline)
                        .foregroundColor(roleColor)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(staff.department)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(staff.id)
                .font(.system(.subheadline, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// RoleFilterButton.swift
struct RoleFilterButton: View {
    let role: StaffRole?
    @Binding var selectedRole: StaffRole?
    
    var isSelected: Bool {
        role == selectedRole
    }
    
    var title: String {
        role?.rawValue ?? "All"
    }
    
    var color: Color {
        guard let role = role else { return .blue }
        switch role {
        case .doctor: return .green
        case .nurse: return .orange
        case .labTechnician: return .purple
        case .admin: return .blue
        }
    }
    
    var body: some View {
        Button {
            selectedRole = role
        } label: {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color.opacity(0.2) : Color(.systemBackground))
                .foregroundColor(isSelected ? color : .primary)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? color : Color(.systemGray4), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
