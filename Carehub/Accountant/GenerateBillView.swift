import SwiftUI
import FirebaseFirestore

struct GenerateBillView: View {
    @StateObject private var viewModel = GenerateBillViewModel()
    @State private var patientIdInput = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // Modern minimal color palette
    let accentColor = Color(hex: "6D57FC")
    let backgroundColor = Color(hex: "F9F9FB")
    let cardColor = Color.white
    
    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Minimalist header
                VStack(spacing: 16) {
                    Text("Generate Bill")
                        .font(.title)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Clean search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Enter Patient ID", text: $patientIdInput)
                            .onChange(of: patientIdInput) { _ in
                                if patientIdInput.count >= 4 {
                                    viewModel.fetchAppointments(forPatientId: patientIdInput)
                                }
                            }
                            .submitLabel(.search)
                            .onSubmit {
                                viewModel.fetchAppointments(forPatientId: patientIdInput)
                            }
                        
                        if !patientIdInput.isEmpty {
                            Button(action: {
                                patientIdInput = ""
                                viewModel.paidAppointments = []
                                viewModel.unpaidAppointments = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        if patientIdInput.count >= 1 {
                            Button(action: {
                                viewModel.fetchAppointments(forPatientId: patientIdInput)
                            }) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundColor(accentColor)
                                    .font(.system(size: 20))
                            }
                        }
                    }
                    .padding(12)
                    .background(cardColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Status indicator
                if viewModel.isLoading {
                    LoadingView()
                        .padding(.top, 24)
                } else if let error = viewModel.error {
                    ErrorView(error: error) {
                        viewModel.fetchAppointments(forPatientId: patientIdInput)
                    }
                    .padding(.top, 24)
                } else if viewModel.unpaidAppointments.isEmpty && viewModel.paidAppointments.isEmpty {
                    EmptyStateView()
                        .padding(.top, 40)
                } else {
                    // Content
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            // Pending payments section
                            if !viewModel.unpaidAppointments.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Pending")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Text("\(viewModel.unpaidAppointments.count)")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(accentColor)
                                    }
                                    
                                    ForEach(viewModel.unpaidAppointments) { appointment in
                                        AppointmentCard(appointment: appointment, viewModel: viewModel)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            // Completed payments section
                            if !viewModel.paidAppointments.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Completed")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Text("\(viewModel.paidAppointments.count)")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(accentColor)
                                    }
                                    
                                    ForEach(viewModel.paidAppointments) { appointment in
                                        AppointmentCard(appointment: appointment, isPaid: true)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

// MARK: - Subviews
struct AppointmentCard: View {
    let appointment: Appointment
    var viewModel: GenerateBillViewModel?
    var isPaid: Bool = false
    @State private var showingActionSheet = false
    @State private var isProcessing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(appointment.description)
                        .font(.system(size: 16, weight: .medium))
                        .lineLimit(1)
                    
                    Text("Dr. \(appointment.docId)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let amount = appointment.amount {
                    Text(String(format: "$%.2f", amount))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "6D57FC"))
                }
            }
            
            HStack {
                if let date = appointment.date {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                        Text(formattedDate(date))
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    // Status indicator
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    
                    Text(appointment.billingStatus.capitalized)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            if !isPaid && viewModel != nil {
                Button(action: {
                    showingActionSheet = true
                }) {
                    Text("Mark as Paid")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(isProcessing ? Color.gray : Color(hex: "6D57FC"))
                        .cornerRadius(8)
                }
                .disabled(isProcessing)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 2)
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text("Confirm Payment"),
                message: Text("Are you sure you want to mark this appointment as paid?"),
                buttons: [
                    .default(Text("Yes, Mark as Paid")) {
                        markAsPaid()
                    },
                    .cancel()
                ]
            )
        }
    }
    
    private var statusColor: Color {
        if appointment.billingStatus.lowercased() == "paid" {
            return Color.green
        } else {
            return Color.orange
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func markAsPaid() {
        guard let viewModel = viewModel else { return }
        
        isProcessing = true
        viewModel.markAsPaid(appointmentId: appointment.id) { success in
            isProcessing = false
            if success {
                // Refresh the appointments
                viewModel.fetchAppointments(forPatientId: appointment.patientId)
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.2)
            
            Text("Loading...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 42))
                .foregroundColor(Color(hex: "6D57FC").opacity(0.5))
            
            Text("No Appointments Found")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Enter a patient ID to search for appointments")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36))
                .foregroundColor(.orange)
            
            Text("Unable to Load Data")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Button(action: retryAction) {
                Text("Try Again")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(hex: "6D57FC"))
                    .cornerRadius(8)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
struct GenerateBillView_Previews: PreviewProvider {
    static var previews: some View {
        GenerateBillView()
    }
}
