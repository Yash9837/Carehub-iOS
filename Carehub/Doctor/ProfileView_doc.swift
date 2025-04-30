import SwiftUI
import Firebase
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
    @State private var showLoginView = false
    @State private var doctorId: String = ""
    private let purpleColor = Color(hex: "6D57FC")
    private let lightPurple = Color(hex: "6D57FC").opacity(0.05)
    private let mediumPurple = Color(hex: "6D57FC").opacity(0.7)
    private let darkPurple = Color(hex: "4A3FC7")
    private let backgroundColor = Color(hex: "F6F7FF")

    private let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    if isLoading {
                        ProgressView("Loading profile...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .foregroundColor(purpleColor)
                    } else if let doctor = doctor {
                        ProfileHeaderView(doctor: doctor, purpleColor: purpleColor, darkPurple: darkPurple)
                        DoctorIDCardView(doctor: doctor, purpleColor: purpleColor)
                        StatsView(doctor: doctor, purpleColor: purpleColor)
                        MonthlySummaryView(purpleColor: purpleColor, lightPurple: lightPurple)
                        QualificationsView(purpleColor: purpleColor)
                        
                        // Doctor's Notes section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Doctor's Notes")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.black)

                            if doctor.doctorsNotes?.isEmpty ?? true {
                                Text("No notes available.")
                                    .font(.system(size: 15, weight: .regular, design: .rounded))
                                    .foregroundColor(.gray)
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
                            Button(action: {
                                showLoginView = true
                            }) {
                                Text("Logout")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 12)

                        Spacer()
                            .frame(height: 100)
                    } else if let errorMessage = errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 32)
            }
            .background(backgroundColor)
            .edgesIgnoringSafeArea(.bottom)
            .onAppear {
                fetchDoctorData()
            }
            .onReceive(authManager.$currentStaffMember) { newStaff in
                fetchDoctorData()
            }
            .fullScreenCover(isPresented: $showLoginView) {
                LoginView()
            }
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

            print("Updated doctorId to: \(docId) from Firestore")
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
        }
    }
}

// MARK: - Subviews (unchanged)
struct ProfileHeaderView: View {
    let doctor: Doctor
    let purpleColor: Color
    let darkPurple: Color

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("My Profile")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.bottom, 12)

            VStack(spacing: 20) {
                Image(doctor.imageURL ?? "placeholder")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 130, height: 130)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(purpleColor.opacity(0.2), lineWidth: 4)
                    )
                    .shadow(color: purpleColor.opacity(0.15), radius: 12, x: 0, y: 6)

                VStack(spacing: 8) {
                    Text(doctor.doctor_name)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.black)

                    Text(doctor.department)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(darkPurple)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct DoctorIDCardView: View {
    let doctor: Doctor
    let purpleColor: Color

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [purpleColor, purpleColor.opacity(0.85)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: purpleColor.opacity(0.2), radius: 12, x: 0, y: 6)

                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DOCTOR ID")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))

                        Text(doctor.id)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    Divider()
                        .background(.white.opacity(0.4))

                    VStack(alignment: .leading, spacing: 14) {
                        CardInfoRow(title: "LICENSE NUMBER", value: doctor.license_number ?? "N/A")
                        CardInfoRow(title: "ISSUED DATE", value: "16 JUN 2013")
                        CardInfoRow(title: "VALIDITY", value: "LIFETIME")
                    }

                    HStack {
                        Spacer()
                        Text("Medical Council of India")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(24)
            }
            .frame(height: 240)
        }
        .padding(.vertical, 12)
    }
}

struct StatsView: View {
    let doctor: Doctor
    let purpleColor: Color

    var body: some View {
        HStack(spacing: 0) {
            StatView(icon: "person.2.fill", value: "1246", label: "Patients", color: purpleColor)
            StatView(icon: "clock.fill", value: "\(doctor.doctor_experience ?? 0) Yrs", label: "Experience", color: purpleColor)
            StatView(icon: "star.fill", value: "4.8", label: "Rating", color: purpleColor)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: purpleColor.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .padding(.vertical, 8)
    }
}

struct MonthlySummaryView: View {
    let purpleColor: Color
    let lightPurple: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Monthly Summary")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.black)

            HStack(spacing: 24) {
                SummaryItem(value: "68", label: "Appointments", icon: "calendar", color: purpleColor)
                SummaryItem(value: "52", label: "Completed", icon: "checkmark.circle.fill", color: purpleColor)
                SummaryItem(value: "16", label: "Upcoming", icon: "clock.fill", color: purpleColor)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(lightPurple)
                .shadow(color: purpleColor.opacity(0.08), radius: 12, x: 0, y: 6)
        )
    }
}

struct QualificationsView: View {
    let purpleColor: Color

    let qualifications = [
        Qualification(degree: "MD in Cardiology", institution: "AIIMS Delhi", years: "2008-2012", description: "Specialized in interventional cardiology."),
        Qualification(degree: "MBBS", institution: "Maulana Azad Medical College", years: "2002-2007", description: "Graduated with honors."),
        Qualification(degree: "Board Certification", institution: "Medical Council of India", years: "2013", description: "National board certified cardiologist.")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Qualifications")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.black)

            ForEach(qualifications, id: \.degree) { qualification in
                QualificationCard(qualification: qualification, color: purpleColor)
            }
        }
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

struct QualificationCard: View {
    let qualification: Qualification
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Image(systemName: "graduationcap.fill")
                    .foregroundColor(color)
                    .font(.system(size: 20))
                VStack(alignment: .leading, spacing: 6) {
                    Text(qualification.degree)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                    Text("\(qualification.institution) | \(qualification.years)")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(color.opacity(0.7))
                }
                Spacer()
            }
            Text(qualification.description)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(.black.opacity(0.65))
                .lineSpacing(6)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: color.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .padding(.vertical, 4)
    }
}

struct StatView: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.08))
                    .frame(width: 52, height: 52)
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.black)
            Text(label)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(color.opacity(0.7))
        }
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity)
    }
}

struct SummaryItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.black)
            Text(label)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(color.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

struct NoteCard: View {
    let note: DoctorsNote
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(color)
                    .font(.system(size: 18))
                Text("Appointment ID: \(note.appointmentID)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                Spacer()
            }
            Text("Patient ID: \(note.patientID)")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(color.opacity(0.7))
            Text(note.note)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.black.opacity(0.65))
                .lineLimit(2)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: color.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}
