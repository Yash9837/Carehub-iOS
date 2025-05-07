import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct DoctorsNote: Identifiable {
    let id = UUID()
    let appointmentID: String
    let note: String
    let patientID: String
}

struct Qualification {
    let degree: String
    let institution: String
    let years: String
    let description: String
}

// MARK: - ProfileView_doc
struct ProfileView_doc: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var doctor: Doctor? = nil
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var doctorId: String = ""
    @State private var showLogoutAlert = false
    @State private var logoutErrorMessage: String?
    @State private var isLoggedOut = false
    @State private var patientCount: Int = 0
    @State private var appointments: [Appointment] = [] // New state for appointments
    private let purpleColor = Color(hex: "6D57FC")
    private let lightPurple = Color(hex: "6D57FC").opacity(0.05)
    private let mediumPurple = Color(hex: "6D57FC").opacity(0.7)
    private let darkPurple = Color(hex: "4A3FC7")
    private let backgroundColor = Color(hex: "F6F7FF")

    private let db = Firestore.firestore()

    // Computed properties for monthly summary
    private var currentMonthAppointments: [Appointment] {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        return appointments.filter { appointment in
            guard let date = appointment.date else { return false }
            let appointmentMonth = calendar.component(.month, from: date)
            let appointmentYear = calendar.component(.year, from: date)
            return appointmentMonth == currentMonth && appointmentYear == currentYear
        }
    }

    private var totalAppointments: Int {
        currentMonthAppointments.count
    }

    private var completedAppointments: Int {
        currentMonthAppointments.filter { $0.status.lowercased() == "completed" }.count
    }

    private var upcomingAppointments: Int {
        currentMonthAppointments.filter { appointment in
            guard let date = appointment.date else { return false }
            return appointment.status.lowercased() == "scheduled" && date > Date()
        }.count
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let doctor = doctor {
                        ProfileHeaderView(doctor: doctor, purpleColor: purpleColor, darkPurple: darkPurple)
                            .padding(.bottom, -5)
                        
                        DoctorIDCardView(doctor: doctor, purpleColor: purpleColor)
                            .padding(.bottom, 5)
                            
                        StatsView(doctor: doctor, purpleColor: purpleColor, patientCount: patientCount)
                            .padding(.bottom, 5)
                            
                        MonthlySummaryView(
                            totalAppointments: totalAppointments,
                            completedAppointments: completedAppointments,
                            upcomingAppointments: upcomingAppointments,
                            purpleColor: purpleColor,
                            lightPurple: lightPurple
                        ) // Pass dynamic values
                            .padding(.bottom, 5)
                        
                        // Doctor's Notes section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Doctor's Notes")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .padding(.top, 5)

                            if doctor.doctorsNotes?.isEmpty ?? true {
                                Text("No notes available.")
                                    .font(.system(size: 15, weight: .regular, design: .rounded))
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 5)
                            } else {
                                ForEach(doctor.doctorsNotes ?? [], id: \.id) { note in
                                    NavigationLink(
                                        destination: NotesView(appointment: Appointment(
                                            id: note.appointmentID,
                                            apptId: note.appointmentID,
                                            patientId: note.patientID,
                                            description: "",
                                            docId: doctor.id,
                                            status: "scheduled",
                                            billingStatus: "unpaid",
                                            amount: 0.0,
                                            date: Date(),
                                            doctorsNotes: note.note,
                                            prescriptionId: nil,
                                            followUpRequired: false,
                                            followUpDate: nil
                                        ))
                                    ) {
                                        NoteCard(note: note, color: purpleColor)
                                    }
                                }
                            }
                            
                            Spacer(minLength: 20)
                            
                            Button(action: {
                                authManager.logout()
                                isLoggedOut = true
                            }) {
                                Text("Logout")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .padding(.top, 5)
                        }
                        .padding(.vertical, 5)

                        Spacer()
                            .frame(height: 80)
                    } else if let errorMessage = errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding(.horizontal, 20)
            }
            .background(backgroundColor)
            .edgesIgnoringSafeArea(.bottom)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchDoctorData()
            }
            .onReceive(authManager.$currentStaffMember) { newStaff in
                fetchDoctorData()
            }
            .alert(isPresented: $showLogoutAlert) {
                Alert(
                    title: Text("Logout Failed"),
                    message: Text(logoutErrorMessage ?? "An error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .fullScreenCover(isPresented: $isLoggedOut) {
            LoginView() // Replace with your actual login view
        }
    }

    private func fetchDoctorData() {
        isLoading = true
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No UID available to fetch doctor data - user might not be logged in")
            doctorId = ""
            doctor = nil
            isLoading = false
            errorMessage = "User not logged in"
            isLoggedOut = true
            return
        }

        print("Fetching doctor data for UID: \(uid)")
        db.collection("doctors").document(uid).getDocument { snapshot, error in
            defer { isLoading = false }
            if let error = error {
                print("Error fetching doctor from UID: \(error.localizedDescription)")
                doctorId = ""
                doctor = nil
                errorMessage = error.localizedDescription
                return
            }

            guard let document = snapshot, document.exists, let data = document.data() else {
                print("No document found for UID: \(uid) in doctors collection")
                doctorId = ""
                doctor = nil
                errorMessage = "Doctor data not found"
                return
            }

            guard let docId = data["Doctorid"] as? String else {
                print("Missing Doctorid in document data: \(data)")
                doctorId = ""
                doctor = nil
                errorMessage = "Doctor ID not found"
                return
            }

            doctorId = docId

            let experience = data["Doctor_experience"] as? Double ?? Double(data["Doctor_experience"] as? Int ?? 0)
            let doctorData = Doctor(
                id: data["Doctorid"] as? String ?? "",
                department: data["Filed_name"] as? String ?? "",
                doctor_name: data["Doctor_name"] as? String ?? "",
                doctor_experience: Int(experience),
                email: data["Email"] as? String,
                imageURL: data["ImageURL"] as? String,
                password: data["Password"] as? String,
                consultationFee: Int(data["consultationFee"] as? Double ?? 0.0),
                license_number: data["license_number"] as? String,
                phoneNo: data["phoneNo"] as? String,
                doctorsNotes: nil
            )
            self.doctor = doctorData

            // Fetch doctor's notes dynamically
            DoctorData.fetchDoctorNotes(forDoctorId: doctorId) { notes in
                if var updatedDoctor = self.doctor {
                    updatedDoctor.doctorsNotes = notes.isEmpty ? nil : notes
                    self.doctor = updatedDoctor
                }
            }

            // Fetch patient count
            fetchPatientCount()

            // Fetch appointments for monthly summary
            fetchAppointments()
        }
    }

    private func fetchPatientCount() {
        guard !doctorId.isEmpty else {
            patientCount = 0
            return
        }

        db.collection("appointments")
            .whereField("docId", isEqualTo: doctorId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching appointments for patient count: \(error)")
                    self.patientCount = 0
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No appointment documents found for docId: \(self.doctorId)")
                    self.patientCount = 0
                    return
                }

                let patientIds = Set(documents.compactMap { $0.data()["patientId"] as? String })
                self.patientCount = patientIds.count
                print("Fetched patient count: \(self.patientCount)")
            }
    }

    private func fetchAppointments() {
        guard !doctorId.isEmpty else {
            appointments = []
            return
        }

        db.collection("appointments")
            .whereField("docId", isEqualTo: doctorId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching appointments: \(error)")
                    self.appointments = []
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No appointment documents found for docId: \(self.doctorId)")
                    self.appointments = []
                    return
                }

                self.appointments = documents.compactMap { doc -> Appointment? in
                    let data = doc.data()
                    guard let apptId = data["apptId"] as? String,
                          let patientId = data["patientId"] as? String,
                          let docId = data["docId"] as? String,
                          let description = (data["description"] as? String) ?? (data["Description"] as? String),
                          let status = (data["status"] as? String) ?? (data["Status"] as? String) else {
                        print("Failed to map document: \(doc.documentID), missing required fields")
                        return nil
                    }

                    return Appointment(
                        id: doc.documentID,
                        apptId: apptId,
                        patientId: patientId,
                        description: description,
                        docId: docId,
                        status: status.lowercased(),
                        billingStatus: data["billingStatus"] as? String ?? "",
                        amount: data["amount"] as? Double,
                        date: (data["date"] as? Timestamp)?.dateValue(),
                        doctorsNotes: (data["doctorsNotes"] as? String) ?? (data["doctorNotes"] as? String),
                        prescriptionId: data["prescriptionId"] as? String,
                        followUpRequired: data["followUpRequired"] as? Bool,
                        followUpDate: (data["followUpDate"] as? Timestamp)?.dateValue()
                    )
                }
                print("Fetched appointments for monthly summary: \(self.appointments.count)")
            }
    }
}
struct ProfileHeaderView: View {
    let doctor: Doctor
    let purpleColor: Color
    let darkPurple: Color

    var body: some View {
       

            VStack(spacing: 15) {
                ZStack {
                    
                        Image(systemName: "person.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(purpleColor.opacity(0.7))
                }
                

                VStack(spacing: 5) {
                    Text(doctor.doctor_name)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.black)

                    Text(doctor.department)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(darkPurple)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }


struct DoctorIDCardView: View {
    let doctor: Doctor
    let purpleColor: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [purpleColor, purpleColor.opacity(0.85)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: purpleColor.opacity(0.2), radius: 10, x: 0, y: 5)

            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("DOCTOR ID")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))

                    Text(doctor.id)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                Divider()
                    .background(.white.opacity(0.4))
                    .padding(.vertical, 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text("LICENSE NUMBER")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        
                    Text(doctor.license_number ?? "N/A")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                HStack {
                    Spacer()
                    Text("Medical Council of India")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(20)
        }
        .frame(height: 180)
    }
}

struct StatsView: View {
    let doctor: Doctor
    let purpleColor: Color
    let patientCount: Int // New parameter for dynamic patient count

    var body: some View {
        HStack(spacing: 0) {
            StatView(icon: "person.2.fill", value: "\(patientCount)", label: "Patients", color: purpleColor)
            StatView(icon: "clock.fill", value: "\(doctor.doctor_experience ?? 0) Yrs", label: "Experience", color: purpleColor)
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.white)
                .shadow(color: purpleColor.opacity(0.08), radius: 10, x: 0, y: 5)
        )
    }
}

struct MonthlySummaryView: View {
    let totalAppointments: Int
    let completedAppointments: Int
    let upcomingAppointments: Int
    let purpleColor: Color
    let lightPurple: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Monthly Summary")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .padding(.bottom, -5)

            HStack(spacing: 18) {
                SummaryItem(value: "\(totalAppointments)", label: "Appointments", icon: "calendar", color: purpleColor)
                SummaryItem(value: "\(completedAppointments)", label: "Completed", icon: "checkmark.circle.fill", color: purpleColor)
                SummaryItem(value: "\(upcomingAppointments)", label: "Upcoming", icon: "clock.fill", color: purpleColor)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(lightPurple)
                .shadow(color: purpleColor.opacity(0.08), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Supporting Views
struct CardInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

struct StatView: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.08))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.black)
            Text(label)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(color.opacity(0.7))
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
    }
}

struct SummaryItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.black)
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(color.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

struct NoteCard: View {
    let note: DoctorsNote
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(color)
                    .font(.system(size: 16))
                Text("Appointment ID: \(note.appointmentID)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                Spacer()
            }
            Text("Patient ID: \(note.patientID)")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(color.opacity(0.7))
            Text(note.note)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(.black.opacity(0.65))
                .lineLimit(2)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white)
                .shadow(color: color.opacity(0.08), radius: 6, x: 0, y: 3)
        )
    }
}
