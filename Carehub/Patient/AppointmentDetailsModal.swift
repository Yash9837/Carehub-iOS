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
    @State private var selectedTime = "" // Changed to String to match time slots
    @State private var isDatePickerExpanded = false
    
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    private let gradientColors = [
        Color(red: 0.43, green: 0.34, blue: 0.99),
        Color(red: 0.55, green: 0.48, blue: 0.99)
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.94, blue: 1.0)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerView
                    
                    // Doctor Info
                    doctorInfoSection
                    
                    // Appointment Details
                    detailsSection
                    
                    // Action Buttons
                    actionButtonsSection
                    
                    Spacer()
                }
                .padding(.bottom, 30)
                .animation(.easeInOut(duration: 0.3), value: showReschedule)
            }
        }
        .navigationTitle("Appointment Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    isPresented = false
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showReschedule) {
            RescheduleView(
                appointment: appointment,
                selectedDate: $selectedDate,
                selectedTime: $selectedTime,
                isPresented: $showReschedule,
                onRescheduleComplete: {
                    isPresented = false
                    dismiss()
                }
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
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Appointment Details")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            
            Text("View and manage your appointment")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var doctorInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "person.fill")
                    .font(.system(size: 18))
                    .foregroundColor(purpleColor)
                
                Text("Doctor")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 20)
            
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
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text(specialty)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
            )
            .padding(.horizontal, 20)
        }
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.system(size: 18))
                    .foregroundColor(purpleColor)
                
                Text("Details")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 14) {
                DetailsRow(label: "Date & Time", value: formatDate(appointment.date ?? Date()), icon: "calendar", purpleColor: purpleColor)
                DetailsRow(label: "Description", value: appointment.description, icon: "text.bubble", purpleColor: purpleColor)
                DetailsRow(label: "Status", value: appointment.status.capitalized, icon: "checkmark.circle", purpleColor: purpleColor)
                DetailsRow(label: "Billing Status", value: appointment.billingStatus.capitalized, icon: "dollarsign.circle", purpleColor: purpleColor)
                DetailsRow(label: "Amount", value: String(format: "$%.2f", appointment.amount ?? 0.0), icon: "banknote", purpleColor: purpleColor)
                if appointment.followUpRequired ?? false {
                    DetailsRow(label: "Follow-Up", value: formatDate(appointment.followUpDate ?? Date()), icon: "calendar.badge.plus", purpleColor: purpleColor)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
            )
            .padding(.horizontal, 20)
        }
    }
    
    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            // Reschedule Button
            Button(action: {
                showReschedule = true
            }) {
                HStack {
                    Text("Reschedule")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .cornerRadius(12)
                    .shadow(color: purpleColor.opacity(0.3), radius: 8, x: 0, y: 4)
                )
            }
            
            // Cancel Button
            Button(action: {
                showCancelConfirmation = true
            }) {
                HStack {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors.map { $0.opacity(0.8) }),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .cornerRadius(12)
                    .shadow(color: purpleColor.opacity(0.3), radius: 8, x: 0, y: 4)
                )
            }
        }
        .padding(.horizontal, 20)
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
                NotificationCenter.default.post(name: NSNotification.Name("AppointmentCancelled"), object: nil)
                isPresented = false
                dismiss()
            }
        }
    }
}

struct DetailsRow: View {
    let label: String
    let value: String
    let icon: String
    let purpleColor: Color
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(purpleColor)
                .frame(width: 20)
            
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
                .lineLimit(1)
            
            Spacer()
        }
    }
}


struct RescheduleView: View {
    let appointment: Appointment
    @Binding var selectedDate: Date
    @Binding var selectedTime: String // Updated to String
    @Binding var isPresented: Bool
    @State private var isDatePickerExpanded = false
    @State private var isTimePickerExpanded = false
    @State private var isLoading = false
    @State private var selectedTimeSlot = "" // New state for time slot
    var onRescheduleComplete: (() -> Void)? = nil
    
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    private let gradientColors = [
        Color(red: 0.43, green: 0.34, blue: 0.99),
        Color(red: 0.55, green: 0.48, blue: 0.99)
    ]
    
    private var timeSlots: [String] {
        var slots = [String]()
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        
        guard let startDate = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) else {
            return []
        }
        
        var currentDate = startDate
        while calendar.component(.hour, from: currentDate) < 18 {
            slots.append(dateFormatter.string(from: currentDate))
            guard let newDate = calendar.date(byAdding: .minute, value: 30, to: currentDate) else {
                break
            }
            currentDate = newDate
        }
        
        return slots
    }
    
    private func isTimeSlotAvailable(_ slot: String) -> Bool {
        if Calendar.current.isDateInToday(selectedDate) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            
            guard let slotTime = timeFormatter.date(from: slot) else {
                return false
            }
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: slotTime)
            
            guard let slotDateTime = calendar.date(
                bySettingHour: components.hour ?? 0,
                minute: components.minute ?? 0,
                second: 0,
                of: Date()
            ) else {
                return false
            }
            
            return slotDateTime > Date().addingTimeInterval(15 * 60)
        }
        
        return true
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.94, green: 0.94, blue: 1.0)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reschedule Appointment")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("Choose a new date and time")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Date Selection
                        dateSelectionSection
                        
                        // Time Selection
                        timeSelectionSection
                        
                        // Save Button
                        Button(action: {
                            saveReschedule()
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Save New Schedule")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: gradientColors),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .cornerRadius(12)
                                .shadow(color: purpleColor.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                            .disabled(isLoading || selectedTimeSlot.isEmpty)
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                    .padding(.bottom, 30)
                    .animation(.easeInOut(duration: 0.3), value: isDatePickerExpanded)
                    .animation(.easeInOut(duration: 0.3), value: isTimePickerExpanded)
                }
            }
            .navigationTitle("Reschedule Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .onAppear {
                selectedTimeSlot = selectedTime // Sync initial value
            }
        }
    }
    
    private var dateSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 18))
                    .foregroundColor(purpleColor)
                
                Text("Date")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 20)
            
            VStack {
                if !isDatePickerExpanded {
                    Button(action: {
                        withAnimation {
                            isDatePickerExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Text(formattedDate(selectedDate))
                                .foregroundColor(.black)
                                .font(.system(size: 16))
                            
                            Spacer()
                            
                            Image(systemName: "calendar")
                                .foregroundColor(purpleColor)
                                .font(.system(size: 14))
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                        )
                    }
                } else {
                    VStack {
                        DatePicker(
                            "Select Date",
                            selection: $selectedDate,
                            in: Date()...Calendar.current.date(byAdding: .month, value: 3, to: Date())!,
                            displayedComponents: .date
                        )
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .accentColor(purpleColor)
                        .padding(.top, 8)
                        
                        Button(action: {
                            withAnimation {
                                isDatePickerExpanded.toggle()
                            }
                        }) {
                            Text("Done")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: gradientColors),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(10)
                                .shadow(color: purpleColor.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        .padding(.top, 12)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var timeSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 18))
                    .foregroundColor(purpleColor)
                
                Text("Available Time Slots")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(purpleColor.opacity(0.8))
                        .font(.system(size: 14))
                    
                    Text(formattedDateWithDay(selectedDate))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(timeSlots, id: \.self) { slot in
                        Button(action: {
                            selectedTimeSlot = slot
                            selectedTime = slot // Update the binding
                        }) {
                            Text(slot)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(slotTextColor(for: slot))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    Group {
                                        if selectedTimeSlot == slot {
                                            LinearGradient(
                                                gradient: Gradient(colors: gradientColors),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                            .cornerRadius(10)
                                            .shadow(color: purpleColor.opacity(0.3), radius: 4, x: 0, y: 2)
                                        } else {
                                            Color.white
                                                .cornerRadius(10)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(slotBorderColor(for: slot), lineWidth: 1)
                                                )
                                        }
                                    }
                                )
                        }
                        .disabled(!isTimeSlotAvailable(slot))
                        .opacity(isTimeSlotAvailable(slot) ? 1.0 : 0.5)
                    }
                }
                .padding(16)
            }
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
            )
            .padding(.horizontal, 20)
        }
    }
    
    private func slotTextColor(for slot: String) -> Color {
        if !isTimeSlotAvailable(slot) {
            return .gray
        }
        return selectedTimeSlot == slot ? .white : purpleColor
    }
    
    private func slotBorderColor(for slot: String) -> Color {
        if !isTimeSlotAvailable(slot) {
            return Color.gray.opacity(0.3)
        }
        return purpleColor
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formattedDateWithDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private func saveReschedule() {
        isLoading = true
        let db = Firestore.firestore()
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        guard let timeDate = timeFormatter.date(from: selectedTimeSlot) else {
            isLoading = false
            print("Error parsing time slot")
            return
        }
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: timeDate)
        
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
                isLoading = false
                if let error = error {
                    print("Error rescheduling appointment: \(error.localizedDescription)")
                } else {
                    print("Appointment rescheduled successfully")
                    NotificationCenter.default.post(name: NSNotification.Name("AppointmentBooked"), object: nil)
                    isPresented = false
                    onRescheduleComplete?()
                }
            }
        } else {
            isLoading = false
            print("Error combining date and time")
        }
    }
}
