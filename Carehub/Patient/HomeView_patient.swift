import SwiftUI
import FirebaseFirestore

struct HomeView_patient: View {
    let patient: PatientF
    @Environment(\.colorScheme) private var colorScheme
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    @State private var upcomingSchedules: [(doctorName: String, specialty: String, date: Date, imageName: String)] = []
    @State private var isLoading = true
    @State private var navigateToBooking = false
    private let currentPatientId = "PT001"
    
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
                                        ForEach(upcomingSchedules, id: \.doctorName) { schedule in
                                            AppointmentCard(
                                                doctorName: schedule.doctorName,
                                                specialty: schedule.specialty,
                                                date: formatDate(schedule.date),
                                                imageName: schedule.imageName
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
                ScheduleAppointmentView()
            }
        }
    }
    
    private func fetchUpcomingAppointments() {
        let db = Firestore.firestore()
        let calendar = Calendar.current
        let now = Date()
        let oneMonthFromNow = calendar.date(byAdding: .month, value: 1, to: now) ?? now
        
        db.collection("appointments")
            .whereField("patientId", isEqualTo: currentPatientId)
            .whereField("Date", isGreaterThanOrEqualTo: now)
            .whereField("Date", isLessThan: oneMonthFromNow)
            .whereField("Status", isEqualTo: "scheduled")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching appointments: \(error.localizedDescription)")
                    isLoading = false
                    upcomingSchedules = [
                        (doctorName: "Dr. Smith", specialty: "Cardiologist", date: Date(), imageName: "doctor1")
                    ]
                    return
                }
                
                var schedules: [(doctorName: String, specialty: String, date: Date, imageName: String)] = []
                for document in querySnapshot?.documents ?? [] {
                    if let doctorName = document.data()["doctorName"] as? String,
                       let specialty = document.data()["specialty"] as? String,
                       let date = (document.data()["Date"] as? Timestamp)?.dateValue(),
                       let imageName = document.data()["imageName"] as? String {
                        schedules.append((doctorName: doctorName, specialty: specialty, date: date, imageName: imageName))
                    }
                }
                upcomingSchedules = schedules.sorted { $0.date < $1.date }
                isLoading = false
            }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct AppointmentCard: View {
    let doctorName: String
    let specialty: String
    let date: String
    let imageName: String
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    
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
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)

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

struct PreviouslyVisitedDoctorCard: View {
    let name: String
    let specialty: String
    let lastVisit: String
    let imageName: String
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    
    var body: some View {
        HStack(spacing: 16) {
            Group {
                if UIImage(named: imageName) != nil {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .foregroundColor(purpleColor)
                        .clipShape(Circle())
                }
            }
            .overlay(
                Circle()
                    .stroke(LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.43, green: 0.34, blue: 0.99),
                            Color(red: 0.55, green: 0.48, blue: 0.99)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ), lineWidth: 2)
            )
            .shadow(color: purpleColor.opacity(0.2), radius: 5, x: 0, y: 3)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(specialty)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(purpleColor)
                        .font(.system(size: 12))
                    
                    Text("Last visit: \(lastVisit)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("Book")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(purpleColor)
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    let samplePatient = PatientF(
        emergencyContact: [],
        medicalRecords: [],
        testResults: [],
        userData: UserData(
            Address: "123 Main St",
            Dob: "01/01/1998",
            Email: "vansh@example.com",
            Name: "Vansh Patel",
            Password: "hashedpassword",
            aadharNo: "123456789012",
            phoneNo: "9876543210"
        ),
        vitals: Vitals(
            allergies: [],
            bp: [],
            heartRate: [],
            height: [],
            temperature: [],
            weight: []
        ),
        lastModified: Date(),
        patientId: "P123456",
        username: "vansh123"
    )
    HomeView_patient(patient: samplePatient)
}
