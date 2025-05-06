import SwiftUI
import FirebaseFirestore

// MARK: - HomeView_patient
struct HomeView_patient: View {
    let patient: PatientF
    @Environment(\.colorScheme) var colorScheme
    let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    @State private var upcomingSchedules: [Appointment] = []
    @State private var isLoading = true
    @State private var navigateToBooking = false
    @State private var showNotifications = false
    @State private var listener: ListenerRegistration?
    @StateObject private var viewModel = AppointmentViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.94, green: 0.94, blue: 1.0)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hello, \(patient.userData.Name)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Text("How are you feeling today?")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showNotifications = true
                            }) {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(purpleColor)
                                    .font(.system(size: 20))
                                    .frame(width: 40, height: 40)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                        
                        // Book Appointment Card
                        Button(action: {
                            navigateToBooking = true
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [purpleColor, Color(red: 0.55, green: 0.48, blue: 0.99)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .shadow(color: purpleColor.opacity(0.2), radius: 10, x: 0, y: 5)
                                
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
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Upcoming Appointments Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Upcoming Appointment")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                NavigationLink(destination: AllAppointmentsView(upcomingSchedules: $upcomingSchedules, getDoctorName: getDoctorName, getDoctorSpecialty: getDoctorSpecialty, formatDate: formatDate)) {
                                    Text("See All")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(purpleColor)
                                }
                            }
                            
                            if isLoading {
                                ProgressView()
                                    .padding()
                            } else if upcomingSchedules.isEmpty {
                                Text("No upcoming appointments.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach($upcomingSchedules) { $appointment in
                                            AppointmentCard(
                                                doctorName: getDoctorName(for: appointment.docId),
                                                specialty: getDoctorSpecialty(for: appointment.docId),
                                                date: formatDate(appointment.date ?? Date()),
                                                imageName: "doctor1",
                                                appointment: $appointment
                                            )
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        
                        // Recent Prescriptions & Reports Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Recent Prescriptions & Reports")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                NavigationLink(destination: AllPrescriptionsView(prescriptions: viewModel.recentPrescriptions, formatDate: formatDate)) {
                                    Text("See All")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(purpleColor)
                                }
                            }
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(viewModel.recentPrescriptions) { appointment in
                                        NavigationLink(
                                            destination: {
                                                if let prescriptionIdStr = appointment.prescriptionId,
                                                   let prescriptionUrl = URL(string: prescriptionIdStr) {
                                                    PDFKitView(url: prescriptionUrl)
                                                } else {
                                                    PDFKitView(url: URL(string: "default_url")!)
                                                }
                                            },
                                            label: {
                                                MedicalRecordCard(
                                                    type: appointment.status,
                                                    doctorName: "Dr. \(appointment.docId)",
                                                    date: formatDate(appointment.date),
                                                    title: appointment.description
                                                )
                                            }
                                        )
                                    }
                                }
                                .padding()
                            }
                            .onAppear {
                                viewModel.fetchRecentPrescriptions(forPatientId: patient.patientId)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        
                        // Previously Visited Doctors Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Previously Visited Doctors")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                NavigationLink(destination: AllVisitedDoctorsView(recentPrescriptions: viewModel.recentPrescriptions, formatDate: formatDate)) {
                                    Text("See All")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(purpleColor)
                                }
                            }
                            VStack(spacing: 12) {
                                ForEach(viewModel.recentPrescriptions) { appointment in
                                    PreviouslyVisitedDoctorCard(
                                        name: "Dr. \(appointment.docId)",
                                        specialty: "General Medicine",
                                        lastVisit: formatDate(appointment.date),
                                        imageName: "defaultDoctorImage"
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
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
            .sheet(isPresented: $showNotifications) {
                NotificationView(upcomingSchedules: upcomingSchedules, getDoctorName: getDoctorName, getDoctorSpecialty: getDoctorSpecialty, formatDate: formatDate)
            }
        }
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
                
                isLoading = false
                print("Updated upcomingSchedules: \(upcomingSchedules.count), isLoading: \(isLoading)")
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
}

// MARK: - AllAppointmentsView
struct AllAppointmentsView: View {
    @Binding var upcomingSchedules: [Appointment]
    let getDoctorName: (String) -> String
    let getDoctorSpecialty: (String) -> String
    let formatDate: (Date?) -> String
    let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if upcomingSchedules.isEmpty {
                    Text("No upcoming appointments.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach($upcomingSchedules) { $appointment in
                        AppointmentCard(
                            doctorName: getDoctorName(appointment.docId),
                            specialty: getDoctorSpecialty(appointment.docId),
                            date: formatDate(appointment.date),
                            imageName: "doctor1",
                            appointment: $appointment
                        )
                    }
                }
            }
            .padding()
        }
        .navigationTitle("All Appointments")
        .background(Color(red: 0.94, green: 0.94, blue: 1.0))
    }
}

// MARK: - AllPrescriptionsView
struct AllPrescriptionsView: View {
    let prescriptions: [Appointment]
    let formatDate: (Date?) -> String
    let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if prescriptions.isEmpty {
                    Text("No prescriptions or reports available.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(prescriptions) { appointment in
                        NavigationLink(
                            destination: {
                                if let prescriptionIdStr = appointment.prescriptionId,
                                   let prescriptionUrl = URL(string: prescriptionIdStr) {
                                    PDFKitView(url: prescriptionUrl)
                                } else {
                                    PDFKitView(url: URL(string: "default_url")!)
                                }
                            },
                            label: {
                                MedicalRecordCard(
                                    type: appointment.status,
                                    doctorName: "Dr. \(appointment.docId)",
                                    date: formatDate(appointment.date),
                                    title: appointment.description
                                )
                            }
                        )
                    }
                }
            }
            .padding()
        }
        .navigationTitle("All Prescriptions & Reports")
        .background(Color(red: 0.94, green: 0.94, blue: 1.0))
    }
}

// MARK: - AllVisitedDoctorsView
struct AllVisitedDoctorsView: View {
    let recentPrescriptions: [Appointment]
    let formatDate: (Date?) -> String
    let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if recentPrescriptions.isEmpty {
                    Text("No previously visited doctors.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(recentPrescriptions, id: \.apptId) { appointment in
                        PreviouslyVisitedDoctorCard(
                            name: "Dr. \(appointment.docId)",
                            specialty: "General Medicine",
                            lastVisit: formatDate(appointment.date),
                            imageName: "defaultDoctorImage"
                        )
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Previously Visited Doctors")
        .background(Color(red: 0.94, green: 0.94, blue: 1.0))
    }
}

// MARK: - NotificationView
struct NotificationView: View {
    let upcomingSchedules: [Appointment]
    let getDoctorName: (String) -> String
    let getDoctorSpecialty: (String) -> String
    let formatDate: (Date?) -> String
    let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    let upcomingIn24to48Hours = upcomingSchedules.filter { appointment in
                        guard let date = appointment.date else { return false }
                        let now = Date()
                        let hoursDifference = Calendar.current.dateComponents([.hour], from: now, to: date).hour ?? 0
                        return hoursDifference >= 24 && hoursDifference <= 48
                    }
                    
                    if upcomingIn24to48Hours.isEmpty {
                        Text("No appointments in the next 24-48 hours.")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(upcomingIn24to48Hours) { appointment in
                            AppointmentCard(
                                doctorName: getDoctorName(appointment.docId),
                                specialty: getDoctorSpecialty(appointment.docId),
                                date: formatDate(appointment.date),
                                imageName: "doctor1",
                                appointment: .constant(appointment)
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Upcoming Notifications")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .background(Color(red: 0.94, green: 0.94, blue: 1.0))
        }
    }
}

// MARK: - PreviouslyVisitedDoctorCard
struct PreviouslyVisitedDoctorCard: View {
    let name: String
    let specialty: String
    let lastVisit: String
    let imageName: String
    let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    
    var body: some View {
        HStack(spacing: 16) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(Circle().stroke(purpleColor, lineWidth: 2))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                
                Text(specialty)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Text("Last Visit: \(lastVisit)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "phone.fill")
                    .foregroundColor(purpleColor)
                    .font(.system(size: 18))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}

// MARK: - AppointmentCard
struct AppointmentCard: View {
    let doctorName: String
    let specialty: String
    let date: String
    let imageName: String
    @Binding var appointment: Appointment
    let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
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

struct MedicalRecordCard: View {
    let type: String
    let doctorName: String
    let date: String
    let title: String
    let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)

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
                Image(systemName: "doc.text.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 35)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("by \(doctorName)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(date)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
            }
            .padding(16)
        }
        .frame(width: 250, height: 100)
    }
}
