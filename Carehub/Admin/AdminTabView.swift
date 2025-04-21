// AdminTabView.swift
struct AdminTabView: View {
    @State private var selectedTab = 0
    @StateObject private var staffManager = StaffManager()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard
            AdminDashboardView(staffManager: staffManager)
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)
            
            // Staff Management
            StaffListView(staffManager: staffManager)
                .tabItem {
                    Label("Staff", systemImage: "person.3.fill")
                }
                .tag(1)
            
            // Analytics
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            // Settings
            AdminSettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .accentColor(Color(red: 0.43, green: 0.34, blue: 0.99))
        .navigationBarBackButtonHidden(true)
    }
}

// AdminDashboardView.swift
struct AdminDashboardView: View {
    @ObservedObject var staffManager: StaffManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Quick Stats
                    HStack(spacing: 15) {
                        DashboardCard(
                            title: "Total Staff",
                            value: "\(staffManager.staffList.count)",
                            icon: "person.2.fill",
                            color: .blue
                        )
                        
                        DashboardCard(
                            title: "Doctors",
                            value: "\(staffManager.staffList.filter { $0.role == .doctor }.count)",
                            icon: "stethoscope",
                            color: .green
                        )
                    }
                    
                    HStack(spacing: 15) {
                        DashboardCard(
                            title: "Nurses",
                            value: "\(staffManager.staffList.filter { $0.role == .nurse }.count)",
                            icon: "cross.case.fill",
                            color: .orange
                        )
                        
                        DashboardCard(
                            title: "Lab Techs",
                            value: "\(staffManager.staffList.filter { $0.role == .labTechnician }.count)",
                            icon: "testtube.2",
                            color: .purple
                        )
                    }
                    
                    // Quick Actions
                    Text("Quick Actions")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        NavigationLink(destination: AddStaffView(staffManager: staffManager)) {
                            QuickActionButton(
                                title: "Add Staff",
                                icon: "person.badge.plus",
                                color: Color(red: 0.43, green: 0.34, blue: 0.99)
                            )
                        }
                        
                        NavigationLink(destination: StaffListView(staffManager: staffManager)) {
                            QuickActionButton(
                                title: "Manage Staff",
                                icon: "person.3.sequence.fill",
                                color: .teal
                            )
                        }
                        
                        NavigationLink(destination: AnalyticsView()) {
                            QuickActionButton(
                                title: "View Reports",
                                icon: "chart.pie.fill",
                                color: .indigo
                            )
                        }
                        
                        NavigationLink(destination: AdminSettingsView()) {
                            QuickActionButton(
                                title: "Settings",
                                icon: "gearshape.fill",
                                color: .gray
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Recent Activity
                    RecentActivityView(staffManager: staffManager)
                }
                .padding(.vertical)
            }
            .navigationTitle("Admin Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AdminProfileView()) {
                        Image(systemName: "person.crop.circle")
                            .font(.title2)
                    }
                }
            }
        }
    }
}

// DashboardCard.swift
struct DashboardCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// QuickActionButton.swift
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}