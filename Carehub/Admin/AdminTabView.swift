import SwiftUI
import os.log

struct AdminTabView: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var staffManager = StaffManager()
    @State private var selectedTab = 0
    @State private var showLogoutAlert = false
    private let logger = Logger(subsystem: "com.yourapp.Carehub", category: "AdminTab")
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    private let gradientColors = [Color(red: 0.43, green: 0.34, blue: 0.99), Color(red: 0.55, green: 0.48, blue: 0.99)]

    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.94, blue: 1.0)
                .edgesIgnoringSafeArea(.all)
            
            if authManager.isLoading {
                ProgressView("Loading admin data...")
                    .tint(purpleColor)
                    .onAppear {
                        logger.debug("Loading admin data...")
                    }
            } else if let admin = authManager.currentStaffMember, admin.role == .admin {
                mainTabView(admin: admin)
            } else {
                accessDeniedView
            }
        }
    }
    
    @ViewBuilder
    private func mainTabView(admin: Staff) -> some View {
        TabView(selection: $selectedTab) {
            AdminDashboardView(staffManager: staffManager)
                .tabItem {
                    Image(systemName: "house.fill")
                        .environment(\.symbolVariants, selectedTab == 0 ? .fill : .none)
                    Text("Dashboard")
                }
                .tag(0)
            
            StaffListView(staffManager: staffManager)
                .tabItem {
                    Image(systemName: "person.3.fill")
                        .environment(\.symbolVariants, selectedTab == 1 ? .fill : .none)
                    Text("Staff")
                }
                .tag(1)
            
            AnalyticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                        .environment(\.symbolVariants, selectedTab == 2 ? .fill : .none)
                    Text("Analytics")
                }
                .tag(2)
            
            AdminProfileView(admin: admin)
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                        .environment(\.symbolVariants, selectedTab == 3 ? .fill : .none)
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(purpleColor)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    logger.debug("Logout button tapped")
                    showLogoutAlert = true
                }) {
                    Text("Logout")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(purpleColor)
                }
            }
        }
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Logout", role: .destructive) {
                logger.debug("User confirmed logout")
                authManager.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .onAppear {
            logger.debug("AdminTabView appeared for user")
        }
    }
    
    private var accessDeniedView: some View {
        VStack(spacing: 20) {
            Text("Access Denied")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            Text(authManager.errorMessage ?? "You don't have admin privileges")
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            Button(action: {
                logger.debug("Logging out unauthorized user")
                authManager.logout()
            }) {
                Text("Logout")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(10)
                    .shadow(color: purpleColor.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            if authManager.currentStaffMember?.role != .admin {
                logger.error("Unauthorized access attempt by user: \(authManager.currentStaffMember?.id ?? "unknown")")
            }
        }
    }
}

