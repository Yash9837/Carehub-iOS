import SwiftUI

struct ScheduleAppointmentView: View {
    @State private var selectedSpecialty = ""
    @State private var selectedDoctor = ""
    @State private var selectedDate = Date()
    @State private var selectedTimeSlot = ""
    @State private var isDatePickerExpanded = false
    
    let specialties = ["Cardiology", "Dermatology", "Neurology", "Pediatrics", "Orthopedics", "General Practice"]
    
    let doctors: [String: [String]] = [
        "Cardiology": ["Dr. Rasheed Idris", "Dr. Kenny Adeola", "Dr. Johnson"],
        "Dermatology": ["Dr. Taiwo", "Dr. Nkechi Okeli"],
        "Neurology": ["Dr. Smith", "Dr. Williams"],
        "Pediatrics": ["Dr. Brown", "Dr. Davis"],
        "Orthopedics": ["Dr. Miller", "Dr. Wilson"],
        "General Practice": ["Dr. Taylor", "Dr. Anderson"]
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
    
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    private let gradientColors = [
        Color(red: 0.43, green: 0.34, blue: 0.99),
        Color(red: 0.55, green: 0.48, blue: 0.99)
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.94, green: 0.94, blue: 1.0)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header with improved styling
                    headerView
                    
                    // Specialty Selection
                    specialtySelectionSection
                    
                    // Doctor Selection (only shown when specialty is selected)
                    if !selectedSpecialty.isEmpty {
                        doctorSelectionSection
                    }
                    
                    // Date Selection (only shown when doctor is selected)
                    if !selectedDoctor.isEmpty {
                        dateSelectionSection
                    }
                    
                    // Time Slots (only shown when date is selected)
                    if !selectedDoctor.isEmpty {
                        timeSlotSelectionSection
                    }
                    
                    // Confirm Button (only shown when all fields are selected)
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
    }
    
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
            // Section title with icon
            HStack(spacing: 8) {
                Image(systemName: "stethoscope")
                    .font(.system(size: 18))
                    .foregroundColor(purpleColor)
                
                Text("Specialty")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 20)
            
            // Specialty selector
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
            // Section title with icon
            HStack(spacing: 8) {
                Image(systemName: "person.fill")
                    .font(.system(size: 18))
                    .foregroundColor(purpleColor)
                
                Text("Doctor")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 20)
            
            // Doctor selector
            Menu {
                ForEach(doctors[selectedSpecialty] ?? [], id: \.self) { doctor in
                    Button(action: {
                        selectedDoctor = doctor
                        selectedTimeSlot = ""
                    }) {
                        Text(doctor)
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
        .transition(.opacity)
    }
    
    private var dateSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section title with icon
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
                    // Collapsed date view
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
                    // Expanded date picker
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
                        
                        // Done button
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
        .transition(.opacity)
    }
    
    private var timeSlotSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section title with icon
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
                // Date display with indicator
                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(purpleColor.opacity(0.8))
                        .font(.system(size: 14))
                    
                    Text(formattedDateWithDay(selectedDate))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                
                // Time slots grid
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
        .transition(.opacity)
    }
    
    private var confirmButtonSection: some View {
        VStack(spacing: 20) {
            // Appointment Summary
            VStack(alignment: .leading, spacing: 16) {
                Text("Appointment Summary")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(purpleColor)
                
                VStack(spacing: 14) {
                    summaryRow(icon: "stethoscope", title: "Specialty", value: selectedSpecialty)
                    summaryRow(icon: "person.fill", title: "Doctor", value: selectedDoctor)
                    summaryRow(icon: "calendar", title: "Date", value: formattedDate(selectedDate))
                    summaryRow(icon: "clock.fill", title: "Time", value: selectedTimeSlot)
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
            
            // Confirm Button
            Button(action: {
                // Handle appointment confirmation
                print("Appointment scheduled with \(selectedDoctor) at \(selectedTimeSlot) on \(formattedDate(selectedDate))")
            }) {
                HStack {
                    Text("Confirm Appointment")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
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
            .padding(.horizontal, 20)
        }
        .transition(.opacity)
    }
    
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
}

struct ScheduleAppointmentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScheduleAppointmentView()
        }
    }
}
