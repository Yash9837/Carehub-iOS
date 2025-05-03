import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import CryptoKit

struct Notification: Identifiable {
    let id: String
    let title: String
    let message: String
    let date: Date
    let appointmentId: String?
    let type: String // Add type to differentiate notifications (e.g., "reminder")
}

struct NotificationsView: View {
    let notifications: [Notification]
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    
    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.94, blue: 1.0)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Notifications")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        .accessibilityAddTraits(.isHeader)
                    
                    if notifications.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "bell.slash.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                            Text("No Updates")
                                .font(.title3.bold())
                                .foregroundColor(.primary)
                            Text("You have no new notifications.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 20)
                        .accessibilityElement(children: .combine)
                    } else {
                        ForEach(notifications) { notification in
                            NotificationCard(notification: notification)
                                .padding(.horizontal, 20)
                                .accessibilityLabel("Notification: \(notification.title), \(notification.message), dated \(formatDate(notification.date))")
                        }
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct NotificationCard: View {
    let notification: Notification
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    private let cancelColor = Color(red: 0.99, green: 0.34, blue: 0.34)
    private let rescheduleColor = Color(red: 0.34, green: 0.67, blue: 0.99)
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            HStack(spacing: 12) {
                Image(systemName: iconForType(notification.type))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundColor(colorForType(notification.type))
                    .padding(8)
                    .background(colorForType(notification.type).opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(notification.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(notification.message)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(formatDate(notification.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .frame(minHeight: 100)
    }
    
    private func iconForType(_ type: String) -> String {
        switch type {
        case "reminder": return "bell.fill"
        case "canceled": return "xmark.circle.fill"
        case "rescheduled": return "calendar.badge.clock"
        default: return "bell.fill"
        }
    }
    
    private func colorForType(_ type: String) -> Color {
        switch type {
        case "reminder": return purpleColor
        case "canceled": return cancelColor
        case "rescheduled": return rescheduleColor
        default: return purpleColor
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct HomeView_patient: View {
    let patient: PatientF
    @Environment(\.colorScheme) var colorScheme
    private let primaryColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    private let secondaryColor = Color(red: 0.55, green: 0.48, blue: 0.99)
    private let backgroundColor = Color(red: 0.97, green: 0.97, blue: 1.0)
    private let cardBackground = Color.white
    private let forNowColor = Color(red: 0.51, green: 0.44, blue: 0.87)

    @State private var upcomingSchedules: [Appointment] = []
    @State private var isLoading = true
    @State private var navigateToBooking = false
    @State private var navigateToNotifications = false
    @State private var listener: ListenerRegistration?
    @StateObject private var viewModel = AppointmentViewModel()
    
    @State private var notifications: [Notification] = []
    
    let previouslyVisitedDoctors = [
        (name: "Dr. Kenny Adeola", specialty: "General Practitioner", lastVisit: "Nov 15, 2023", imageName: "doctor2"),
        (name: "Dr. Taiwo", specialty: "General Practitioner", lastVisit: "Oct 28, 2023", imageName: "doctor3"),
        (name: "Dr. Johnson", specialty: "Pediatrician", lastVisit: "Oct 10, 2023", imageName: "doctor4")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerSection
                        
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
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                        
                                        Text("Schedule with your preferred doctor")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white)
                                        .font(.system(size: 18))
                                        .padding(.trailing, 16)
                                }
                                .padding(.vertical, 16)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 10)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        upcomingAppointmentsSection
                        
                        recentPrescriptionsSection
                        
                        previouslyVisitedDoctorsSection
                    }
                    .padding(.bottom, 24)
                }
                .padding(.leading, 16)
                .padding(.trailing, 8)
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                let currentPatientId = hashPatientId()
                print("HomeView_patient appeared with patient.patientId: \(patient.patientId), Hashed UID: \(currentPatientId), Firebase UID: \(Auth.auth().currentUser?.uid ?? "No UID")")
                if patient.patientId != currentPatientId {
                    print("WARNING: patient.patientId does not match hashed UID. Using hashed UID for queries.")
                }
                if listener == nil {
                    isLoading = true
                    loadDoctorData {
                        setupSnapshotListener()
                    }
                }
                fetchNotifications()
            }
            .onDisappear {
                print("HomeView_patient disappeared, removing listener")
                listener?.remove()
                listener = nil
            }
            .navigationDestination(isPresented: $navigateToBooking) {
                DoctorView()
            }
            .navigationDestination(isPresented: $navigateToNotifications) {
                NotificationsView(notifications: notifications)
            }
        }
    }
    
    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Hello, \(patient.userData.Name)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                
                Text("Welcome to CareHub")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                navigateToNotifications = true
            }) {
                ZStack {
                    Circle()
                        .fill(cardBackground)
                        .frame(width: 44, height: 44)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: "bell.fill")
                        .foregroundColor(primaryColor)
                        .font(.system(size: 18))
                }
            }
            .accessibilityLabel("Notifications")
        }
        .padding(.top, 16)
    }
    
    private var upcomingAppointmentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Upcoming Appointments", hasContent: !upcomingSchedules.isEmpty) {
                NavigationLink(destination: AllAppointmentsView(appointments: upcomingSchedules)) {
                    Text("See All")
                        .font(.system(size: 14, weight: .semibold))
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
                        ForEach(upcomingSchedules) { appointment in
                            let datetime = formatDateTime(appointment.date)
                            ImprovedAppointmentCard(
                                doctorName: getDoctorName(for: appointment.docId),
                                specialty: getDoctorSpecialty(for: appointment.docId),
                                date: datetime.date,
                                time: datetime.time,
                                imageName: "doctor1",
                                appointment: .constant(appointment)
                            )
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 2)
                }
            }
        }
    }
    
    private var recentPrescriptionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Recent Prescriptions & Reports", hasContent: !viewModel.recentPrescriptions.isEmpty) {
                NavigationLink(destination: AllPrescriptionsView(prescriptions: viewModel.recentPrescriptions)) {
                    Text("See All")
                        .font(.system(size: 14, weight: .semibold))
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
                                        doctorName: "Dr. \(getDoctorName(for: appointment.docId))",
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
            let currentPatientId = hashPatientId()
            viewModel.fetchRecentPrescriptions(forPatientId: currentPatientId)
        }
    }
    
    private var previouslyVisitedDoctorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Previously Visited Doctors", hasContent: !previouslyVisitedDoctors.isEmpty) {
                NavigationLink(destination: AllDoctorsView(doctors: previouslyVisitedDoctors)) {
                    Text("See All")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(primaryColor)
                }
            }
            
            if previouslyVisitedDoctors.isEmpty {
                emptyStateView(
                    icon: "person.2",
                    title: "No Doctor Visits",
                    message: "Your previously visited doctors will appear here"
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(previouslyVisitedDoctors, id: \.name) { doctor in
                            ImprovedDoctorCard(
                                name: doctor.name,
                                specialty: doctor.specialty,
                                lastVisit: doctor.lastVisit,
                                imageName: doctor.imageName
                            )
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 2)
                }
            }
        }
    }
    
    private func sectionHeader<T: View>(title: String, hasContent: Bool, @ViewBuilder action: @escaping () -> T) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .bold))
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
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.system(size: 14))
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
    }
    
    private func hashPatientId() -> String {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No Firebase UID found, using default patientId")
            return "unknown_user"
        }
        let inputData = Data(uid.utf8)
        let hashed = SHA256.hash(data: inputData)
        let hashedString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        return "P\(hashedString)"
    }
    
    private func fetchNotifications() {
        let currentPatientId = hashPatientId()
        print("Fetching notifications for patientId: \(currentPatientId)")
        let db = Firestore.firestore()
        db.collection("notifications")
            .whereField("patientId", isEqualTo: currentPatientId)
            .order(by: "date", descending: true)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error fetching notifications: \(error.localizedDescription)")
                    return
                }
                
                notifications = querySnapshot?.documents.compactMap { document in
                    let data = document.data()
                    guard let title = data["title"] as? String,
                          let message = data["message"] as? String,
                          let dateTimestamp = data["date"] as? Timestamp,
                          let type = data["type"] as? String else {
                        print("Invalid notification data: \(data)")
                        return nil
                    }
                    let date = dateTimestamp.dateValue()
                    let appointmentId = data["appointmentId"] as? String
                    return Notification(id: document.documentID, title: title, message: message, date: date, appointmentId: appointmentId, type: type)
                } ?? []
                print("Fetched \(notifications.count) notifications")
            }
    }
    
    private func checkAndGenerateAppointmentNotifications() {
        let currentPatientId = hashPatientId()
        let db = Firestore.firestore()
        let now = Date()
        
        print("Checking for appointment notifications at \(now)")
        
        for appointment in upcomingSchedules {
            guard let appointmentDate = appointment.date else {
                print("Skipping appointment \(appointment.id) due to missing date")
                continue
            }
            
            let timeInterval = appointmentDate.timeIntervalSince(now)
            let hoursUntilAppointment = timeInterval / 3600
            
            print("Appointment \(appointment.id) with date \(appointmentDate) is \(hoursUntilAppointment) hours away")
            
            // Check if the appointment is within the 24-48 hour window
            if hoursUntilAppointment >= 24 && hoursUntilAppointment <= 48 {
                let notificationExists = notifications.contains { notification in
                    notification.appointmentId == appointment.id && notification.type == "reminder"
                }
                
                if !notificationExists {
                    let doctorName = getDoctorName(for: appointment.docId)
                    let notificationTitle = "Upcoming Appointment Reminder"
                    let daysAway = Int(hoursUntilAppointment / 24)
                    let notificationMessage: String
                    if daysAway == 1 {
                        notificationMessage = "Your appointment with \(doctorName) is tomorrow at \(formatDateTime(appointment.date).time)."
                    } else {
                        notificationMessage = "Your appointment with \(doctorName) is in \(daysAway) days at \(formatDateTime(appointment.date).time)."
                    }
                    let notificationDate = Date()
                    
                    let notificationData: [String: Any] = [
                        "patientId": currentPatientId,
                        "title": notificationTitle,
                        "message": notificationMessage,
                        "date": Timestamp(date: notificationDate),
                        "appointmentId": appointment.id,
                        "type": "reminder"
                    ]
                    
                    db.collection("notifications").addDocument(data: notificationData) { error in
                        if let error = error {
                            print("Error adding notification: \(error.localizedDescription)")
                        } else {
                            print("Notification added for appointment \(appointment.id) at \(notificationDate)")
                        }
                    }
                } else {
                    print("Notification already exists for appointment \(appointment.id)")
                }
            } else {
                print("Appointment \(appointment.id) is not within the 24-48 hour window (\(hoursUntilAppointment) hours away)")
            }
        }
    }
    
    private func loadDoctorData(completion: @escaping () -> Void) {
        print("Loading doctor data...")
        DoctorData.fetchDoctors {
            print("Doctor data loaded: \(DoctorData.specialties)")
            completion()
        }
    }
    
    private func setupSnapshotListener() {
        let currentPatientId = hashPatientId()
        let db = Firestore.firestore()
        
        print("Setting up snapshot listener for patientId: \(currentPatientId)")
        
        listener = db.collection("appointments")
            .whereField("patientId", isEqualTo: currentPatientId)
            .whereField("status", isEqualTo: "scheduled")
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching appointments: \(error.localizedDescription)")
                    self.isLoading = false
                    return
                }
                
                guard let changes = querySnapshot?.documentChanges else {
                    print("No document changes received")
                    self.isLoading = false
                    return
                }
                
                var schedules: [Appointment] = self.upcomingSchedules
                for change in changes {
                    let documentData = change.document.data()
                    print("Processing appointment with patientId: \(documentData["patientId"] ?? "N/A")")
                    
                    guard let apptId = documentData["apptId"] as? String,
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
                          let followUpDate = (documentData["followUpDate"] as? Timestamp)?.dateValue() else {
                        print("Missing or invalid fields in document: \(change.document.documentID), data: \(documentData)")
                        continue
                    }
                    
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
                        if let index = schedules.firstIndex(where: { $0.id == appointment.id }) {
                            schedules[index] = appointment
                            print("Updated appointment: ID=\(apptId), Date=\(String(describing: date)), Doctor=\(docId)")
                        } else {
                            schedules.append(appointment)
                            print("Added appointment: ID=\(apptId), Date=\(String(describing: date)), Doctor=\(docId)")
                        }
                    } else if change.type == .removed {
                        schedules.removeAll { $0.id == appointment.id }
                        print("Removed appointment: ID=\(apptId)")
                    }
                }
                
                if let documentIds = querySnapshot?.documents.map({ $0.documentID }) {
                    schedules.removeAll { !documentIds.contains($0.id) }
                }
                
                self.upcomingSchedules = schedules.sorted { ($0.date ?? Date.distantPast) < ($1.date ?? Date.distantPast) }
                self.isLoading = false
                print("Updated upcomingSchedules: \(self.upcomingSchedules.count) appointments, isLoading: \(self.isLoading)")
                
                self.checkAndGenerateAppointmentNotifications()
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

struct ImprovedAppointmentCard: View {
    let doctorName: String
    let specialty: String
    let date: String
    let time: String
    let imageName: String
    @Binding var appointment: Appointment
    @State private var showDetails = false
    private let purpleColor = Color(red: 0.51, green: 0.44, blue: 0.87)
    
    var body: some View {
        Button(action: {
            showDetails = true
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(purpleColor)
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
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(doctorName)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text(specialty)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        HStack(spacing: 6) {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                                
                                Text(date)
                                    .font(.system(size: 14, weight: .medium))
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
                                    .font(.system(size: 14))
                                
                                Text(time)
                                    .font(.system(size: 14, weight: .medium))
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

struct AllPrescriptionsView: View {
    let prescriptions: [Appointment]
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    Text("Prescriptions & Reports")
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .accessibilityAddTraits(.isHeader)
                    
                    if prescriptions.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.secondary)
                            Text("No Prescriptions Available")
                                .font(.title3.bold())
                                .foregroundColor(.primary)
                            Text("Your prescriptions and reports will appear here once added.")
                                .font(.subheadline)
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
                                        doctorName: "Dr. \(getDoctorName(for: appointment.docId))",
                                        date: formatDate(appointment.date),
                                        title: appointment.description
                                    )
                                    .padding(.horizontal, 20)
                                    .accessibilityLabel("Prescription: \(appointment.description) by Dr. \(getDoctorName(for: appointment.docId)), dated \(formatDate(appointment.date))")
                                }
                            )
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("Prescriptions")
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
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("The document is not available.")
                        .font(.subheadline)
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
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "No date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

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
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(doctorName)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Text(date)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
            }
            .padding(16)
        }
        .frame(width: 280, height: 100)
        .accessibilityLabel("\(title) by \(doctorName), dated \(date)")
    }
}

struct AllDoctorsView: View {
    let doctors: [(name: String, specialty: String, lastVisit: String, imageName: String)]
    private let primaryColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    private let backgroundColor = Color(red: 0.97, green: 0.97, blue: 1.0)
    
    var body: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        Text("Previously Visited Doctors")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 20)
                    
                    if doctors.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "person.2.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray.opacity(0.7))
                            
                            Text("No Doctor Visits")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Your previously visited doctors will appear here")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 100)
                        .padding(.horizontal)
                    } else {
                        VStack(spacing: 16) {
                            ForEach(doctors, id: \.name) { doctor in
                                DoctorListCard(
                                    name: doctor.name,
                                    specialty: doctor.specialty,
                                    lastVisit: doctor.lastVisit,
                                    imageName: doctor.imageName
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationTitle("Visited Doctors")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DoctorListCard: View {
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
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(primaryColor, lineWidth: 2))
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(specialty)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(primaryColor)
                            .font(.system(size: 12))
                        
                        Text("Last Visit: \(lastVisit)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(primaryColor.opacity(0.1))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "phone.fill")
                            .foregroundColor(primaryColor)
                            .font(.system(size: 16))
                    }
                }
                .accessibilityLabel("Call \(name)")
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
    }
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
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(primaryColor, lineWidth: 2))
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(specialty)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text("Last Visit: \(lastVisit)")
                        .font(.system(size: 12))
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
                            .font(.system(size: 16))
                    }
                }
                .accessibilityLabel("Call \(name)")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(width: 300, height: 100)
    }
}

struct AllAppointmentsView: View {
    let appointments: [Appointment]
    private let primaryColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    private let backgroundColor = Color(red: 0.97, green: 0.97, blue: 1.0)
    
    var body: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                HStack {
                    Text("Upcoming Appointments")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.horizontal, 20)
                
                if appointments.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray.opacity(0.7))
                        
                        Text("No Upcoming Appointments")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("You don't have any scheduled appointments")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 100)
                    .padding(.horizontal)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(appointments) { appointment in
                                AppointmentListCard(
                                    doctorName: getDoctorName(for: appointment.docId),
                                    specialty: getDoctorSpecialty(for: appointment.docId),
                                    date: formatDate(appointment.date),
                                    imageName: "doctor1",
                                    appointment: .constant(appointment)
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .padding(.top, 8)
        }
        .navigationTitle("Appointments")
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
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "No date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct AppointmentListCard: View {
    let doctorName: String
    let specialty: String
    let date: String
    let imageName: String
    @Binding var appointment: Appointment
    private let primaryColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    @State private var showDetails = false
    
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
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(primaryColor, lineWidth: 2))
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(primaryColor)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(doctorName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text(specialty)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .foregroundColor(primaryColor)
                                .font(.system(size: 12))
                            
                            Text(date)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
                .padding(16)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
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
        .accessibilityLabel("Appointment with \(doctorName), \(specialty), on \(date)")
    }
}

struct ImprovedAppointmentListCard: View {
    let doctorName: String
   

 let specialty: String
    let date: String
    let imageName: String
    @Binding var appointment: Appointment
    private let primaryColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    private let secondaryColor = Color(red: 0.55, green: 0.48, blue: 0.99)
    @State private var showDetails = false
    
    var body: some View {
        Button(action: {
            showDetails = true
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [primaryColor, secondaryColor]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .shadow(color: primaryColor.opacity(0.25), radius: 8, x: 0, y: 4)
                
                HStack(spacing: 16) {
                    Group {
                        if UIImage(named: imageName) != nil {
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.white)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(doctorName)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(specialty)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .foregroundColor(.white.opacity(0.9))
                                .font(.system(size: 14))
                            
                            Text(date)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                        .padding(.trailing, 4)
                }
                .padding(16)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
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
        .accessibilityLabel("Appointment with \(doctorName), \(specialty), on \(date)")
    }
}

struct AppointmentCard: View {
    let doctorName: String
    let specialty: String
    let date: String
    let imageName: String
    @Binding var appointment: Appointment
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    @State private var showDetails = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [purpleColor, Color(red: 0.55, green: 0.48, blue: 0.99)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .shadow(color: purpleColor.opacity(0.2), radius: 10, x: 0, y: 5)
            
            HStack(spacing: 16) {
                Group {
                    if UIImage(named: imageName) != nil {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(doctorName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(specialty)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                        
                        Text(date)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
            }
            .padding(16)
        }
        .frame(width: 300, height: 120)
        .onTapGesture {
            showDetails = true
        }
        .sheet(isPresented: $showDetails) {
            AppointmentDetailsModal(
                appointment: appointment,
                doctorName: doctorName,
                specialty: specialty,
                imageName: imageName,
                isPresented: $showDetails
            )
        }
    }
}
