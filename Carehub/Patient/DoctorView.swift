import SwiftUI
import FirebaseFirestore

struct DoctorView: View {
    let patientId: String
    @State private var specialties: [String] = []
    @State private var isDataLoaded = false
    @State private var isDataLoadFailed = false
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.94, green: 0.94, blue: 1.0)
                    .edgesIgnoringSafeArea(.all)
                if !isDataLoaded && !isDataLoadFailed {
                    ProgressView()
                        .tint(Color(red: 0.43, green: 0.34, blue: 0.99))
                        .padding()
                } else if isDataLoadFailed {
                    VStack {
                        Text("Failed to load specialties")
                            .foregroundColor(.red)
                            .font(FontSizeManager.font(for: 18, weight: .medium))
                        Button(action: {
                            isDataLoaded = false
                            isDataLoadFailed = false
                            loadData()
                        }) {
                            Text("Retry")
                                .font(FontSizeManager.font(for: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color(red: 0.43, green: 0.34, blue: 0.99))
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Select a Specialty")
                                .font(FontSizeManager.font(for: 28, weight: .bold))
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                            
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(specialties, id: \.self) { specialty in
                                    NavigationLink(destination: SpecialtyDoctorsView(selectedSpecialty: specialty, patientId: patientId)) {
                                        SpecialtyCard(specialty: specialty)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                        }
                    }
                }
            }
            .navigationTitle("Doctors")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadData()
            }
        }
    }
    
    private func loadData() {
        DoctorData.fetchDoctors {
            specialties = DoctorData.specialties
            isDataLoaded = true
            if specialties.isEmpty {
                isDataLoadFailed = true
            }
        }
    }
}

struct SpecialtyCard: View {
    let specialty: String
    
    var iconName: String {
        switch specialty {
        case "Cardiology": return "heart.fill"
        case "Orthopedics": return "figure.walk"
        case "Neurology": return "brain.head.profile"
        case "Gynecology": return "person.crop.circle.fill"
        case "Surgery": return "scissors"
        case "Dermatology": return "hand.raised.fill"
        case "Endocrinology": return "chart.bar.fill"
        case "ENT": return "ear.fill"
        case "Oncology": return "waveform.path.ecg"
        case "Psychiatry": return "brain.fill"
        case "Urology": return "kidneys"
        case "Pediatrics": return "figure.2.and.child.holdinghands"
        default: return "stethoscope"
        }
    }
    
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: iconName)
                .font(.system(size: FontSizeManager.fontSize(for: 32)))
                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                .frame(height: 36)
                .padding(.top, 8)
            
            Text(specialty)
                .font(FontSizeManager.font(for: 16, weight: .semibold))
                .foregroundColor(.black)
                .padding(.bottom, 10)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 120)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
    }
}

struct SpecialtyDoctorsView: View {
    let selectedSpecialty: String
    let patientId: String
    @State private var searchText = ""
    @State private var sortByExp = false
    @State private var doctors: [Doctor] = []
    @State private var isDataLoaded = false
    @State private var isDataLoadFailed = false
    
    var filteredDoctors: [Doctor] {
        let filtered = doctors.filter { doctor in
            searchText.isEmpty || doctor.doctor_name.lowercased().contains(searchText.lowercased())
        }
        return sortByExp ? filtered.sorted { ($0.doctor_experience ?? 0) > ($1.doctor_experience ?? 0) } : filtered.sorted { ($0.doctor_experience ?? 0) < ($1.doctor_experience ?? 0) }
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.94, blue: 1.0)
                .edgesIgnoringSafeArea(.all)
            
            if !isDataLoaded && !isDataLoadFailed {
                ProgressView()
                    .tint(Color(red: 0.43, green: 0.34, blue: 0.99))
                    .padding()
            } else if isDataLoadFailed {
                VStack {
                    Text("Failed to load doctors")
                        .foregroundColor(.red)
                        .font(FontSizeManager.font(for: 18, weight: .medium))
                    Button(action: {
                        isDataLoaded = false
                        isDataLoadFailed = false
                        loadDoctors()
                    }) {
                        Text("Retry")
                            .font(FontSizeManager.font(for: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(red: 0.43, green: 0.34, blue: 0.99))
                            .cornerRadius(10)
                    }
                }
                .padding()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        HStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                                    .font(.system(size: FontSizeManager.fontSize(for: 18)))
                                    .padding(.leading, 12)
                                
                                TextField("Search by doctor name...", text: $searchText)
                                    .font(FontSizeManager.font(for: 16))
                                    .padding(.vertical, 12)
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                            .padding(.leading, 16)
                            
                            Menu {
                                Button(action: { sortByExp = false }) {
                                    Text("Sort by Exp (Low to High)")
                                        .font(FontSizeManager.font(for: 14))
                                }
                                Button(action: { sortByExp = true }) {
                                    Text("Sort by Exp (High to Low)")
                                        .font(FontSizeManager.font(for: 14))
                                }
                            } label: {
                                Image(systemName: "slider.horizontal.3")
                                    .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                                    .font(.system(size: FontSizeManager.fontSize(for: 20)))
                                    .padding(.trailing, 16)
                                    .padding(.vertical, 12)
                            }
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 16)
                        .padding(.trailing, 16)
                        
                        HStack {
                            Text(selectedSpecialty)
                                .font(FontSizeManager.font(for: 18, weight: .bold))
                                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                            
                            Text("(\(filteredDoctors.count))")
                                .font(FontSizeManager.font(for: 18, weight: .medium))
                                .foregroundColor(.gray)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 14)
                        
                        LazyVStack(spacing: 0) {
                            ForEach(filteredDoctors, id: \.id) { doctor in
                                NavigationLink(destination: DoctorDetailView(doctor: doctor, specialty: selectedSpecialty, patientId: patientId)) {
                                    DoctorCardView(
                                        name: doctor.doctor_name,
                                        specialty: selectedSpecialty,
                                        experience: doctor.doctor_experience ?? 0,
                                        imageName: "person.circle.fill"
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .navigationTitle(selectedSpecialty)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadDoctors()
        }
    }
    
    private func loadDoctors() {
        let filteredDoctors = DoctorData.doctors[selectedSpecialty] ?? []
        doctors = filteredDoctors
        isDataLoaded = true
        if doctors.isEmpty {
            isDataLoadFailed = true
        }
    }
}

struct DoctorCardView: View {
    let name: String
    let specialty: String
    let experience: Int
    let imageName: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: FontSizeManager.fontSize(for: 50), height: FontSizeManager.fontSize(for: 50))
                .foregroundColor(.white)
                .padding(6)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.43, green: 0.34, blue: 0.99),
                            Color(red: 0.55, green: 0.48, blue: 0.99)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.3), radius: 5, x: 0, y: 3)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(FontSizeManager.font(for: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Text(specialty)
                    .font(FontSizeManager.font(for: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                HStack(spacing: 4) {
                    Image(systemName: "briefcase.fill")
                        .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                        .font(.system(size: FontSizeManager.fontSize(for: 12)))
                    
                    Text("\(experience) yrs exp")
                        .font(FontSizeManager.font(for: 12, weight: .medium))
                        .foregroundColor(Color.black.opacity(0.7))
                }
            }
            .padding(.vertical, 4)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                .font(.system(size: FontSizeManager.fontSize(for: 14), weight: .semibold))
                .padding(.trailing, 8)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

struct DoctorDetailView: View {
    let doctor: Doctor
    let specialty: String
    let patientId: String
    @State private var qualifications: [String] = ["MBBS", "MD - General Medicine", "DNB - Cardiology"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hero Card with doctor info
                VStack {
                    HStack(alignment: .top, spacing: 20) {
                        // Left side - Image
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: FontSizeManager.fontSize(for: 100), height: FontSizeManager.fontSize(for: 100))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.43, green: 0.34, blue: 0.99),
                                        Color(red: 0.55, green: 0.48, blue: 0.99)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        // Right side - Details
                        VStack(alignment: .leading, spacing: 10) {
                            Text(doctor.doctor_name)
                                .font(FontSizeManager.font(for: 22, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text(specialty)
                                .font(FontSizeManager.font(for: 16, weight: .medium))
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 6) {
                                Image(systemName: "briefcase.fill")
                                    .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                                    .font(.system(size: FontSizeManager.fontSize(for: 14)))
                                
                                Text("\(doctor.doctor_experience ?? 0) years experience")
                                    .font(FontSizeManager.font(for: 14, weight: .medium))
                                    .foregroundColor(Color.black.opacity(0.7))
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(20)
                }
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // Qualifications Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Qualifications")
                        .font(FontSizeManager.font(for: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                        .padding(.horizontal, 16)
                    
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(qualifications, id: \.self) { qualification in
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                                    .font(.system(size: FontSizeManager.fontSize(for: 16)))
                                
                                Text(qualification)
                                    .font(FontSizeManager.font(for: 16))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                    .padding(.horizontal, 16)
                }
                
                // Book appointment button
                NavigationLink(destination: ScheduleAppointmentView(
                    patientId: patientId,
                    selectedSpecialty: specialty,
                    selectedDoctor: doctor.doctor_name
                )) {
                    HStack {
                        Spacer()
                        Text("Book Appointment")
                            .font(FontSizeManager.font(for: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                        Spacer()
                    }
                    .background(Color(red: 0.43, green: 0.34, blue: 0.99))
                    .cornerRadius(12)
                    .shadow(color: Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.4), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(Color(red: 0.94, green: 0.94, blue: 1.0))
        .navigationTitle("Doctor Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}
