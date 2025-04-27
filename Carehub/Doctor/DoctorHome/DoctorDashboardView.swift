
import SwiftUI
import FirebaseFirestore


struct DoctorDashboardView: View {
    @State private var selectedDate = Date()
    @State private var viewMode: CalendarViewMode = .day
    @State private var appointments: [Appointment] = []
    @State private var doctorName: String = "Doctor"
    @State private var doctorId: String = "DOC001"
    
    @State private var showActionSheet = false
    @State private var showImagePicker = false
    @State private var showNotesView = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
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
                        DayView(selectedDate: $selectedDate, appointments: appointments.filter { $0.date?.isSameDay(as: selectedDate) ?? false })
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
                fetchDoctorData()
                fetchData()
            }
        }
    }
    
    private func fetchDoctorData() {
        db.collection("doctors").document(doctorId).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching doctor: \(error)")
                return
            }
            
            if let data = snapshot?.data(),
               let name = data["Doctor_name"] as? String {
                doctorName = name
            }
        }
    }
    
    private func fetchData() {
        db.collection("appointments")
            .whereField("docId", isEqualTo: doctorId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching appointments: \(error)")
                    return
                }
                
                appointments = snapshot?.documents.compactMap { doc -> Appointment? in
                    let data = doc.data()
                    guard let apptId = data["apptId"] as? String,
                          let patientId = data["patientId"] as? String,
                          let docId = data["docId"] as? String,
                          let description = data["Description"] as? String,
                          let status = data["Status"] as? String else { return nil }
                    
                    return Appointment(
                        id: doc.documentID,
                        apptId: apptId,
                        patientId: patientId,
                        description: description,
                        docId: docId,
                        status: status,
                        billingStatus: data["billingStatus"] as? String ?? "",
                        amount: data["amount"] as? Double,
                        date: (data["Date"] as? Timestamp)?.dateValue(),
                        doctorsNotes: data["doctorNotes"] as? String,
                        prescriptionId: data["prescriptionId"] as? String,
                        followUpRequired: data["followUpRequired"] as? Bool,
                        followUpDate: (data["followUpdate"] as? Timestamp)?.dateValue()
                    )
                } ?? []
            }
    }
}

struct DayView: View {
    @Binding var selectedDate: Date
    let appointments: [Appointment]
    
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
                            AppointmentView(appointment: appointment)
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
    @State private var isShowingNotesView: Bool = false
    @State private var isShowingPrescriptionView: Bool = false
    
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
                    isShowingNotesView = true
                }
                Button("Add Prescription") {
                    isShowingPrescriptionView = true
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
        .navigationDestination(isPresented: $isShowingNotesView) {
            NotesView(appointment: appointment)
        }
        .navigationDestination(isPresented: $isShowingPrescriptionView) {
            PrescriptionView(appointment: appointment)
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
        db.collection("patients").document(appointment.patientId).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching patient: \(error)")
                return
            }
            if let data = snapshot?.data(),
               let userData = data["userData"] as? [String: Any],
               let name = userData["Name"] as? String {
                patientName = name
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
        Calendar.current.isDate(self, inSameDayAs: other)
    }
}

#Preview {
    DoctorDashboardView()
}
