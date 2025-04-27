import SwiftUI
import FirebaseFirestore

struct AppointmentDetailsModal: View {
    let appointment: Appointment
    let doctorName: String
    let specialty: String
    let imageName: String
    @Binding var isPresented: Bool
    @Environment(\.dismiss) var dismiss
    
    @State private var showReschedule = false
    @State private var showCancelConfirmation = false
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    
    let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }
            
            // Modal content
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Appointment Details")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 24))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Doctor Info
                HStack(spacing: 16) {
                    Group {
                        if UIImage(named: imageName) != nil {
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(purpleColor, lineWidth: 2))
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(purpleColor)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(doctorName)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text(specialty)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                VStack(alignment: .leading, spacing: 12) {
                    DetailsRow(label: "Date & Time", value: formatDate(appointment.date ?? Date()))
                    DetailsRow(label: "Description", value: appointment.description)
                    DetailsRow(label: "Status", value: appointment.status.capitalized)
                    DetailsRow(label: "Billing Status", value: appointment.billingStatus.capitalized)
                    DetailsRow(label: "Amount", value: String(format: "$%.2f", appointment.amount ?? "0"))
                    if appointment.followUpRequired ?? true {
                        DetailsRow(label: "Follow-Up", value: formatDate(appointment.followUpDate ?? Date()))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // Action Buttons
                HStack(spacing: 12) {
                    // Reschedule Button
                    Button(action: {
                        showReschedule = true
                    }) {
                        Text("Reschedule")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(purpleColor)
                            .cornerRadius(12)
                    }
                    
                    // Cancel Button
                    Button(action: {
                        showCancelConfirmation = true
                    }) {
                        Text("Cancel Appointment")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color.white)
            .cornerRadius(20)
            .padding(.horizontal, 20)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .sheet(isPresented: $showReschedule) {
            RescheduleView(
                appointment: appointment,
                selectedDate: $selectedDate,
                selectedTime: $selectedTime,
                isPresented: $showReschedule
            )
        }
        .alert("Confirm Cancellation", isPresented: $showCancelConfirmation) {
            Button("Cancel Appointment", role: .destructive) {
                cancelAppointment()
            }
            Button("Keep Appointment", role: .cancel) {}
        } message: {
            Text("Are you sure you want to cancel this appointment? This action cannot be undone.")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func cancelAppointment() {
        let db = Firestore.firestore()
        db.collection("appointments").document(appointment.id).updateData([
            "status": "cancelled",
            "billingStatus": "cancelled"
        ]) { error in
            if let error = error {
                print("Error cancelling appointment: \(error.localizedDescription)")
            } else {
                print("Appointment cancelled successfully")
                isPresented = false
            }
        }
    }
}

// Helper view for detail rows
struct DetailsRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(.black)
        }
    }
}

struct RescheduleView: View {
    let appointment: Appointment
    @Binding var selectedDate: Date
    @Binding var selectedTime: Date
    @Binding var isPresented: Bool
    let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Date Picker
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding(.horizontal)
                
                // Time Picker
                DatePicker(
                    "Select Time",
                    selection: $selectedTime,
                    displayedComponents: [.hourAndMinute]
                )
                .datePickerStyle(.wheel)
                .padding(.horizontal)
                
                // Save Button
                Button(action: {
                    saveReschedule()
                }) {
                    Text("Save New Schedule")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(purpleColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle("Reschedule Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func saveReschedule() {
        let db = Firestore.firestore()
        
        // Combine date and time
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        
        if let newDate = calendar.date(from: combinedComponents) {
            db.collection("appointments").document(appointment.id).updateData([
                "date": Timestamp(date: newDate)
            ]) { error in
                if let error = error {
                    print("Error rescheduling appointment: \(error.localizedDescription)")
                } else {
                    print("Appointment rescheduled successfully")
                    isPresented = false
                }
            }
        }
    }
}
