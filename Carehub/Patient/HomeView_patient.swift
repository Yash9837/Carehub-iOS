import SwiftUI
import FirebaseFirestore

struct HomeView_patient: View {
    let patient: PatientF
    @Environment(\.colorScheme) var colorScheme
    let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    @State private var upcomingSchedules: [Appointment] = []
    @State private var isLoading = true
    @State private var navigateToBooking = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.94, green: 0.94, blue: 1.0)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Greeting Section
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hello, \(patient.username)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Text("How are you feeling today?")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: {}) {
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
                                        ForEach(upcomingSchedules) { appointment in
                                            AppointmentCard(
                                                doctorName: getDoctorName(for: appointment.docId),
                                                specialty: getDoctorSpecialty(for: appointment.docId),
                                                date: formatDate(appointment.date ?? Date()),
                                                imageName: "doctor1",
                                                appointment: appointment
                                            )
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        
                        // Recent Prescriptions & Reports Section (Removed static data, added message)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Recent Prescriptions & Reports")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Spacer()
                            }
                            
                            Text("No prescriptions or reports available.")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .padding()
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        
                        // Previously Visited Doctors Section (Removed static data, added message)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Previously Visited Doctors")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Spacer()
                            }
                            
                            Text("No previously visited doctors available.")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .padding()
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
                loadDoctorData()
                fetchUpcomingAppointments()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AppointmentCancelled"))) { _ in
                print("Received AppointmentCancelled notification, refreshing appointments")
                fetchUpcomingAppointments()
            }
            .navigationDestination(isPresented: $navigateToBooking) {
                ScheduleAppointmentView(patientId: patient.patientId)
            }
        }
    }
    
    private func loadDoctorData() {
        DoctorData.fetchDoctors {
            print("Doctor data loaded: \(DoctorData.specialties)")
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
    
    private func fetchUpcomingAppointments() {
        let db = Firestore.firestore()
        let calendar = Calendar.current
        let now = Date()
        let oneMonthFromNow = calendar.date(byAdding: .month, value: 1, to: now) ?? now
        print("Starting to fetch appointments for patient: \(patient.patientId)")
        db.collection("appointments")
            .whereField("patientId", isEqualTo: patient.patientId)
            .whereField("status", isEqualTo: "scheduled")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: now))
            .whereField("date", isLessThan: Timestamp(date: oneMonthFromNow))
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching appointments: \(error.localizedDescription)")
                    isLoading = false
                    return
                }
                
                print("Received snapshot with \(querySnapshot?.documents.count ?? 0) documents")
                
                // Clear existing appointments before updating
                upcomingSchedules = []
                
                for document in querySnapshot?.documents ?? [] {
                    print("Processing document ID: \(document.documentID)")
                    
                    // Create appointment with required fields
                    if let patientId = document.data()["patientId"] as? String,
                       let docId = document.data()["docId"] as? String,
                       let date = (document.data()["date"] as? Timestamp)?.dateValue() {
                        
                        // Get optional fields with defaults
                        let apptId = document.data()["apptId"] as? String ?? document.documentID
                        let description = document.data()["description"] as? String ?? ""
                        let status = document.data()["status"] as? String ?? "scheduled"
                        let billingStatus = document.data()["billingStatus"] as? String ?? "pending"
                        let amount = document.data()["amount"] as? Double ?? 0.0
                        let doctorsNotes = document.data()["doctorsNotes"] as? String ?? ""
                        let prescriptionId = document.data()["prescriptionId"] as? String ?? ""
                        let followUpRequired = document.data()["followUpRequired"] as? Bool ?? false
                        let followUpDate = (document.data()["followUpDate"] as? Timestamp)?.dateValue() ?? Date.distantFuture
                        
                        let appointment = Appointment(
                            id: document.documentID,
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
                        
                        upcomingSchedules.append(appointment)
                        print("Added appointment with date: \(formatDate(date))")
                    } else {
                        print("Missing required fields in document: \(document.documentID)")
                    }
                }
                
                // Sort by date
                upcomingSchedules.sort { ($0.date ?? Date.distantPast) < ($1.date ?? Date.distantPast) }
                
                print("Updated upcomingSchedules: \(upcomingSchedules.count) appointments")
                isLoading = false
            }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "No date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
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

struct AppointmentCard: View {
    let doctorName: String
    let specialty: String
    let date: String
    let imageName: String
    let appointment: Appointment
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
