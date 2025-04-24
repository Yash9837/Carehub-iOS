import SwiftUI

struct DoctorView: View {
    let specialties = DoctorData.specialties
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color from first design
                Color(red: 0.94, green: 0.94, blue: 1.0)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Select a Specialty")
                            .font(.system(size: 28, weight: .bold))
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                            .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(specialties, id: \.self) { specialty in
                                NavigationLink(destination: SpecialtyDoctorsView(selectedSpecialty: specialty)) {
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
            .navigationTitle("Doctors")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SpecialtyCard: View {
    let specialty: String
    
    // Map specialties to appropriate icons
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
            // Icon with consistent size and styling
            Image(systemName: iconName)
                .font(.system(size: 32))
                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                .frame(height: 36)
                .padding(.top, 8)
            
            // Specialty name with consistent positioning
            Text(specialty)
                .font(.system(size: 16, weight: .semibold))
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
    @State private var searchText = ""
    @State private var sortByExp = false // False for ascending, true for descending
    let doctors = DoctorData.doctors
    
    var filteredDoctors: [(name: String, experience: Int, imageName: String)] {
        let filtered = doctors[selectedSpecialty]?.filter { doctor in
            searchText.isEmpty || doctor.name.lowercased().contains(searchText.lowercased())
        } ?? []
        return sortByExp ? filtered.sorted { $0.experience > $1.experience } : filtered.sorted { $0.experience < $1.experience }
    }

    var body: some View {
        ZStack {
            // Background color from first design
            Color(red: 0.94, green: 0.94, blue: 1.0)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 0) {
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                                .font(.system(size: 18))
                                .padding(.leading, 12)
                            
                            TextField("Search by doctor name...", text: $searchText)
                                .font(.system(size: 16))
                                .padding(.vertical, 12)
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                        .padding(.leading, 16)
                        
                        // Filter button
                        Menu {
                            Button(action: { sortByExp = false }) {
                                Text("Sort by Exp (Low to High)")
                            }
                            Button(action: { sortByExp = true }) {
                                Text("Sort by Exp (High to Low)")
                            }
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                                .font(.system(size: 20))
                                .padding(.trailing, 16)
                                .padding(.vertical, 12)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                    .padding(.trailing, 16)
                    
                    HStack {
                        Text(selectedSpecialty)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                        
                        Text("(\(filteredDoctors.count))")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)
                    
                    LazyVStack(spacing: 0) {
                        ForEach(filteredDoctors, id: \.name) { doctor in
                            Button(action: {
                                print("Selected doctor: \(doctor.name)")
                            }) {
                                DoctorCardView(
                                    name: doctor.name,
                                    specialty: selectedSpecialty,
                                    experience: doctor.experience,
                                    imageName: doctor.imageName
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle(selectedSpecialty)
        .navigationBarTitleDisplayMode(.inline)
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
                .frame(width: 50, height: 50)
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
            
            // Doctor Details with adjusted typography
            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Text(specialty)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                HStack(spacing: 4) {
                    Image(systemName: "briefcase.fill")
                        .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                        .font(.system(size: 12))
                    
                    Text("\(experience) yrs exp")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.black.opacity(0.7))
                }
            }
            .padding(.vertical, 4)
            
            Spacer()
            
            // Book button
            Button(action: {
                print("Book appointment for \(name)")
            }) {
                Text("Book")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Color(red: 0.43, green: 0.34, blue: 0.99)
                    )
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
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

struct DoctorView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorView()
    }
}

