//
//  AccountantDashboardView.swift
//  Carehub
//
//  Created by user@87 on 22/04/25.
//

import SwiftUI

struct AccountantDashboard: View {
    @State private var selectedTab = 0
    @StateObject private var viewModel = AccountantViewModel()
    let primaryColor = Color(hex: "6d57fc")
    let accountantId: String
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                ZStack {
                    if colorScheme == .dark {
                        Color(.systemBackground)
                            .edgesIgnoringSafeArea(.all)
                    } else {
                        LinearGradient(
                            colors: [
                                Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.1),
                                Color(.systemBackground).opacity(0.9),
                                Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .edgesIgnoringSafeArea(.all)
                    }
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            VStack(alignment: .leading, spacing: 8) {
                                if viewModel.isLoading {
                                    Text("Loading...")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(primaryColor)
                                } else if let accountant = viewModel.accountant {
                                    Text("Hi, \(accountant.name)")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                } else {
                                    Text("Welcome")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(primaryColor)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 24)
                            
                            // Accountant Cards Grid
                            VStack(spacing: 16) {
                                NavigationLink(destination: GenerateBillView()) {
                                    AccountantCard(
                                        title: "Generate Bill",
                                        icon: "doc.text",
                                        color: primaryColor
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 24)
                                }
                                
                                NavigationLink(destination: ScheduleFollowupsView()) {
                                    AccountantCard(
                                        title: "Schedule Followups",
                                        icon: "calendar.badge.clock",
                                        color: primaryColor
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 24)
                                }
                                
                                NavigationLink(destination: PaymentHistoryView()) {
                                    AccountantCard(
                                        title: "Payment History",
                                        icon: "chart.bar.fill",
                                        color: primaryColor
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 24)
                                }
                            }
                            .padding(.top)

                        }
                    }
                }
                .navigationBarHidden(true)
                .onAppear {
                    viewModel.fetchAccountant(byAccountantId: accountantId)
                }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            AccountantProfileView(accountantId: accountantId)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(1)
        }
        .accentColor(primaryColor)
    }
}

struct AccountantCard: View {
    let title: String
    let icon: String
    let color: Color
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .padding(12)
                .background(color.opacity(0.1))
                .clipShape(Circle())
                .frame(width: 44, height: 44)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.top, 8)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.05), radius: 8, x: 0, y: 4)
    }
}

struct ActionButton: View {
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(color)
                .clipShape(Circle())
            
            Text(label)
                .font(.title3)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TransactionItem: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.up.right")
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(Color.green)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Client Payment")
                    .font(.title3)
                    .foregroundColor(.primary)
                
                Text("Today, 10:30 AM")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("$1,250.00")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    Group {
        AccountantDashboard(accountantId: "ACC001")
            .preferredColorScheme(.light)
    }
}
