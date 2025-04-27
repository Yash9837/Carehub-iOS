import SwiftUI
import FirebaseFirestore

struct HomeView_patient: View {
    let patient: PatientF
    @Environment(\.colorScheme) var colorScheme
    let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    @State private var upcomingSchedules: [Appointment] = []
    @State private var isLoading = true
    @State private var navigateToBooking = false
    
    let recentPrescriptions = [
        (type: "Prescription", doctorName: "Dr. Kenny Adeola", date: "Nov 15, 2023", title: "Blood Test Results"),
        (type: "Report", doctorName: "Dr. Rasheed Idris", date: "Nov 10, 2023", title: "CT Scan Report"),
        (type: "Prescription", doctorName: "Dr. Taiwo", date: "Nov 5, 2023", title: "Antibiotics")
    ]
    
    let previouslyVisitedDoctors = [
        (name: "Dr. Kenny Adeola", specialty: "General Practitioner", lastVisit: "Nov 15, 2023", imageName: "doctor2"),
        (name: "Dr. Taiwo", specialty: "General Practitioner", lastVisit: "Oct 28, 2023", imageName: "doctor3"),
        (name: "Dr. Johnson", specialty: "Pediatrician", lastVisit: "Oct 10, 2023", imageName: "doctor4")
    ]
    
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
                                
                                Button(action: {}) {
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
                                        ForEach(upcomingSchedules) { appointment in
                                            AppointmentCard(
                                                doctorName: appointment.description,
                                                specialty: "",
                                                date: formatDate(appointment.date ?? Date()),
                                                imageName: "doctor1"
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
                                
                                Button(action: {}) {
                                    Text("See All")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(purpleColor)
                                }
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(recentPrescriptions, id: \.title) { item in
                                        MedicalRecordCard(
                                            type: item.type,
                                            doctorName: item.doctorName,
                                            date: item.date,
                                            title: item.title
                                        )
                                    }
                                }
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
                                
                                Button(action: {}) {
                                    Text("See All")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(purpleColor)
                                }
                            }
                            
                            VStack(spacing: 12) {
                                ForEach(previouslyVisitedDoctors, id: \.name) { doctor in
                                    PreviouslyVisitedDoctorCard(
                                        name: doctor.name,
                                        specialty: doctor.specialty,
                                        lastVisit: doctor.lastVisit,
                                        imageName: doctor.imageName
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
                fetchUpcomingAppointments()
            }
            .navigationDestination(isPresented: $navigateToBooking) {
                ScheduleAppointmentView(patientId: patient.patientId)
            }
        }
    }
    
    private func fetchUpcomingAppointments() {
        let db = Firestore.firestore()
        let calendar = Calendar.current
        let now = Date()
        let oneMonthFromNow = calendar.date(byAdding: .month, value: 1, to: now) ?? now
        
        db.collection("appointments")
            .whereField("patientId", isEqualTo: patient.patientId)
            .whereField("status", isEqualTo: "scheduled")
            .whereField("date", isGreaterThanOrEqualTo: now)
            .whereField("date", isLessThan: oneMonthFromNow)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching appointments: \(error.localizedDescription)")
                    isLoading = false
                    return
                }
                
                var schedules: [Appointment] = []
                for document in querySnapshot?.documents ?? [] {
                    print("Document data: \(document.data())")
                    if let apptId = document.data()["apptId"] as? String,
                       let patientId = document.data()["patientId"] as? String,
                       let description = document.data()["description"] as? String,
                       let docId = document.data()["docId"] as? String,
                       let status = document.data()["status"] as? String,
                       let billingStatus = document.data()["billingStatus"] as? String,
                       let amount = document.data()["amount"] as? Double,
                       let date = (document.data()["date"] as? Timestamp)?.dateValue(),
                       let doctorsNotes = document.data()["doctorsNotes"] as? String,
                       let prescriptionId = document.data()["prescriptionId"] as? String,
                       let followUpRequired = document.data()["followUpRequired"] as? Bool,
                       let followUpDate = (document.data()["followUpDate"] as? Timestamp)?.dateValue() {
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
                        schedules.append(appointment)
                    } else {
                        print("Missing or invalid fields in document: \(document.documentID)")
                    }
                }
                print("Fetched schedules: \(schedules)")
                upcomingSchedules = schedules.sorted { ($0.date ?? Date.distantPast) < ($1.date ?? Date.distantPast) }
                isLoading = false
                print("Updated upcomingSchedules: \(upcomingSchedules), isLoading: \(isLoading)")
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

// Define PreviouslyVisitedDoctorCard
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

// Existing subviews (unchanged)
struct AppointmentCard: View {
    let doctorName: String
    let specialty: String
    let date: String
    let imageName: String
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
                Group {
                    if UIImage(named: imageName) != nil {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
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
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [purpleColor, Color(red: 0.55, green: 0.48, blue: 0.99)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 60, height: 60)
                        .shadow(color: purpleColor.opacity(0.2), radius: 5, x: 0, y: 3)
                    
                    Image(systemName: "doc.text.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 35)
                        .foregroundColor(.white)
                }
                
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

