// SearchBar.swift
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray5))
        .cornerRadius(10)
    }
}

// RecentActivityView.swift
struct RecentActivityView: View {
    @ObservedObject var staffManager: StaffManager
    
    var recentStaff: [Staff] {
        Array(staffManager.staffList.sorted(by: { $0.joinDate > $1.joinDate }).prefix(3))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent Additions")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach(recentStaff) { staff in
                    HStack(spacing: 12) {
                        StaffAvatarView(role: staff.role)
                            .frame(width: 40, height: 40)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(staff.fullName)
                                .font(.subheadline)
                                .bold()
                            
                            Text("\(staff.role.rawValue) • \(staff.department)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(staff.joinDate.formatted(date: .numeric, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}