import SwiftUI

struct AdminDashboardView: View {
    @ObservedObject var staffManager: StaffManager
    @State private var stats: [DashboardStat] = []
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    
    var body: some View {
        ZStack {
            // Background Color for entire screen
            Color(red: 0.94, green: 0.94, blue: 1.0)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Stats Overview
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(stats) { stat in
                            DashboardStatCard(stat: stat)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Quick Actions
                    QuickActionsView(staffManager: staffManager)
                    
                    // Recent Activity
                    RecentActivityView(staffManager: staffManager)
                }
                .padding(.top, 20)
            }
            .scrollIndicators(.hidden) // Hides scroll bar for a cleaner look (optional)
            .scrollContentBackground(.hidden) // <- Important: Hides internal ScrollView background
        }
        .navigationTitle("Admin Dashboard")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadStats()
        }
    }
    
    private func loadStats() {
        stats = [
            DashboardStat(title: "Total Staff", value: "\(staffManager.staffList.count)", icon: "person.3.fill", color: purpleColor),
            DashboardStat(title: "Doctors", value: "\(staffManager.doctors.count)", icon: "stethoscope", color: purpleColor),
            DashboardStat(title: "Nurses", value: "\(staffManager.nurses.count)", icon: "cross.case.fill", color: purpleColor),
            DashboardStat(title: "Lab Techs", value: "\(staffManager.labTechs.count)", icon: "testtube.2", color: purpleColor)
        ]
    }
}

struct DashboardStat: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let icon: String
    let color: Color
}

struct DashboardStatCard: View {
    let stat: DashboardStat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: stat.icon)
                        .foregroundColor(stat.color)
                        .font(.system(size: 16))
                    Text(stat.title.uppercased())
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    Spacer()
                }
                
                Text(stat.value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
            }
            .padding(12)
        }
        .frame(maxWidth: .infinity, minHeight: 80)
    }
}

struct QuickActionsView: View {
    @ObservedObject var staffManager: StaffManager
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)

    var body: some View {
        VStack(alignment: .leading) {
            Text("Quick Actions")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .padding(.top, 10)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                NavigationLink {
                    AddStaffView(staffManager: staffManager)
                } label: {
                    ActionButton2(title: "Add Staff", icon: "person.badge.plus", color: purpleColor)
                }
                
                NavigationLink {
                    StaffListView(staffManager: staffManager)
                } label: {
                    ActionButton2(title: "Manage Staff", icon: "person.3.sequence.fill", color: purpleColor)
                }
                
                NavigationLink {
                    AnalyticsView()
                } label: {
                    ActionButton2(title: "View Reports", icon: "chart.pie.fill", color: purpleColor)
                }
                
                NavigationLink {
                    AdminSettingsView()
                } label: {
                    ActionButton2(title: "Settings", icon: "gearshape.fill", color: purpleColor)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct ActionButton2: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
            }
            .padding(12)
        }
        .frame(maxWidth: .infinity, minHeight: 80)
    }
}

