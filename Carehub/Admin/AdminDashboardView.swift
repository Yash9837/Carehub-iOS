//
//  AdminDashboardView.swift
//  Carehub
//
//  Created by Anurag on 25/04/25.
//


import SwiftUI

struct AdminDashboardView: View {
    @ObservedObject var staffManager: StaffManager
    @State private var stats: [DashboardStat] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Stats Overview
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(stats) { stat in
                        DashboardStatCard(stat: stat)
                    }
                }
                .padding()
                
                // Quick Actions
                QuickActionsView(staffManager: staffManager)
                
                // Recent Activity
                RecentActivityView(staffManager: staffManager)
            }
            .padding(.vertical)
        }
        .navigationTitle("Admin Dashboard")
        .onAppear {
            loadStats()
        }
    }
    
    private func loadStats() {
        stats = [
            DashboardStat(title: "Total Staff", value: "\(staffManager.staffList.count)", icon: "person.3.fill", color: .blue),
            DashboardStat(title: "Doctors", value: "\(staffManager.doctors.count)", icon: "stethoscope", color: .green),
            DashboardStat(title: "Nurses", value: "\(staffManager.nurses.count)", icon: "cross.case.fill", color: .orange),
            DashboardStat(title: "Lab Techs", value: "\(staffManager.labTechs.count)", icon: "testtube.2", color: .purple)
        ]
    }
}

// Supporting Views
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: stat.icon)
                    .foregroundColor(stat.color)
                Text(stat.title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Text(stat.value)
                .font(.title)
                .fontWeight(.bold)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct QuickActionsView: View {
    @ObservedObject var staffManager: StaffManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Quick Actions")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                NavigationLink {
                    AddStaffView(staffManager: staffManager)
                } label: {
                    ActionButton2(title: "Add Staff", icon: "person.badge.plus", color: .purple)
                }
                
                NavigationLink {
                    StaffListView(staffManager: staffManager)
                } label: {
                    ActionButton2(title: "Manage Staff", icon: "person.3.sequence.fill", color: .teal)
                }
                
                NavigationLink {
                    AnalyticsView()
                } label: {
                    ActionButton2(title: "View Reports", icon: "chart.pie.fill", color: .indigo)
                }
                
                NavigationLink {
                    AdminSettingsView()
                } label: {
                    ActionButton2(title: "Settings", icon: "gearshape.fill", color: .gray)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct ActionButton2: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
            Text(title)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(color.opacity(0.1))
        .foregroundColor(color)
        .cornerRadius(12)
    }
}

