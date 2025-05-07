//import SwiftUI
//import FirebaseFirestore
//
//// MARK: - Models
//struct Notification: Identifiable {
//    let id: String
//    let title: String
//    let message: String
//    let date: Date
//    let appointmentId: String?
//    let type: String
//}
//
//// MARK: - HomeView_patient
//struct HomeView_patient: View {
//    let patient: PatientF
//    @Environment(\.colorScheme) var colorScheme
//    private let primaryColor = Color(red: 0.43, green: 0.34, blue: 0.99)
//    private let secondaryColor = Color(red: 0.55, green: 0.48, blue: 0.99)
//    private let backgroundColor = Color(red: 0.97, green: 0.97, blue: 1.0)
//    private let cardBackground = Color.white
//    @State private var upcomingSchedules: [Appointment] = []
//    @State private var isLoading = true
//    @State private var navigateToBooking = false
//    @State private var navigateToNotifications = false
//    @State private var listener: ListenerRegistration?
//    @State private var notificationCount: Int = 0
//    @StateObject private var viewModel = AppointmentViewModel()
//    private let forNowColor = Color(red: 0.51, green: 0.44, blue: 0.87)
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                backgroundColor
//                    .edgesIgnoringSafeArea(.all)
//                
//                ScrollView(showsIndicators: false) {
//                    VStack(spacing: 24) {
//                        // Header
//                        HStack(alignment: .center) {
//                            VStack(alignment: .leading, spacing: 6) {
//                                Text("Hello, \(patient.userData.Name)")
//                                    .font(.system(size: 28, weight: .bold))
//                                    .foregroundColor(.black)
//                                
//                                Text("Welcome to CareHub")
//                                    .font(.system(size: 16, weight: .medium))
//                                    .foregroundColor(.gray)
//                            }
//                            
//                            Spacer()
//                            
//                            Button(action: {
//                                navigateToNotifications = true
//                            }) {
//                                ZStack {
//                                    Circle()
//                                        .fill(cardBackground)
//                                        .frame(width: 44, height: 44)
//                                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
//                                    
//                                    Image(systemName: "bell.fill")
//                                        .foregroundColor(primaryColor)
//                                        .font(.system(size: 18))
//                                    
//                                    if notificationCount > 0 {
//                                        ZStack {
//                                            Circle()
//                                                .fill(Color.red)
//                                                .frame(width: 20, height: 20)
//                                            Text("\(notificationCount)")
//                                                .font(.system(size: 12, weight: .bold))
//                                                .foregroundColor(.white)
//                                        }
//                                        .offset(x: 12, y: -12)
//                                    }
//                                }
//                            }
//                            .accessibilityLabel("Notifications, \(notificationCount) new")
//                        }
//                        .padding(.horizontal, 16)
//                        .padding(.top, 16)
//                        
//                        // Book Appointment Card
//                        Button(action: {
//                            navigateToBooking = true
//                        }) {
//                            ZStack {
//                                RoundedRectangle(cornerRadius: 16)
//                                    .fill(LinearGradient(
//                                        gradient: Gradient(colors: [forNowColor, secondaryColor]),
//                                        startPoint: .topLeading,
//                                        endPoint: .bottomTrailing
//                                    ))
//                                    .shadow(color: primaryColor.opacity(0.2), radius: 10, x: 0, y: 5)
//                                
//                                HStack(spacing: 16) {
//                                    Image(systemName: "calendar.badge.plus")
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 50, height: 50)
//                                        .foregroundColor(.white)
//                                        .padding(.leading, 16)
//                                    
//                                    VStack(alignment: .leading, spacing: 8) {
//                                        Text("Book an Appointment")
//                                            .font(.system(size: 18, weight: .bold))
//                                            .foregroundColor(.white)
//                                        
//                                        Text("Schedule with your preferred doctor")
//                                            .font(.system(size: 14, weight: .medium))
//                                            .foregroundColor(.white.opacity(0.8))
//                                    }
//                                    
//                                    Spacer()
//                                    
//                                    Image(systemName: "chevron.right")
//                                        .foregroundColor(.white)
//                                        .font(.system(size: 18))
//                                        .padding(.trailing, 16)
//                                }
//                                .padding(.vertical, 16)
//                            }
//                            .frame(maxWidth: .infinity)
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                        .padding(.horizontal, 16)
//                        .padding(.bottom, 10)
//                        
//                        // Upcoming Appointments Section
//                        VStack(alignment: .leading, spacing: 16) {
//                            sectionHeader(
//                                title: "Upcoming Appointments",
//                                hasContent: !upcomingSchedules.isEmpty
//                            ) {
//                                NavigationLink(destination: AllAppointmentsView(
//                                    upcomingSchedules: $upcomingSchedules,
//                                    getDoctorName: getDoctorName,
//                                    getDoctorSpecialty: getDoctorSpecialty,
//                                    formatDate: formatDate
//                                )) {
//                                    Text("See All")
//                                        .font(.system(size: 14, weight: .semibold))
//                                        .foregroundColor(primaryColor)
//                                }
//                            }
//                            
//                            if isLoading {
//                                HStack {
//                                    Spacer()
//                                    ProgressView()
//                                        .padding()
//                                    Spacer()
//                                }
//                            } else if upcomingSchedules.isEmpty {
//                                emptyStateView(
//                                    icon: "calendar",
//                                    title: "No Upcoming Appointments",
//                                    message: "You don't have any scheduled appointments"
//                                )
//                            } else {
//                                ScrollView(.horizontal, showsIndicators: false) {
//                                    HStack(spacing: 16) {
//                                        ForEach($upcomingSchedules) { $appointment in
//                                            ImprovedAppointmentCard(
//                                                doctorName: getDoctorName(for: appointment.docId),
//                                                specialty: getDoctorSpecialty(for: appointment.docId),
//                                                date: formatDateTime(appointment.date ?? Date()).date,
//                                                time: formatDateTime(appointment.date ?? Date()).time,
//                                                imageName: "doctor1",
//                                                appointment: $appointment
//                                            )
//                                        }
//                                    }
//                                    .padding(.vertical, 8)
//                                    .padding(.horizontal, 2)
//                                }
//                            }
//                        }
//                        
//                        // Recent Prescriptions Section
//                        VStack(alignment: .leading, spacing: 16) {
//                            sectionHeader(
//                                title: "Recent Prescriptions & Reports",
//                                hasContent: !viewModel.recentPrescriptions.isEmpty
//                            ) {
//                                NavigationLink(destination: AllPrescriptionsView(
//                                    prescriptions: viewModel.recentPrescriptions,
//                                    formatDate: formatDate
//                                )) {
//                                    Text("See All")
//                                        .font(.system(size: 14, weight: .semibold))
//                                        .foregroundColor(primaryColor)
//                                }
//                            }
//                            
//                            if viewModel.recentPrescriptions.isEmpty {
//                                emptyStateView(
//                                    icon: "doc.text",
//                                    title: "No Recent Prescriptions",
//                                    message: "Your prescriptions will appear here"
//                                )
//                            } else {
//                                ScrollView(.horizontal, showsIndicators: false) {
//                                    HStack(spacing: 16) {
//                                        ForEach(viewModel.recentPrescriptions) { appointment in
//                                            NavigationLink(
//                                                destination: {
//                                                    if let prescriptionIdStr = appointment.prescriptionId,
//                                                       let prescriptionUrl = URL(string: prescriptionIdStr) {
//                                                        PDFKitView(url: prescriptionUrl)
//                                                    } else {
//                                                        PDFKitView(url: URL(string: "https://example.com")!)
//                                                    }
//                                                },
//                                                label: {
//                                                    ImprovedMedicalRecordCard(
//                                                        type: appointment.status,
//                                                        doctorName: "Dr. \(getDoctorName(for: appointment.docId))",
//                                                        date: formatDate(appointment.date),
//                                                        title: appointment.description
//                                                    )
//                                                }
//                                            )
//                                        }
//                                    }
//                                    .padding(.vertical, 8)
//                                    .padding(.horizontal, 2)
//                                }
//                            }
//                        }
//                        .onAppear {
//                            viewModel.fetchRecentPrescriptions(forPatientId: patient.patientId)
//                        }
//                        
//                        // Previously Visited Doctors Section
//                        VStack(alignment: .leading, spacing: 16) {
//                            sectionHeader(
//                                title: "Previously Visited Doctors",
//                                hasContent: !viewModel.recentPrescriptions.isEmpty
//                            ) {
//                                NavigationLink(destination: AllVisitedDoctorsView(
//                                    recentPrescriptions: viewModel.recentPrescriptions,
//                                    formatDate: formatDate
//                                )) {
//                                    Text("See All")
//                                        .font(.system(size: 14, weight: .semibold))
//                                        .foregroundColor(primaryColor)
//                                }
//                            }
//                            
//                            if viewModel.recentPrescriptions.isEmpty {
//                                emptyStateView(
//                                    icon: "person.2",
//                                    title: "No Doctor Visits",
//                                    message: "Your previously visited doctors will appear here"
//                                )
//                            } else {
//                                ScrollView(.horizontal, showsIndicators: false) {
//                                    HStack(spacing: 16) {
//                                        ForEach(viewModel.recentPrescriptions) { appointment in
//                                            ImprovedDoctorCard(
//                                                name: "Dr. \(getDoctorName(for: appointment.docId))",
//                                                specialty: "General Medicine",
//                                                lastVisit: formatDate(appointment.date),
//                                                imageName: "defaultDoctorImage"
//                                            )
//                                        }
//                                    }
//                                    .padding(.vertical, 8)
//                                    .padding(.horizontal, 2)
//                                }
//                            }
//                        }
//                    }
//                    .padding(.bottom, 24)
//                }
//                .padding(.leading, 16)
//                .padding(.trailing, 8)
//            }
//            .navigationBarBackButtonHidden(true)
//            .onAppear {
//                if listener == nil {
//                    isLoading = true
//                    loadDoctorData {
//                        setupSnapshotListener()
//                    }
//                }
//            }
//            .onDisappear {
//                listener?.remove()
//                listener = nil
//            }
//            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AppointmentBooked"))) { _ in
//                listener?.remove()
//                listener = nil
//                isLoading = true
//                setupSnapshotListener()
//            }
//            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AppointmentCancelled"))) { _ in
//                listener?.remove()
//                listener = nil
//                isLoading = true
//                setupSnapshotListener()
//            }
//            .navigationDestination(isPresented: $navigateToBooking) {
//                DoctorView(patientId: patient.patientId)
//            }
//            .navigationDestination(isPresented: $navigateToNotifications) {
//                NotificationsView(
//                    upcomingSchedules: upcomingSchedules,
//                    getDoctorName: getDoctorName,
//                    getDoctorSpecialty: getDoctorSpecialty,
//                    formatDate: formatDate
//                )
//            }
//        }
//    }
//    
//    private func sectionHeader<T: View>(title: String, hasContent: Bool, @ViewBuilder action: @escaping () -> T) -> some View {
//        HStack {
//            Text(title)
//                .font(.system(size: 20, weight: .bold))
//                .foregroundColor(.black)
//            
//            Spacer()
//            
//            if hasContent {
//                action()
//            }
//        }
//    }
//    
//    private func emptyStateView(icon: String, title: String, message: String) -> some View {
//        HStack {
//            Spacer()
//            VStack(spacing: 12) {
//                Image(systemName: icon)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 36, height: 36)
//                    .foregroundColor(.gray.opacity(0.7))
//                
//                Text(title)
//                    .font(.system(size: 16, weight: .semibold))
//                    .foregroundColor(.primary)
//                
//                Text(message)
//                    .font(.system(size: 14))
//                    .foregroundColor(.secondary)
//                    .multilineTextAlignment(.center)
//            }
//            .frame(maxWidth: .infinity)
//            .padding(.vertical, 24)
//            .padding(.horizontal)
//            .background(cardBackground.opacity(0.5))
//            .cornerRadius(16)
//            Spacer()
//        }
//        .padding(.horizontal, 16)
//    }
//    
//    private func loadDoctorData(completion: @escaping () -> Void) {
//        DoctorData.fetchDoctors {
//            print("Doctor data loaded: \(DoctorData.specialties)")
//            DispatchQueue.main.async {
//                self.isLoading = true // Ensure isLoading remains true until snapshot listener completes
//                completion()
//            }
//        }
//    }
//    
//    private func setupSnapshotListener() {
//        let db = Firestore.firestore()
//        let calendar = Calendar.current
//        let now = Date()
//        let oneMonthFromNow = calendar.date(byAdding: .month, value: 1, to: now) ?? now
//
//        listener = db.collection("appointments")
//            .whereField("patientId", isEqualTo: patient.patientId)
//            .whereField("status", isEqualTo: "scheduled")
//            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: now))
//            .whereField("date", isLessThan: Timestamp(date: oneMonthFromNow))
//            .addSnapshotListener { (querySnapshot, error) in
//                DispatchQueue.main.async {
//                    defer { self.isLoading = false }
//                    if let error = error {
//                        print("Error fetching appointments: \(error.localizedDescription)")
//                        self.upcomingSchedules = []
//                        self.notificationCount = 0
//                        return
//                    }
//                    
//                    guard let querySnapshot = querySnapshot else {
//                        print("No query snapshot received")
//                        self.upcomingSchedules = []
//                        self.notificationCount = 0
//                        return
//                    }
//                    
//                    var schedules: [Appointment] = []
//                    for change in querySnapshot.documentChanges {
//                        let documentData = change.document.data()
//                        
//                        guard let apptId = documentData["apptId"] as? String,
//                              let patientId = documentData["patientId"] as? String,
//                              let description = documentData["description"] as? String,
//                              let docId = documentData["docId"] as? String,
//                              let status = documentData["status"] as? String,
//                              let billingStatus = documentData["billingStatus"] as? String,
//                              let amount = documentData["amount"] as? Double,
//                              let date = (documentData["date"] as? Timestamp)?.dateValue(),
//                              let doctorsNotes = documentData["doctorsNotes"] as? String,
//                              let prescriptionId = documentData["prescriptionId"] as? String,
//                              let followUpRequired = documentData["followUpRequired"] as? Bool else {
//                            print("Missing or invalid fields in document: \(change.document.documentID)")
//                            continue
//                        }
//                        
//                        let followUpDate = (documentData["followUpDate"] as? Timestamp)?.dateValue()
//                        
//                        let appointment = Appointment(
//                            id: apptId,
//                            apptId: apptId,
//                            patientId: patientId,
//                            description: description,
//                            docId: docId,
//                            status: status,
//                            billingStatus: billingStatus,
//                            amount: amount,
//                            date: date,
//                            doctorsNotes: doctorsNotes,
//                            prescriptionId: prescriptionId,
//                            followUpRequired: followUpRequired,
//                            followUpDate: followUpDate
//                        )
//                        
//                        if change.type == .added || change.type == .modified {
//                            if !schedules.contains(where: { $0.id == appointment.id }) {
//                                schedules.append(appointment)
//                            }
//                        }
//                    }
//                    
//                    // Replace the documentIds check with this:
//                    let documentIds = querySnapshot.documents.map { $0.documentID }
//                    self.upcomingSchedules.removeAll { !documentIds.contains($0.id) }
//                    
//                    self.upcomingSchedules = schedules.sorted { ($0.date ?? Date.distantPast) < ($1.date ?? Date.distantPast) }
//                    
//                    // Calculate notification count for appointments within 0–48 hours
//                    self.notificationCount = self.upcomingSchedules.filter { appointment in
//                        guard let date = appointment.date else { return false }
//                        let hoursDifference = Calendar.current.dateComponents([.hour], from: now, to: date).hour ?? 0
//                        return hoursDifference >= 0 && hoursDifference <= 48
//                    }.count
//                    
//                    print("Updated upcomingSchedules: \(self.upcomingSchedules.count), notificationCount: \(self.notificationCount), isLoading: \(self.isLoading)")
//                }
//            }
//    }
//
//    private func getDoctorName(for docId: String) -> String {
//        for specialty in DoctorData.doctors.keys {
//            if let doctor = DoctorData.doctors[specialty]?.first(where: { $0.id == docId }) {
//                return doctor.doctor_name
//            }
//        }
//        return "Unknown Doctor"
//    }
//    
//    private func getDoctorSpecialty(for docId: String) -> String {
//        for specialty in DoctorData.doctors.keys {
//            if DoctorData.doctors[specialty]?.contains(where: { $0.id == docId }) ?? false {
//                return specialty
//            }
//        }
//        return "Unknown Specialty"
//    }
//    
//    private func formatDate(_ date: Date?) -> String {
//        guard let date = date else { return "No date" }
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .short
//        return formatter.string(from: date)
//    }
//    
//    private func formatDateTime(_ date: Date?) -> (date: String, time: String) {
//        guard let date = date else { return ("No date", "No time") }
//        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "EEE, d MMM yyyy"
//        let dateStr = dateFormatter.string(from: date)
//        
//        dateFormatter.dateFormat = "h:mm a"
//        let timeStr = dateFormatter.string(from: date)
//        
//        return (dateStr, timeStr)
//    }
//}
//
//// MARK: - NotificationsView
//struct NotificationsView: View {
//    let upcomingSchedules: [Appointment]
//    let getDoctorName: (String) -> String
//    let getDoctorSpecialty: (String) -> String
//    let formatDate: (Date?) -> String
//    private let primaryColor = Color(red: 0.43, green: 0.34, blue: 0.99)
//    private let backgroundColor = Color(red: 0.94, green: 0.94, blue: 1.0)
//    
//    @State private var selectedAppointmentForDetails: Appointment?
//
//    var body: some View {
//        ZStack {
//            backgroundColor
//                .ignoresSafeArea()
//            
//            ScrollView {
//                let upcomingIn24to48Hours = upcomingSchedules.filter { appointment in
//                    guard let date = appointment.date else { return false }
//                    let now = Date()
//                    let hoursDifference = Calendar.current.dateComponents([.hour], from: now, to: date).hour ?? 0
//                    return hoursDifference >= 0 && hoursDifference <= 48
//                }
//                
//                VStack(spacing: 20) {
//                    if upcomingIn24to48Hours.isEmpty {
//                        VStack(spacing: 12) {
//                            Image(systemName: "bell.slash.fill")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 60, height: 60)
//                                .foregroundColor(.gray)
//                            Text("No Updates")
//                                .font(.title3.bold())
//                                .foregroundColor(.primary)
//                            Text("You have no new notifications.")
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                                .multilineTextAlignment(.center)
//                                .padding(.horizontal)
//                        }
//                        .padding(.vertical, 20)
//                        .accessibilityElement(children: .combine)
//                    } else {
//                        ForEach(upcomingIn24to48Hours) { appointment in
//                            NotificationCard(
//                                doctorName: getDoctorName(appointment.docId),
//                                date: formatDate(appointment.date).components(separatedBy: " at ")[0],
//                                time: formatDate(appointment.date).components(separatedBy: " at ")[1]
//                            )
//                            .padding(.horizontal, 20)
//                            .accessibilityLabel("Notification: Appointment with \(getDoctorName(appointment.docId)) on \(formatDate(appointment.date))")
//                            .onTapGesture {
//                                selectedAppointmentForDetails = appointment
//                            }
//                        }
//                    }
//                }
//                .padding(.bottom, 20)
//                .padding(.top, 20)
//            }
//        }
//        .navigationTitle("Notifications")
//        .navigationBarTitleDisplayMode(.inline)
//        .sheet(item: $selectedAppointmentForDetails) { appointment in
//            AppointmentDetailsModal(
//                appointment: appointment,
//                doctorName: getDoctorName(appointment.docId),
//                specialty: getDoctorSpecialty(appointment.docId),
//                imageName: "doctor1",
//                isPresented: Binding(
//                    get: { selectedAppointmentForDetails != nil },
//                    set: { if !$0 { selectedAppointmentForDetails = nil } }
//                )
//            )
//        }
//    }
//}
//
//// MARK: - NotificationCard
//struct NotificationCard: View {
//    let doctorName: String
//    let date: String
//    let time: String
//    
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color.white)
//                .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
//            
//            VStack(alignment: .leading, spacing: 14) {
//                HStack(spacing: 12) {
//                    Image(systemName: "bell.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 22, height: 22)
//                        .foregroundColor(.white)
//                        .padding(8)
//                        .background(Color(red: 0.43, green: 0.34, blue: 0.99))
//                        .clipShape(Circle())
//                    
//                    Text("You have an upcoming appointment with \(doctorName) at \(time)")
//                        .font(.system(size: 16, weight: .medium))
//                        .foregroundColor(.black)
//                        .lineLimit(3)
//                        .fixedSize(horizontal: false, vertical: true)
//                    
//                    Spacer()
//                }
//                HStack(spacing: 8) {
//                    Image(systemName: "calendar")
//                        .font(.system(size: 14))
//                        .foregroundColor(.black.opacity(0.6))
//                    
//                    Text(date)
//                        .font(.system(size: 15, weight: .medium))
//                        .foregroundColor(.black.opacity(0.8))
//                }
//                .padding(.horizontal, 14)
//                .padding(.vertical, 8)
//                .background(Color(red: 0.95, green: 0.95, blue: 0.98))
//                .cornerRadius(12)
//            }
//            .padding(16)
//        }
//        .frame(maxWidth: .infinity, minHeight: 100)
//    }
//}
//
//// MARK: - AllAppointmentsView
//struct AllAppointmentsView: View {
//    @Binding var upcomingSchedules: [Appointment]
//    let getDoctorName: (String) -> String
//    let getDoctorSpecialty: (String) -> String
//    let formatDate: (Date?) -> String
//    private let primaryColor = Color(red: 0.43, green: 0.34, blue: 0.99)
//    private let backgroundColor = Color(red: 0.97, green: 0.97, blue: 1.0)
//    
//    var body: some View {
//        ZStack {
//            backgroundColor
//                .edgesIgnoringSafeArea(.all)
//            
//            VStack(spacing: 16) {
//                if upcomingSchedules.isEmpty {
//                    VStack(spacing: 12) {
//                        Image(systemName: "calendar")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 60, height: 60)
//                            .foregroundColor(.gray.opacity(0.7))
//                        
//                        Text("No Upcoming Appointments")
//                            .font(.system(size: 18, weight: .semibold))
//                            .foregroundColor(.primary)
//                        
//                        Text("You don't have any scheduled appointments")
//                            .font(.system(size: 14))
//                            .foregroundColor(.secondary)
//                            .multilineTextAlignment(.center)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 100)
//                    .padding(.horizontal)
//                } else {
//                    ScrollView {
//                        VStack(spacing: 16) {
//                            ForEach($upcomingSchedules) { $appointment in
//                                AppointmentListCard(
//                                    doctorName: getDoctorName(appointment.docId),
//                                    specialty: getDoctorSpecialty(appointment.docId),
//                                    date: formatDate(appointment.date),
//                                    imageName: "doctor1",
//                                    appointment: $appointment
//                                )
//                                .padding(.horizontal, 20)
//                            }
//                        }
//                        .padding(.bottom, 20)
//                    }
//                }
//            }
//            .padding(.top, 20)
//        }
//        .navigationTitle("Upcoming Appointments")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//    
//    private func formatDateTime(_ date: Date?) -> (date: String, time: String) {
//        guard let date = date else { return ("No date", "No time") }
//        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "EEE, d MMM yyyy"
//        let dateStr = dateFormatter.string(from: date)
//        
//        dateFormatter.dateFormat = "h:mm a"
//        let timeStr = dateFormatter.string(from: date)
//        
//        return (dateStr, timeStr)
//    }
//}
//
//// MARK: - AppointmentListCard
//struct AppointmentListCard: View {
//    let doctorName: String
//    let specialty: String
//    let date: String
//    let imageName: String
//    @Binding var appointment: Appointment
//    @State private var showDetails = false
//    private let primaryColor = Color(red: 0.43, green: 0.34, blue: 0.99)
//    
//    var body: some View {
//        Button(action: {
//            showDetails = true
//        }) {
//            ZStack {
//                RoundedRectangle(cornerRadius: 16)
//                    .fill(Color.white)
//                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
//                
//                HStack(spacing: 16) {
//                    Group {
//                        if UIImage(named: imageName) != nil {
//                            Image(imageName)
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: 64, height: 64)
//                                .clipShape(Circle())
//                                .overlay(Circle().stroke(Color.white, lineWidth: 1))
//                        } else {
//                            Image(systemName: "person.crop.circle.fill")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 64, height: 64)
//                                .foregroundColor(primaryColor)
//                        }
//                    }
//                    
//                    VStack(alignment: .leading, spacing: 6) {
//                        Text(doctorName)
//                            .font(.system(size: 16, weight: .bold))
//                            .foregroundColor(.primary)
//                        
//                        Text(specialty)
//                            .font(.system(size: 14))
//                            .foregroundColor(.secondary)
//                        
//                        Text(date)
//                            .font(.system(size: 12))
//                            .foregroundColor(.gray)
//                    }
//                    
//                    Spacer()
//                    
//                    Image(systemName: "chevron.right")
//                        .foregroundColor(.gray)
//                        .font(.system(size: 16))
//                }
//                .padding(16)
//            }
//            .frame(maxWidth: .infinity)
//        }
//        .buttonStyle(PlainButtonStyle())
//        .sheet(isPresented: $showDetails) {
//            AppointmentDetailsModal(
//                appointment: appointment,
//                doctorName: doctorName,
//                specialty: specialty,
//                imageName: imageName,
//                isPresented: $showDetails
//            )
//        }
//        .accessibilityLabel("Appointment with \(doctorName) for \(specialty), on \(date)")
//    }
//}
//
//// MARK: - AllPrescriptionsView
//struct AllPrescriptionsView: View {
//    let prescriptions: [Appointment]
//    let formatDate: (Date?) -> String
//    private let primaryColor = Color(red: 0.43, green: 0.34, blue: 0.99)
//    
//    var body: some View {
//        ZStack {
//            Color(.systemBackground)
//                .ignoresSafeArea()
//            
//            ScrollView {
//                VStack(spacing: 16) {
//                    if prescriptions.isEmpty {
//                        VStack(spacing: 12) {
//                            Image(systemName: "doc.text.fill")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 60, height: 60)
//                                .foregroundColor(.secondary)
//                            Text("No Prescriptions Available")
//                                .font(.title3.bold())
//                                .foregroundColor(.primary)
//                            Text("Your prescriptions and reports will appear here once added.")
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                                .multilineTextAlignment(.center)
//                                .padding(.horizontal)
//                        }
//                        .padding(.vertical, 20)
//                        .accessibilityElement(children: .combine)
//                    } else {
//                        ForEach(prescriptions) { appointment in
//                            NavigationLink(
//                                destination: prescriptionDestination(for: appointment),
//                                label: {
//                                    ImprovedMedicalRecordCard(
//                                        type: appointment.status,
//                                        doctorName: "Dr. \(getDoctorName(for: appointment.docId))",
//                                        date: formatDate(appointment.date),
//                                        title: appointment.description
//                                    )
//                                    .padding(.horizontal, 20)
//                                    .accessibilityLabel("Prescription: \(appointment.description) by Dr. \(getDoctorName(for: appointment.docId)), dated \(formatDate(appointment.date))")
//                                }
//                            )
//                            .buttonStyle(.plain)
//                        }
//                    }
//                }
//                .padding(.top, 20)
//                .padding(.bottom, 20)
//            }
//        }
//        .navigationTitle("All Prescriptions")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//    
//    private func prescriptionDestination(for appointment: Appointment) -> some View {
//        Group {
//            if let prescriptionIdStr = appointment.prescriptionId,
//               let prescriptionUrl = URL(string: prescriptionIdStr) {
//                PDFKitView(url: prescriptionUrl)
//            } else {
//                VStack {
//                    Text("Unable to Load Prescription")
//                        .font(.headline)
//                        .foregroundColor(.primary)
//                    Text("The document is not available.")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                }
//            }
//        }
//    }
//    
//    private func getDoctorName(for docId: String) -> String {
//        for specialty in DoctorData.doctors.keys {
//            if let doctor = DoctorData.doctors[specialty]?.first(where: { $0.id == docId }) {
//                return doctor.doctor_name
//            }
//        }
//        return "Unknown Doctor"
//    }
//}
//
//// MARK: - AllVisitedDoctorsView
//struct AllVisitedDoctorsView: View {
//    let recentPrescriptions: [Appointment]
//    let formatDate: (Date?) -> String
//    private let primaryColor = Color(red: 0.43, green: 0.34, blue: 0.99)
//    private let backgroundColor = Color(red: 0.97, green: 0.97, blue: 1.0)
//    
//    var body: some View {
//        ZStack {
//            backgroundColor
//                .edgesIgnoringSafeArea(.all)
//            
//            ScrollView {
//                VStack(spacing: 16) {
//                    if recentPrescriptions.isEmpty {
//                        VStack(spacing: 12) {
//                            Image(systemName: "person.2.fill")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 60, height: 60)
//                                .foregroundColor(.gray.opacity(0.7))
//                            
//                            Text("No Doctor Visits")
//                                .font(.system(size: 18, weight: .semibold))
//                            .foregroundColor(.primary)
//                            
//                            Text("Your previously visited doctors will appear here")
//                                .font(.system(size: 14))
//                                .foregroundColor(.secondary)
//                                .multilineTextAlignment(.center)
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 100)
//                        .padding(.horizontal)
//                    } else {
//                        VStack(spacing: 16) {
//                            ForEach(recentPrescriptions, id: \.apptId) { appointment in
//                                ImprovedDoctorCard(
//                                    name: "Dr. \(getDoctorName(for: appointment.docId))",
//                                    specialty: "General Medicine",
//                                    lastVisit: formatDate(appointment.date),
//                                    imageName: "defaultDoctorImage"
//                                )
//                                .padding(.horizontal, 20)
//                            }
//                        }
//                        .padding(.bottom, 20)
//                    }
//                }
//                .padding(.top, 20)
//            }
//        }
//        .navigationTitle("Visited Doctors")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//    
//    private func getDoctorName(for docId: String) -> String {
//        for specialty in DoctorData.doctors.keys {
//            if let doctor = DoctorData.doctors[specialty]?.first(where: { $0.id == docId }) {
//                return doctor.doctor_name
//            }
//        }
//        return "Unknown Doctor"
//    }
//}
//
//// MARK: - ImprovedAppointmentCard
//struct ImprovedAppointmentCard: View {
//    let doctorName: String
//    let specialty: String
//    let date: String
//    let time: String
//    let imageName: String
//    @Binding var appointment: Appointment
//    @State private var showDetails = false
//    private let primaryColor = Color(red: 0.51, green: 0.44, blue: 0.87)
//    
//    var body: some View {
//        Button(action: {
//            showDetails = true
//        }) {
//            ZStack {
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(primaryColor)
//                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
//                
//                VStack(alignment: .leading, spacing: 12) {
//                    HStack(spacing: 12) {
//                        Group {
//                            if UIImage(named: imageName) != nil {
//                                Image(imageName)
//                                    .resizable()
//                                    .scaledToFill()
//                                    .frame(width: 50, height: 50)
//                                    .clipShape(Circle())
//                                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
//                            } else {
//                                Image(systemName: "person.crop.circle.fill")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 50, height: 50)
//                                    .foregroundColor(.white)
//                            }
//                        }
//                        
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text(doctorName)
//                                .font(.system(size: 18, weight: .semibold))
//                                .foregroundColor(.white)
//                            
//                            Text(specialty)
//                                .font(.system(size: 14, weight: .regular))
//                                .foregroundColor(.white.opacity(0.9))
//                        }
//                        
//                        Spacer()
//                    }
//                    
//                    HStack {
//                        HStack(spacing: 6) {
//                            HStack(spacing: 6) {
//                                Image(systemName: "calendar")
//                                    .foregroundColor(.white)
//                                    .font(.system(size: 14))
//                                
//                                Text(date)
//                                    .font(.system(size: 14, weight: .medium))
//                                    .foregroundColor(.white)
//                            }
//                            .padding(.vertical, 8)
//                            .padding(.leading, 12)
//                            .padding(.trailing, 6)
//                            
//                            Rectangle()
//                                .frame(width: 1, height: 20)
//                                .foregroundColor(.white.opacity(0.3))
//                                .padding(.horizontal, 4)
//                            
//                            HStack(spacing: 6) {
//                                Image(systemName: "clock")
//                                    .foregroundColor(.white)
//                                    .font(.system(size: 14))
//                                
//                                Text(time)
//                                    .font(.system(size: 14, weight: .medium))
//                                    .foregroundColor(.white)
//                            }
//                            .padding(.vertical, 8)
//                            .padding(.leading, 6)
//                            .padding(.trailing, 12)
//                        }
//                        .background(Color.white.opacity(0.2))
//                        .cornerRadius(16)
//                        
//                        Spacer()
//                    }
//                }
//                .padding(16)
//            }
//        }
//        .buttonStyle(PlainButtonStyle())
//        .frame(height: 130)
//        .sheet(isPresented: $showDetails) {
//            AppointmentDetailsModal(
//                appointment: appointment,
//                doctorName: doctorName,
//                specialty: specialty,
//                imageName: imageName,
//                isPresented: $showDetails
//            )
//        }
//        .accessibilityLabel("Appointment with \(doctorName) for \(specialty), on \(date) at \(time)")
//    }
//}
//
//// MARK: - ImprovedMedicalRecordCard
//struct ImprovedMedicalRecordCard: View {
//    let type: String
//    let doctorName: String
//    let date: String
//    let title: String
//    private let primaryColor = Color(red: 0.43, green: 0.34, blue: 0.99)
//    
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color.white)
//                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
//            
//            HStack(spacing: 16) {
//                ZStack {
//                    Circle()
//                        .fill(primaryColor.opacity(0.1))
//                        .frame(width: 48, height: 48)
//                    
//                    Image(systemName: "doc.text.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 22, height: 22)
//                        .foregroundColor(primaryColor)
//                }
//                
//                VStack(alignment: .leading, spacing: 6) {
//                    Text(title)
//                        .font(.system(size: 16, weight: .bold))
//                        .foregroundColor(.primary)
//                        .lineLimit(1)
//                    
//                    Text(doctorName)
//                        .font(.system(size: 14))
//                        .foregroundColor(.secondary)
//                        .lineLimit(1)
//                    
//                    Text(date)
//                        .font(.system(size: 12))
//                        .foregroundColor(.secondary)
//                }
//                
//                Spacer()
//                
//                Image(systemName: "chevron.right")
//                    .foregroundColor(.secondary)
//                    .font(.system(size: 14))
//            }
//            .padding(16)
//        }
//        .frame(maxWidth: .infinity)
//        .accessibilityLabel("\(title) by \(doctorName), dated \(date)")
//    }
//}
//
//// MARK: - ImprovedDoctorCard
//struct ImprovedDoctorCard: View {
//    let name: String
//    let specialty: String
//    let lastVisit: String
//    let imageName: String
//    private let primaryColor = Color(red: 0.43, green: 0.34, blue: 0.99)
//    
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color.white)
//                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
//            
//            HStack(spacing: 16) {
//                Image(imageName)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 64, height: 64)
//                    .clipShape(Circle())
//                    .overlay(Circle().stroke(primaryColor, lineWidth: 2))
//                
//                VStack(alignment: .leading, spacing: 6) {
//                    Text(name)
//                        .font(.system(size: 16, weight: .bold))
//                        .foregroundColor(.primary)
//                    
//                    Text(specialty)
//                        .font(.system(size: 14))
//                        .foregroundColor(.secondary)
//                    
//                    Text("Last Visit: \(lastVisit)")
//                        .font(.system(size: 12))
//                        .foregroundColor(.gray)
//                }
//                
//                Spacer()
//                
//                Button(action: {}) {
//                    ZStack {
//                        Circle()
//                            .fill(primaryColor.opacity(0.1))
//                            .frame(width: 40, height: 40)
//                        
//                        Image(systemName: "phone.fill")
//                            .foregroundColor(primaryColor)
//                            .font(.system(size: 16))
//                    }
//                }
//                .accessibilityLabel("Call \(name)")
//            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 12)
//        }
//        .frame(maxWidth: .infinity)
//    }
//}

import SwiftUI
import FirebaseFirestore

// MARK: - Models
struct Notification: Identifiable {
    let id: String
    let title: String
    let message: String
    let date: Date
    let appointmentId: String?
    let type: String
}
struct HomeView_patient: View {
    let patient: PatientF
    @Environment(\.colorScheme) var colorScheme
    private let primaryColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    private let secondaryColor = Color(red: 0.55, green: 0.48, blue: 0.99)
    private let backgroundColor = Color(red: 0.97, green: 0.97, blue: 1.0)
    private let cardBackground = Color.white
    @State private var upcomingSchedules: [Appointment] = []
    @State private var isLoading = true
    @State private var navigateToBooking = false
    @State private var navigateToNotifications = false
    @State private var listener: ListenerRegistration?
    @State private var notificationCount: Int = 0
    @State private var hasViewedNotifications: Bool = UserDefaults.standard.bool(forKey: "hasViewedNotifications") ?? false
    @State private var lastNotificationViewTime: Date? = UserDefaults.standard.object(forKey: "lastNotificationViewTime") as? Date
    @StateObject private var viewModel = AppointmentViewModel()
    private let forNowColor = Color(red: 0.51, green: 0.44, blue: 0.87)

    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Hello, \(patient.userData.Name)")
                                    .font(FontSizeManager.font(for: 28, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Text("Welcome to CareHub")
                                    .font(FontSizeManager.font(for: 16, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                navigateToNotifications = true
                                hasViewedNotifications = true
                                lastNotificationViewTime = Date()
                                UserDefaults.standard.set(true, forKey: "hasViewedNotifications")
                                UserDefaults.standard.set(lastNotificationViewTime, forKey: "lastNotificationViewTime")
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(cardBackground)
                                        .frame(width: 44, height: 44)
                                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(primaryColor)
                                        .font(.system(size: FontSizeManager.fontSize(for: 18)))
                                    
                                    if notificationCount > 0 {
                                        ZStack {
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 20, height: 20)
                                            Text("\(notificationCount)")
                                                .font(FontSizeManager.font(for: 12, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                        .offset(x: 12, y: -12)
                                    }
                                }
                            }
                            .accessibilityLabel("Notifications, \(notificationCount) new")
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Book Appointment Card
                        Button(action: {
                            navigateToBooking = true
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [forNowColor, secondaryColor]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .shadow(color: primaryColor.opacity(0.2), radius: 10, x: 0, y: 5)
                                
                                HStack(spacing: 16) {
                                    Image(systemName: "calendar.badge.plus")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.white)
                                        .padding(.leading, 16)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Book an Appointment")
                                            .font(FontSizeManager.font(for: 18, weight: .bold))
                                            .foregroundColor(.white)
                                        
                                        Text("Schedule with your preferred doctor")
                                            .font(FontSizeManager.font(for: 14, weight: .medium))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white)
                                        .font(.system(size: FontSizeManager.fontSize(for: 18)))
                                        .padding(.trailing, 16)
                                }
                                .padding(.vertical, 16)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 16)
                        .padding(.bottom, 10)
                        
                        // Upcoming Appointments Section
                        VStack(alignment: .leading, spacing: 16) {
                            sectionHeader(
                                title: "Upcoming Appointments",
                                hasContent: !upcomingSchedules.isEmpty
                            ) {
                                NavigationLink(destination: AllAppointmentsView(
                                    upcomingSchedules: $upcomingSchedules,
                                    getDoctorName: getDoctorName,
                                    getDoctorSpecialty: getDoctorSpecialty,
                                    formatDate: formatDate
                                )) {
                                    Text("See All")
                                        .font(FontSizeManager.font(for: 14, weight: .semibold))
                                        .foregroundColor(primaryColor)
                                }
                            }
                            
                            if isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .padding()
                                    Spacer()
                                }
                            } else if upcomingSchedules.isEmpty {
                                emptyStateView(
                                    icon: "calendar",
                                    title: "No Upcoming Appointments",
                                    message: "You don't have any scheduled appointments"
                                )
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach($upcomingSchedules) { $appointment in
                                            ImprovedAppointmentCard(
                                                doctorName: getDoctorName(for: appointment.docId),
                                                specialty: getDoctorSpecialty(for: appointment.docId),
                                                date: formatDateTime(appointment.date ?? Date()).date,
                                                time: formatDateTime(appointment.date ?? Date()).time,
                                                imageName: "doctor1",
                                                appointment: $appointment
                                            )
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 2)
                                }
                            }
                        }
                        
                        // Recent Prescriptions Section
                        VStack(alignment: .leading, spacing: 16) {
                            sectionHeader(
                                title: "Recent Prescriptions & Reports",
                                hasContent: !viewModel.recentPrescriptions.isEmpty
                            ) {
                                NavigationLink(destination: AllPrescriptionsView(
                                    prescriptions: viewModel.recentPrescriptions,
                                    formatDate: formatDate
                                )) {
                                    Text("See All")
                                        .font(FontSizeManager.font(for: 14, weight: .semibold))
                                        .foregroundColor(primaryColor)
                                }
                            }
                            
                            if viewModel.recentPrescriptions.isEmpty {
                                emptyStateView(
                                    icon: "doc.text",
                                    title: "No Recent Prescriptions",
                                    message: "Your prescriptions will appear here"
                                )
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(viewModel.recentPrescriptions) { appointment in
                                            NavigationLink(
                                                destination: {
                                                    if let prescriptionIdStr = appointment.prescriptionId,
                                                       let prescriptionUrl = URL(string: prescriptionIdStr) {
                                                        PDFKitView(url: prescriptionUrl)
                                                    } else {
                                                        PDFKitView(url: URL(string: "https://example.com")!)
                                                    }
                                                },
                                                label: {
                                                    ImprovedMedicalRecordCard(
                                                        type: appointment.status,
                                                        doctorName: "\(getDoctorName(for: appointment.docId))",
                                                        date: formatDate(appointment.date),
                                                        title: appointment.description
                                                    )
                                                }
                                            )
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 2)
                                }
                            }
                        }
                        .onAppear {
                            viewModel.fetchRecentPrescriptions(forPatientId: patient.patientId)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            sectionHeader(
                                title: "Previously Visited Doctors",
                                hasContent: !viewModel.recentPrescriptions.isEmpty
                            ) {
                                NavigationLink(destination: AllVisitedDoctorsView(
                                    recentPrescriptions: viewModel.recentPrescriptions,
                                    formatDate: formatDate
                                )) {
                                    Text("See All")
                                        .font(FontSizeManager.font(for: 14, weight: .semibold))
                                        .foregroundColor(primaryColor)
                                }
                            }
                            
                            if viewModel.recentPrescriptions.isEmpty {
                                emptyStateView(
                                    icon: "person.2",
                                    title: "No Doctor Visits",
                                    message: "Your previously visited doctors will appear here"
                                )
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(viewModel.recentPrescriptions) { appointment in
                                            ImprovedDoctorCard(
                                                name: " \(getDoctorName(for: appointment.docId))",
                                                specialty: "General Medicine",
                                                lastVisit: formatDate(appointment.date),
                                                imageName: "defaultDoctorImage"
                                            )
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 2)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 24)
                }
                .padding(.leading, 16)
                .padding(.trailing, 8)
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                if listener == nil {
                    isLoading = true
                    loadDoctorData {
                        setupSnapshotListener()
                    }
                }
            }
            .onDisappear {
                listener?.remove()
                listener = nil
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AppointmentBooked"))) { _ in
                listener?.remove()
                listener = nil
                isLoading = true
                setupSnapshotListener()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AppointmentCancelled"))) { _ in
                listener?.remove()
                listener = nil
                isLoading = true
                setupSnapshotListener()
            }
            .navigationDestination(isPresented: $navigateToBooking) {
                DoctorView(patientId: patient.patientId)
            }
            .navigationDestination(isPresented: $navigateToNotifications) {
                NotificationsView(
                    upcomingSchedules: upcomingSchedules,
                    getDoctorName: getDoctorName,
                    getDoctorSpecialty: getDoctorSpecialty,
                    formatDate: formatDate
                )
            }
        }
    }
    
    private func sectionHeader<T: View>(title: String, hasContent: Bool, @ViewBuilder action: @escaping () -> T) -> some View {
        HStack {
            Text(title)
                .font(FontSizeManager.font(for: 20, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
            
            if hasContent {
                action()
            }
        }
    }
    
    private func emptyStateView(icon: String, title: String, message: String) -> some View {
        HStack {
            Spacer()
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .foregroundColor(.gray.opacity(0.7))
                    .font(.system(size: FontSizeManager.fontSize(for: 36)))
                
                Text(title)
                    .font(FontSizeManager.font(for: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(FontSizeManager.font(for: 14, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal)
            .background(cardBackground.opacity(0.5))
            .cornerRadius(16)
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    private func loadDoctorData(completion: @escaping () -> Void) {
        DoctorData.fetchDoctors {
            print("Doctor data loaded: \(DoctorData.specialties)")
            completion()
        }
    }
    
    private func setupSnapshotListener() {
        let db = Firestore.firestore()
        let calendar = Calendar.current
        let now = Date()
        let oneMonthFromNow = calendar.date(byAdding: .month, value: 1, to: now) ?? now

        listener = db.collection("appointments")
            .whereField("patientId", isEqualTo: patient.patientId)
            .whereField("status", isEqualTo: "scheduled")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: now))
            .whereField("date", isLessThan: Timestamp(date: oneMonthFromNow))
            .addSnapshotListener { [self] (querySnapshot, error) in
                if let error = error {
                    print("Error fetching appointments: \(error.localizedDescription)")
                    isLoading = false
                    return
                }
                
                var schedules: [Appointment] = []
                for change in querySnapshot?.documentChanges ?? [] {
                    let documentData = change.document.data()
                    
                    if let apptId = documentData["apptId"] as? String,
                       let patientId = documentData["patientId"] as? String,
                       let description = documentData["description"] as? String,
                       let docId = documentData["docId"] as? String,
                       let status = documentData["status"] as? String,
                       let billingStatus = documentData["billingStatus"] as? String,
                       let amount = documentData["amount"] as? Double,
                       let date = (documentData["date"] as? Timestamp)?.dateValue(),
                       let doctorsNotes = documentData["doctorsNotes"] as? String,
                       let prescriptionId = documentData["prescriptionId"] as? String,
                       let followUpRequired = documentData["followUpRequired"] as? Bool,
                       let followUpDate = (documentData["followUpDate"] as? Timestamp)?.dateValue() {

                        let appointment = Appointment(
                            id: apptId,
                            apptId: apptId,
                            patientId: patientId,
                            description: description,
                            docId: docId,
                            status: status,
                            billingStatus: billingStatus,
                            amount: amount,
                            date: date,
                            doctorsNotes: doctorsNotes,
                            prescriptionId: prescriptionId,
                            followUpRequired: followUpRequired,
                            followUpDate: followUpDate
                        )

                        if change.type == .added || change.type == .modified {
                            if !schedules.contains(where: { $0.id == appointment.id }) {
                                schedules.append(appointment)
                            }
                        }
                    } else {
                        print("Missing or invalid fields in document: \(change.document.documentID)")
                    }
                }

                if let documentIds = querySnapshot?.documents.map({ $0.documentID }) {
                    upcomingSchedules.removeAll { !documentIds.contains($0.id) }
                }
                
                upcomingSchedules = schedules.sorted { ($0.date ?? Date.distantPast) < ($1.date ?? Date.distantPast) }
                
                // Calculate notification count for appointments within 0–48 hours
                let appointmentsWithin48Hours = upcomingSchedules.filter { appointment in
                    guard let date = appointment.date else { return false }
                    let hoursDifference = Calendar.current.dateComponents([.hour], from: now, to: date).hour ?? 0
                    return hoursDifference >= 0 && hoursDifference <= 48
                }
                
                if hasViewedNotifications, let lastViewTime = lastNotificationViewTime {
                    // Only count appointments that are scheduled after the last notification view
                    notificationCount = appointmentsWithin48Hours.filter { appointment in
                        guard let date = appointment.date else { return false }
                        return date > lastViewTime
                    }.count
                } else {
                    // If notifications haven't been viewed, show all appointments within 48 hours
                    notificationCount = appointmentsWithin48Hours.count
                }
                
                isLoading = false
                print("Updated upcomingSchedules: \(upcomingSchedules.count), notificationCount: \(notificationCount), isLoading: \(isLoading)")
            }
    }

    private func getDoctorName(for docId: String) -> String {
        for specialty in DoctorData.doctors.keys {
            if let doctor = DoctorData.doctors[specialty]?.first(where: { $0.id == docId }) {
                return doctor.doctor_name
            }
        }
        return "Unknown Doctor"
    }
    
    private func getDoctorSpecialty(for docId: String) -> String {
        for specialty in DoctorData.doctors.keys {
            if DoctorData.doctors[specialty]?.contains(where: { $0.id == docId }) ?? false {
                return specialty
            }
        }
        return "Unknown Specialty"
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "No date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDateTime(_ date: Date?) -> (date: String, time: String) {
        guard let date = date else { return ("No date", "No time") }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, d MMM yyyy"
        let dateStr = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "h:mm a"
        let timeStr = dateFormatter.string(from: date)
        
        return (dateStr, timeStr)
    }
}

// MARK: - NotificationsView
struct NotificationsView: View {
    let upcomingSchedules: [Appointment]
    let getDoctorName: (String) -> String
    let getDoctorSpecialty: (String) -> String
    let formatDate: (Date?) -> String
    private let primaryColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    private let backgroundColor = Color(red: 0.94, green: 0.94, blue: 1.0)
    
    @State private var selectedAppointmentForDetails: Appointment?

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                let upcomingIn24to48Hours = upcomingSchedules.filter { appointment in
                    guard let date = appointment.date else { return false }
                    let now = Date()
                    let hoursDifference = Calendar.current.dateComponents([.hour], from: now, to: date).hour ?? 0
                    return hoursDifference >= 0 && hoursDifference <= 48
                }
                
                VStack(spacing: 20) {
                    if upcomingIn24to48Hours.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "bell.slash.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                                .font(.system(size: FontSizeManager.fontSize(for: 60)))
                            Text("No Updates")
                                .font(FontSizeManager.font(for: 20, weight: .bold))
                                .foregroundColor(.primary)
                            Text("You have no new notifications.")
                                .font(FontSizeManager.font(for: 16, weight: .regular))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 20)
                        .accessibilityElement(children: .combine)
                    } else {
                        ForEach(upcomingIn24to48Hours) { appointment in
                            NotificationCard(
                                doctorName: getDoctorName(appointment.docId),
                                date: formatDate(appointment.date).components(separatedBy: " at ")[0],
                                time: formatDate(appointment.date).components(separatedBy: " at ")[1]
                            )
                            .padding(.horizontal, 20)
                            .accessibilityLabel("Notification: Appointment with \(getDoctorName(appointment.docId)) on \(formatDate(appointment.date))")
                            .onTapGesture {
                                selectedAppointmentForDetails = appointment
                            }
                        }
                    }
                }
                .padding(.bottom, 20)
                .padding(.top, 20)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedAppointmentForDetails) { appointment in
            AppointmentDetailsModal(
                appointment: appointment,
                doctorName: getDoctorName(appointment.docId),
                specialty: getDoctorSpecialty(appointment.docId),
                imageName: "doctor1",
                isPresented: Binding(
                    get: { selectedAppointmentForDetails != nil },
                    set: { if !$0 { selectedAppointmentForDetails = nil } }
                )
            )
        }
    }
}

// MARK: - NotificationCard
struct NotificationCard: View {
    let doctorName: String
    let date: String
    let time: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Image(systemName: "bell.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color(red: 0.43, green: 0.34, blue: 0.99))
                        .clipShape(Circle())
                    
                    Text("You have an upcoming appointment with \(doctorName) at \(time)")
                        .font(FontSizeManager.font(for: 16, weight: .medium))
                        .foregroundColor(.black)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: FontSizeManager.fontSize(for: 14)))
                        .foregroundColor(.black.opacity(0.6))
                    
                    Text(date)
                        .font(FontSizeManager.font(for: 15, weight: .medium))
                        .foregroundColor(.black.opacity(0.8))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(red: 0.95, green: 0.95, blue: 0.98))
                .cornerRadius(12)
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
    }
}

// MARK: - AllAppointmentsView
struct AllAppointmentsView: View {
    @Binding var upcomingSchedules: [Appointment]
    let getDoctorName: (String) -> String
    let getDoctorSpecialty: (String) -> String
    let formatDate: (Date?) -> String
    private let primaryColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    private let backgroundColor = Color(red: 0.97, green: 0.97, blue: 1.0)
    
    var body: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                if upcomingSchedules.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray.opacity(0.7))
                            .font(.system(size: FontSizeManager.fontSize(for: 60)))
                        
                        Text("No Upcoming Appointments")
                            .font(FontSizeManager.font(for: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("You don't have any scheduled appointments")
                            .font(FontSizeManager.font(for: 14, weight: .regular))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 100)
                    .padding(.horizontal)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach($upcomingSchedules) { $appointment in
                                AppointmentListCard(
                                    doctorName: getDoctorName(appointment.docId),
                                    specialty: getDoctorSpecialty(appointment.docId),
                                    date: formatDate(appointment.date),
                                    imageName: "doctor1",
                                    appointment: $appointment
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .padding(.top, 20)
        }
        .navigationTitle("Upcoming Appointments")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatDateTime(_ date: Date?) -> (date: String, time: String) {
        guard let date = date else { return ("No date", "No time") }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, d MMM yyyy"
        let dateStr = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "h:mm a"
        let timeStr = dateFormatter.string(from: date)
        
        return (dateStr, timeStr)
    }
}

// MARK: - AppointmentListCard
struct AppointmentListCard: View {
    let doctorName: String
    let specialty: String
    let date: String
    let imageName: String
    @Binding var appointment: Appointment
    @State private var showDetails = false
    private let primaryColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    
    var body: some View {
        Button(action: {
            showDetails = true
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                
                HStack(spacing: 16) {
                    Group {
                        if UIImage(named: imageName) != nil {
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 1))
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 64, height: 64)
                                .foregroundColor(primaryColor)
                                .font(.system(size: FontSizeManager.fontSize(for: 64)))
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(doctorName)
                            .font(FontSizeManager.font(for: 16, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(specialty)
                            .font(FontSizeManager.font(for: 14, weight: .regular))
                            .foregroundColor(.secondary)
                        
                        Text(date)
                            .font(FontSizeManager.font(for: 12, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.system(size: FontSizeManager.fontSize(for: 16)))
                }
                .padding(16)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetails) {
            AppointmentDetailsModal(
                appointment: appointment,
                doctorName: doctorName,
                specialty: specialty,
                imageName: imageName,
                isPresented: $showDetails
            )
        }
        .accessibilityLabel("Appointment with \(doctorName) for \(specialty), on \(date)")
    }
}
struct AllPrescriptionsView: View {
    let prescriptions: [Appointment]
    let formatDate: (Date?) -> String
    private let primaryColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    if prescriptions.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.secondary)
                                .font(.system(size: FontSizeManager.fontSize(for: 60)))
                            Text("No Prescriptions Available")
                                .font(FontSizeManager.font(for: 20, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Your prescriptions and reports will appear here once added.")
                                .font(FontSizeManager.font(for: 16, weight: .regular))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 20)
                        .accessibilityElement(children: .combine)
                    } else {
                        ForEach(prescriptions) { appointment in
                            NavigationLink(
                                destination: prescriptionDestination(for: appointment),
                                label: {
                                    ImprovedMedicalRecordCard(
                                        type: appointment.status,
                                        doctorName: "\(getDoctorName(for: appointment.docId))",
                                        date: formatDate(appointment.date),
                                        title: appointment.description
                                    )
                                    .padding(.horizontal, 20)
                                    .accessibilityLabel("Prescription: \(appointment.description) by \(getDoctorName(for: appointment.docId)), dated \(formatDate(appointment.date))")
                                }
                            )
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("All Prescriptions")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func prescriptionDestination(for appointment: Appointment) -> some View {
        Group {
            if let prescriptionIdStr = appointment.prescriptionId,
               let prescriptionUrl = URL(string: prescriptionIdStr) {
                PDFKitView(url: prescriptionUrl)
            } else {
                VStack {
                    Text("Unable to Load Prescription")
                        .font(FontSizeManager.font(for: 18, weight: .bold))
                        .foregroundColor(.primary)
                    Text("The document is not available.")
                        .font(FontSizeManager.font(for: 16, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func getDoctorName(for docId: String) -> String {
        for specialty in DoctorData.doctors.keys {
            if let doctor = DoctorData.doctors[specialty]?.first(where: { $0.id == docId }) {
                return doctor.doctor_name
            }
        }
        return "Unknown Doctor"
    }
}
// MARK: - ImprovedAppointmentCard
struct ImprovedAppointmentCard: View {
    let doctorName: String
    let specialty: String
    let date: String
    let time: String
    let imageName: String
    @Binding var appointment: Appointment
    @State private var showDetails = false
    private let primaryColor = Color(red: 0.51, green: 0.44, blue: 0.87)
    
    var body: some View {
        Button(action: {
            showDetails = true
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(primaryColor)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Group {
                            if UIImage(named: imageName) != nil {
                                Image(imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                                    .font(.system(size: FontSizeManager.fontSize(for: 50)))
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(doctorName)
                                .font(FontSizeManager.font(for: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text(specialty)
                                .font(FontSizeManager.font(for: 14, weight: .regular))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        HStack(spacing: 6) {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .foregroundColor(.white)
                                    .font(.system(size: FontSizeManager.fontSize(for: 14)))
                                
                                Text(date)
                                    .font(FontSizeManager.font(for: 14, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 8)
                            .padding(.leading, 12)
                            .padding(.trailing, 6)
                            
                            Rectangle()
                                .frame(width: 1, height: 20)
                                .foregroundColor(.white.opacity(0.3))
                                .padding(.horizontal, 4)
                            
                            HStack(spacing: 6) {
                                Image(systemName: "clock")
                                    .foregroundColor(.white)
                                    .font(.system(size: FontSizeManager.fontSize(for: 14)))
                                
                                Text(time)
                                    .font(FontSizeManager.font(for: 14, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 8)
                            .padding(.leading, 6)
                            .padding(.trailing, 12)
                        }
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(16)
                        
                        Spacer()
                    }
                }
                .padding(16)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(height: 130)
        .sheet(isPresented: $showDetails) {
            AppointmentDetailsModal(
                appointment: appointment,
                doctorName: doctorName,
                specialty: specialty,
                imageName: imageName,
                isPresented: $showDetails
            )
        }
        .accessibilityLabel("Appointment with \(doctorName) for \(specialty), on \(date) at \(time)")
    }
}

// MARK: - ImprovedMedicalRecordCard
struct ImprovedMedicalRecordCard: View {
    let type: String
    let doctorName: String
    let date: String
    let title: String
    private let primaryColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(primaryColor.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "doc.text.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundColor(primaryColor)
                        .font(.system(size: FontSizeManager.fontSize(for: 22)))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(FontSizeManager.font(for: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(doctorName)
                        .font(FontSizeManager.font(for: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Text(date)
                        .font(FontSizeManager.font(for: 12, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.system(size: FontSizeManager.fontSize(for: 14)))
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel("\(title) by \(doctorName), dated \(date)")
    }
}

struct DoctorVisit: Identifiable {
    let id: String 
    let name: String
    let specialty: String
    let lastVisit: Date
}

struct ImprovedDoctorCard: View {
    let name: String
    let specialty: String
    let lastVisit: String
    let imageName: String
    private let primaryColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .frame(width: 64, height: 64)
                        .foregroundColor(.clear)
                        .overlay(Circle().stroke(primaryColor, lineWidth: 2))
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 40)) // Reduced size of the icon
                        .foregroundColor(primaryColor)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(name)
                        .font(FontSizeManager.font(for: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(specialty)
                        .font(FontSizeManager.font(for: 14, weight: .regular))
                        .foregroundColor(.secondary)
                    
                    Text("Last Visit: \(lastVisit)")
                        .font(FontSizeManager.font(for: 12, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(primaryColor.opacity(0.1))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "phone.fill")
                            .foregroundColor(primaryColor)
                            .font(.system(size: FontSizeManager.fontSize(for: 16)))
                    }
                }
                .accessibilityLabel("Call \(name)")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity)
    }
}
// MARK: - AllVisitedDoctorsView
struct AllVisitedDoctorsView: View {
    let recentPrescriptions: [Appointment]
    let formatDate: (Date?) -> String
    private let primaryColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    private let backgroundColor = Color(red: 0.97, green: 0.97, blue: 1.0)
    
    var body: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                let uniqueDoctors = getUniqueDoctors()
                VStack(spacing: 16) {
                    if uniqueDoctors.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "person.2.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray.opacity(0.7))
                                .font(.system(size: FontSizeManager.fontSize(for: 60)))
                            
                            Text("No Doctor Visits")
                                .font(FontSizeManager.font(for: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Your previously visited doctors will appear here")
                                .font(FontSizeManager.font(for: 14, weight: .regular))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 100)
                        .padding(.horizontal)
                    } else {
                        VStack(spacing: 16) {
                            ForEach(uniqueDoctors) { doctor in
                                ImprovedDoctorCard(
                                    name: " \(doctor.name)",
                                    specialty: doctor.specialty,
                                    lastVisit: formatDate(doctor.lastVisit),
                                    imageName: "defaultDoctorImage"
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle("Visited Doctors")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func getDoctorName(for docId: String) -> String {
        for specialty in DoctorData.doctors.keys {
            if let doctor = DoctorData.doctors[specialty]?.first(where: { $0.id == docId }) {
                return doctor.doctor_name
            }
        }
        return "Unknown Doctor"
    }
    
    private func getDoctorSpecialty(for docId: String) -> String {
        for specialty in DoctorData.doctors.keys {
            if DoctorData.doctors[specialty]?.contains(where: { $0.id == docId }) ?? false {
                return specialty
            }
        }
        return "Unknown Specialty"
    }
    
    private func getUniqueDoctors() -> [DoctorVisit] {
        var doctorMap: [String: DoctorVisit] = [:]
        
        for appointment in recentPrescriptions {
            let docId = appointment.docId
            let doctorName = getDoctorName(for: docId)
            let specialty = getDoctorSpecialty(for: docId)
            let visitDate = appointment.date ?? Date.distantPast
            
            if let existing = doctorMap[docId] {
                if visitDate > existing.lastVisit {
                    doctorMap[docId] = DoctorVisit(id: docId, name: doctorName, specialty: specialty, lastVisit: visitDate)
                }
            } else {
                doctorMap[docId] = DoctorVisit(id: docId, name: doctorName, specialty: specialty, lastVisit: visitDate)
            }
        }
        
        return doctorMap.values.sorted { $0.lastVisit > $1.lastVisit }
    }
}
