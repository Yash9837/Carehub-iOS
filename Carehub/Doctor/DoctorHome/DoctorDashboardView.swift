import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct DoctorDashboardView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var selectedDate = Date()
    @State private var viewMode: CalendarViewMode = .day
    @State private var appointments: [Appointment] = []
    @State private var doctorName: String = "Doctor"
    @State private var doctorId: String = ""
    
    @State private var showActionSheet = false
    @State private var showImagePicker = false
    @State private var showNotesView = false
    @State private var showPrescriptionView = false
    @State private var selectedAppointment: Appointment?
    
    @Environment(\.colorScheme) private var colorScheme
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: colorScheme == .dark ? [Color.black.opacity(0.9), Color(.systemGray6)] : [Color.white, Color(.systemGray6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hi, \(doctorName)")
                                .font(.system(.title2, design: .rounded, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Text("")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                        }
                        Spacer()
                        Image(systemName: "bell.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(purpleColor)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    
                    switch viewMode {
                    case .month:
                        MonthView(selectedDate: $selectedDate, viewMode: $viewMode)
                    case .day:
                        DayView(
                            selectedDate: $selectedDate,
                            appointments: appointments.filter { $0.date?.isSameDay(as: selectedDate) ?? false },
                            showNotesView: $showNotesView,
                            showPrescriptionView: $showPrescriptionView,
                            selectedAppointment: $selectedAppointment
                        )
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Doctor Dashboard")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }
            .onAppear {
                updateDoctorData()
            }
            .onReceive(authManager.$currentStaffMember) { newStaff in
                updateDoctorData()
            }
            .navigationDestination(isPresented: $showNotesView) {
                if let selectedAppointment = selectedAppointment {
                    NotesView(appointment: selectedAppointment)
                }
            }
            .navigationDestination(isPresented: $showPrescriptionView) {
                if let selectedAppointment = selectedAppointment {
                    PrescriptionView(appointment: selectedAppointment)
                }
            }
        }
    }
    
    private func updateDoctorData() {
        if let staff = authManager.currentStaffMember, staff.role == .doctor {
            doctorName = staff.fullName
            doctorId = staff.id ?? ""
            print("Doctor ID set to: \(doctorId) (from AuthManager)")
            print("Staff data: id=\(staff.id ?? "nil"), fullName=\(staff.fullName), role=\(String(describing: staff.role))")
            
            // Always fetch the correct Doctor_id from Firestore using the UID
            guard let uid = Auth.auth().currentUser?.uid else {
                print("No UID available to fetch doctor data - user might not be logged in")
                doctorId = ""
                doctorName = "Doctor"
                appointments = []
                return
            }
            
            print("Fetching doctor data for UID: \(uid)")
            db.collection("doctors").document(uid).getDocument { snapshot, error in
                if let error = error {
                    print("Error fetching doctor from UID: \(error.localizedDescription)")
                    doctorId = ""
                    doctorName = "Doctor"
                    appointments = []
                    return
                }
                
                guard let data = snapshot?.data(), snapshot?.exists == true else {
                    print("No document found for UID: \(uid) in doctors collection")
                    doctorId = ""
                    doctorName = "Doctor"
                    appointments = []
                    return
                }
                
                guard let docId = data["Doctorid"] as? String,
                      let name = data["Doctor_name"] as? String else {
                    print("Missing Doctor_id or Doctor_name in document data: \(data)")
                    doctorId = ""
                    doctorName = "Doctor"
                    appointments = []
                    return
                }
                
                print("Updated doctorId to: \(docId) from Firestore")
                print("Updated doctorName to: \(name) from Firestore")
                doctorId = docId
                doctorName = name
                fetchData() // Fetch appointments with the correct doctorId
            }
        } else {
            doctorName = "Doctor"
            doctorId = ""
            appointments = []
            print("No doctor logged in or role is not doctor")
        }
    }
    
    private func fetchData() {
        guard !doctorId.isEmpty else {
            print("No doctor ID available, cannot fetch appointments")
            appointments = []
            return
        }
        
        print("Fetching appointments for docId: \(doctorId)")
        db.collection("appointments")
            .whereField("docId", isEqualTo: doctorId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching appointments: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found for docId: \(doctorId)")
                    appointments = []
                    return
                }
                
                print("Found \(documents.count) appointment documents")
                appointments = documents.compactMap { doc -> Appointment? in
                    let data = doc.data()
                    print("Document data: \(data)")
                    
                    // Handle case-insensitive field names
                    let apptId = data["apptId"] as? String
                    let patientId = data["patientId"] as? String
                    let docId = data["docId"] as? String
                    let description = (data["description"] as? String) ?? (data["Description"] as? String)
                    let status = (data["status"] as? String) ?? (data["Status"] as? String)
                    let date = (data["date"] as? Timestamp) ?? (data["Date"] as? Timestamp)
                    let followUpDate = (data["followUpDate"] as? Timestamp) ?? (data["followUpdate"] as? Timestamp)
                    let doctorsNotes = (data["doctorsNotes"] as? String) ?? (data["doctorNotes"] as? String)
                    
                    guard let apptId = apptId,
                          let patientId = patientId,
                          let docId = docId,
                          let description = description,
                          let status = status else {
                        print("Failed to map document: \(doc.documentID), missing required fields")
                        return nil
                    }
                    
                    let appointment = Appointment(
                        id: doc.documentID,
                        apptId: apptId,
                        patientId: patientId,
                        description: description,
                        docId: docId,
                        status: status,
                        billingStatus: data["billingStatus"] as? String ?? "",
                        amount: data["amount"] as? Double,
                        date: date?.dateValue(),
                        doctorsNotes: doctorsNotes,
                        prescriptionId: data["prescriptionId"] as? String,
                        followUpRequired: data["followUpRequired"] as? Bool,
                        followUpDate: followUpDate?.dateValue()
                    )
                    print("Mapped appointment: \(appointment)")
                    return appointment
                }
                
                print("Total appointments after mapping: \(appointments.count)")
            }
    }
}

struct DayView: View {
    @Binding var selectedDate: Date
    let appointments: [Appointment]
    @Binding var showNotesView: Bool
    @Binding var showPrescriptionView: Bool
    @Binding var selectedAppointment: Appointment?
    
    var scheduleTitle: String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        if calendar.isDate(selectedDate, inSameDayAs: today) {
            return "Today's Schedule"
        } else if calendar.isDate(selectedDate, inSameDayAs: tomorrow) {
            return "Tomorrow's Schedule"
        } else {
            return "Upcoming Schedule"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DateSelectorBar(selectedDate: $selectedDate)
            
            Text(selectedDate.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                .font(.headline)
                .padding(.vertical, 8)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 8) {
                    Text(scheduleTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    if appointments.isEmpty {
                        Text("No appointments scheduled")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(appointments, id: \.id) { appointment in
                            AppointmentView(
                                appointment: appointment,
                                showNotesView: $showNotesView,
                                showPrescriptionView: $showPrescriptionView,
                                selectedAppointment: $selectedAppointment
                            )
                        }
                    }
                }
                .padding(.bottom)
            }
        }
    }
}

struct DateSelectorBar: View {
    @Binding var selectedDate: Date
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    
    var weekDates: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).map { calendar.date(byAdding: .day, value: $0, to: today)! }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(weekDates, id: \.self) { date in
                    VStack(spacing: 4) {
                        Text(date.formatted(.dateTime.weekday(.abbreviated)))
                            .font(.caption)
                        
                        Text(date.formatted(.dateTime.day()))
                            .font(.subheadline)
                            .padding(8)
                            .background(date.isSameDay(as: selectedDate) ? purpleColor : Color.clear)
                            .clipShape(Circle())
                            .foregroundColor(date.isSameDay(as: selectedDate) ? .white : .primary)
                    }
                    .frame(width: 40)
                    .onTapGesture {
                        selectedDate = date
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

struct AppointmentView: View {
    let appointment: Appointment
    @State private var patientName: String = "Unknown"
    @Binding var showNotesView: Bool
    @Binding var showPrescriptionView: Bool
    @Binding var selectedAppointment: Appointment?
    
    private let db = Firestore.firestore()
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(statusColor)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(patientName)
                    .font(.subheadline)
                    .bold()
                
                Text(appointment.date?.formatted(.dateTime) ?? "No Date")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(appointment.status.capitalized)
                    .font(.caption)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 6)
                    .background(statusColor.opacity(0.3))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                
                if !appointment.description.isEmpty {
                    Text(appointment.description)
                        .font(.caption)
                        .lineLimit(2)
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Menu {
                Button("Add Notes") {
                    selectedAppointment = appointment
                    showNotesView = true
                }
                Button("Add Prescription") {
                    selectedAppointment = appointment
                    showPrescriptionView = true
                }
            } label: {
                Image(systemName: "chevron.down")
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(Color.gray)
                    .clipShape(Circle())
            }
            .padding(.trailing, 8)
        }
        .background(statusColor.opacity(0.1))
        .cornerRadius(8)
        .onAppear {
            fetchPatientName()
        }
    }
    
    private var statusColor: Color {
        let status = appointment.status.lowercased()
        let hash = status.hashValue
        let r = CGFloat((hash & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((hash & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(hash & 0x0000FF) / 255.0
        return Color(red: r, green: g, blue: b).opacity(0.8)
    }
    
    private func fetchPatientName() {
            print("Fetching patient name for patientId: \(appointment.patientId)")
            db.collection("patients")
                .whereField("patientId", isEqualTo: appointment.patientId)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching patient: \(error)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents, !documents.isEmpty else {
                        print("No patient found for patientId: \(appointment.patientId)")
                        patientName = "Unknown"
                        return
                    }
                    
                    if let data = documents.first?.data(),
                       let userData = data["userData"] as? [String: Any],
                       let name = userData["Name"] as? String {
                        patientName = name
                        print("Patient name fetched: \(name)")
                    } else {
                        print("Failed to fetch patient name for patientId: \(appointment.patientId), data: \(String(describing: documents.first?.data()))")
                    }
                }
        }
}

struct MonthView: View {
    @Binding var selectedDate: Date
    @Binding var viewMode: CalendarViewMode
    
    var body: some View {
        VStack {
            MonthHeaderView(selectedDate: $selectedDate)
            CalendarGridView(selectedDate: $selectedDate, viewMode: $viewMode)
        }
    }
}

struct MonthHeaderView: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        HStack {
            Button(action: { changeMonth(by: -1) }) {
                Image(systemName: "chevron.left")
            }
            
            Spacer()
            
            Text(selectedDate.formatted(.dateTime.month(.wide)))
                .font(.headline)
            
            Spacer()
            
            Button(action: { changeMonth(by: 1) }) {
                Image(systemName: "chevron.right")
            }
        }
        .padding()
    }
    
    private func changeMonth(by value: Int) {
        selectedDate = Calendar.current.date(byAdding: .month, value: value, to: selectedDate)!
    }
}

struct CalendarGridView: View {
    @Binding var selectedDate: Date
    @Binding var viewMode: CalendarViewMode
    
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var daysInMonth: [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: selectedDate)!
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        
        return range.compactMap { day -> Date? in
            var newComponents = components
            newComponents.day = day
            return calendar.date(from: newComponents)
        }
    }
    
    var firstWeekday: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        let firstDay = calendar.date(from: components)!
        return calendar.component(.weekday, from: firstDay)
    }
    
    var body: some View {
        VStack {
            LazyVGrid(columns: columns) {
                ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 8)
            
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(0..<firstWeekday-1, id: \.self) { _ in
                    Color.clear
                }
                
                ForEach(daysInMonth, id: \.self) { date in
                    DayCell(date: date, selectedDate: $selectedDate, viewMode: $viewMode)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct DayCell: View {
    let date: Date
    @Binding var selectedDate: Date
    @Binding var viewMode: CalendarViewMode
    
    var body: some View {
        Button(action: {
            selectedDate = date
            viewMode = .day
        }) {
            VStack {
                Text(date.formatted(.dateTime.day()))
                    .font(.subheadline)
                    .foregroundColor(date.isSameDay(as: Date()) ? .red : .primary)
                    .frame(width: 30, height: 30)
                    .background(date.isSameDay(as: selectedDate) ? Color.red.opacity(0.2) : Color.clear)
                    .clipShape(Circle())
            }
            .frame(maxWidth: .infinity, minHeight: 40)
        }
    }
}

enum CalendarViewMode {
    case month, day
}

extension Date {
    func isSameDay(as other: Date) -> Bool {
        let calendar = Calendar.current
        let componentsSelf = calendar.dateComponents([.year, .month, .day], from: self)
        let componentsOther = calendar.dateComponents([.year, .month, .day], from: other)
        return componentsSelf.year == componentsOther.year &&
               componentsSelf.month == componentsOther.month &&
               componentsSelf.day == componentsOther.day
    }
}

#Preview {
    DoctorDashboardView()
}
