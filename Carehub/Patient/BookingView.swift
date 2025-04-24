import SwiftUI
import FirebaseFirestore

struct ScheduleAppointmentView: View {
    @State private var selectedSpecialty = ""
    @State private var selectedDoctor = ""
    @State private var selectedDate = Date()
    @State private var selectedTimeSlot = ""
    @State private var isDatePickerExpanded = false
    @State private var description: String = ""
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    let specialties = DoctorData.specialties
    let doctors = DoctorData.doctors
    
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
    
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    private let gradientColors = [
        Color(red: 0.43, green: 0.34, blue: 0.99),
        Color(red: 0.55, green: 0.48, blue: 0.99)
    ]
    
    private let currentPatientId = "PT001" // Example patient ID
    
    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.94, blue: 1.0)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    headerView
                    
                    specialtySelectionSection
                    
                    if !selectedSpecialty.isEmpty {
                        doctorSelectionSection
                    }
                    
                    if !selectedDoctor.isEmpty {
                        dateSelectionSection
                    }
                    
                    if !selectedDoctor.isEmpty {
                        timeSlotSelectionSection
                    }
                    
                    if !selectedDoctor.isEmpty {
                        descriptionField
                    }
                    
                    if !selectedSpecialty.isEmpty && !selectedDoctor.isEmpty && !selectedTimeSlot.isEmpty {
                        confirmButtonSection
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 30)
                .animation(.easeInOut(duration: 0.3), value: selectedSpecialty)
                .animation(.easeInOut(duration: 0.3), value: selectedDoctor)
                .animation(.easeInOut(duration: 0.3), value: selectedTimeSlot)
                .animation(.easeInOut(duration: 0.3), value: isDatePickerExpanded)
            }
        }
        .navigationTitle("New Appointment")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Appointment Scheduled", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your appointment has been successfully scheduled.")
        }
        .alert("Cannot Schedule Appointment", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Already Booked a slot for this day. Please try again later.")
        }
    }
    
    // MARK: - View Components
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Book Appointment")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            
            Text("Schedule with your preferred doctor")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var specialtySelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "stethoscope")
                    .font(.system(size: 18))
                    .foregroundColor(purpleColor)
                
                Text("Specialty")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 20)
            
            Menu {
                ForEach(specialties, id: \.self) { specialty in
                    Button(action: {
                        selectedSpecialty = specialty
                        selectedDoctor = ""
                        selectedTimeSlot = ""
                    }) {
                        Text(specialty)
                    }
                }
            } label: {
                HStack {
                    Text(selectedSpecialty.isEmpty ? "Select Specialty" : selectedSpecialty)
                        .foregroundColor(selectedSpecialty.isEmpty ? .gray : .black)
                        .font(.system(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
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
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var doctorSelectionSection: some View {
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
            
            Menu {
                ForEach(doctors[selectedSpecialty] ?? [], id: \.name) { doctor in
                    Button(action: {
                        selectedDoctor = doctor.name
                        selectedTimeSlot = ""
                    }) {
                        Text(doctor.name)
                    }
                }
            } label: {
                HStack {
                    Text(selectedDoctor.isEmpty ? "Select Doctor" : selectedDoctor)
                        .foregroundColor(selectedDoctor.isEmpty ? .gray : .black)
                        .font(.system(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
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
                .padding(.horizontal, 20)
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
    
    private var timeSlotSelectionSection: some View {
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
                        }) {
                            Text(slot)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedTimeSlot == slot ? .white : purpleColor)
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
                                                        .stroke(purpleColor, lineWidth: 1)
                                                )
                                        }
                                    }
                                )
                        }
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
    
    private var descriptionField: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "text.bubble")
                    .font(.system(size: 18))
                    .foregroundColor(purpleColor)
                
                Text("Description (Optional)")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 20)
            
            TextField("Brief description of your appointment", text: $description)
                .font(.system(size: 16))
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                )
                .padding(.horizontal, 20)
        }
    }
    
    private var confirmButtonSection: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Appointment Summary")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(purpleColor)
                
                VStack(spacing: 14) {
                    summaryRow(icon: "stethoscope", title: "Specialty", value: selectedSpecialty)
                    summaryRow(icon: "person.fill", title: "Doctor", value: selectedDoctor)
                    summaryRow(icon: "calendar", title: "Date", value: formattedDate(selectedDate))
                    summaryRow(icon: "clock.fill", title: "Time", value: selectedTimeSlot)
                    if !description.isEmpty {
                        summaryRow(icon: "text.bubble", title: "Description", value: description)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.97, green: 0.97, blue: 1.0))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.9, green: 0.9, blue: 1.0), lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, 20)
            
            Button(action: {
                scheduleAppointment()
            }) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Confirm Appointment")
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
                .disabled(isLoading)
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Helper Functions
    private func summaryRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(purpleColor)
                .frame(width: 20)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
                .lineLimit(1)
            
            Spacer()
        }
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
    
    // MARK: - Appointment Scheduling Logic
    private func scheduleAppointment() {
        isLoading = true
        
        let calendar = Calendar.current
        let startOfSelectedDate = calendar.startOfDay(for: selectedDate)
        let endOfSelectedDate = calendar.date(byAdding: .day, value: 1, to: startOfSelectedDate)!
        
        let db = Firestore.firestore()
        
        // Check for existing appointments on this date
        db.collection("appointments")
            .whereField("patientId", isEqualTo: currentPatientId)
            .whereField("Date", isGreaterThanOrEqualTo: startOfSelectedDate)
            .whereField("Date", isLessThan: endOfSelectedDate)
            .getDocuments { [self] (querySnapshot, error) in
                if let error = error {
                    errorMessage = "Error checking appointments: \(error.localizedDescription)"
                    showErrorAlert = true
                    isLoading = false
                    return
                }
                
                guard let documents = querySnapshot?.documents, documents.isEmpty else {
                    errorMessage = "You already have an appointment scheduled for this day. Please choose another date."
                    showErrorAlert = true
                    isLoading = false
                    return
                }
                
                // No existing appointment - proceed to create new one
                createNewAppointment()
            }
    }
    
    private func createNewAppointment() {
        let appointmentId = "APT\(UUID().uuidString.prefix(6))"
        let calendar = Calendar.current
        
        // Combine date and time
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        guard let timeDate = timeFormatter.date(from: selectedTimeSlot) else {
            isLoading = false
            errorMessage = "Invalid time format"
            showErrorAlert = true
            return
        }
        
        let timeComponents = calendar.dateComponents([.hour, .minute], from: timeDate)
        guard let appointmentDateTime = calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                                      minute: timeComponents.minute ?? 0,
                                                      second: 0,
                                                      of: selectedDate) else {
            isLoading = false
            errorMessage = "Could not create appointment date"
            showErrorAlert = true
            return
        }
        
        let doctorId = "DOC\(selectedDoctor.hashValue)"
        let followUpDate = calendar.date(byAdding: .day, value: 7, to: appointmentDateTime) ?? Date()
        
        let appointmentData: [String: Any] = [
            "Date": appointmentDateTime,
            "Description": description.isEmpty ? "Annual Checkup" : description,
            "Status": "scheduled",
            "apptId": appointmentId,
            "billingStatus": "pending",
            "docId": doctorId,
            "doctorNotes": "",
            "followUpDate": followUpDate,
            "followUpRequired": false,
            "patientId": currentPatientId,
            "prescriptionId": ""
        ]
        
        let db = Firestore.firestore()
        db.collection("appointments").document(appointmentId).setData(appointmentData) { error in
            isLoading = false
            if let error = error {
                errorMessage = "Failed to schedule appointment"
                showErrorAlert = true
            } else {
                showSuccessAlert = true
                resetForm()
            }
        }
    }
    
    private func resetForm() {
        selectedSpecialty = ""
        selectedDoctor = ""
        selectedDate = Date()
        selectedTimeSlot = ""
        description = ""
    }
}

struct ScheduleAppointmentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScheduleAppointmentView()
        }
    }
}

