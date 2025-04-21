import SwiftUI

struct DoctorCard: View {
    let name: String
    let specialty: String
    let education: String
    let experience: Int
    let imageName: String

    var body: some View {
        HStack(spacing: 15) {
            // Doctor Image
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99)) // Purple color
                .padding(8)
                .background(Circle().fill(Color.white))
                .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
            
            // Doctor Details
            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(.headline)
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Text(specialty)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(education)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 4) {
                    Image(systemName: "briefcase.fill")
                        .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                        .font(.caption)
                    
                    Text("\(experience) yrs exp")
                        .font(.caption)
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .frame(maxWidth: .infinity)
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct DoctorView: View {
    let specialties = ["Cardiology", "Orthopedics", "Neurology", "Gynecology", "Surgery", "Dermatology", "Endocrinology", "ENT", "Oncology", "Psychiatry", "Urology", "Pediatrics"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                // Gradient overlay with purple shade #6D57FC
                LinearGradient(
                    colors: [
                        Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.4), // #6D57FC
                        Color.white.opacity(0.9),
                        Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 15) {
                        Text("Select a Specialty")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.top, 20)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(specialties, id: \.self) { specialty in
                                NavigationLink(destination: SpecialtyDoctorsView(selectedSpecialty: specialty)) {
                                    CategoryCard(specialty: specialty)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                }
            }
            .navigationTitle("Doctors")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Category Card for Specialties (Image Removed)
struct CategoryCard: View {
    let specialty: String

    var body: some View {
        HStack(spacing: 15) {
            Text(specialty)
                .font(.headline)
                .foregroundColor(.black)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding()
        .background(Color.white)
        .frame(maxWidth: .infinity)
        .frame(width: UIScreen.main.bounds.width * 0.45) // Adjusted for 2 cards per row
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// New View for Specialty-Specific Doctors with Search and Filter
struct SpecialtyDoctorsView: View {
    let selectedSpecialty: String
    @State private var searchText = ""
    @State private var doctors = [
        (name: "Dr. Amit Sharma", specialty: "Cardiology", education: "MBBS, MD", experience: 12, imageName: "person.circle.fill"),
        (name: "Dr. Priya Gupta", specialty: "Orthopedics", education: "MBBS, MS", experience: 8, imageName: "person.circle.fill"),
        (name: "Dr. Rajesh Kumar", specialty: "Neurology", education: "MBBS, DNB", experience: 15, imageName: "person.circle.fill"),
        (name: "Dr. Neha Singh", specialty: "Gynecology", education: "MBBS, DGO", experience: 9, imageName: "person.circle.fill"),
        (name: "Dr. Vikram Patel", specialty: "Surgery", education: "MBBS, FRCS", experience: 18, imageName: "person.circle.fill"),
        (name: "Dr. Anjali Desai", specialty: "Dermatology", education: "MBBS, MD", experience: 7, imageName: "person.circle.fill"),
        (name: "Dr. Sanjay Mehta", specialty: "Endocrinology", education: "MBBS, DM", experience: 11, imageName: "person.circle.fill"),
        (name: "Dr. Kavita Rao", specialty: "ENT", education: "MBBS, MS", experience: 10, imageName: "person.circle.fill"),
        (name: "Dr. Anil Joshi", specialty: "Oncology", education: "MBBS, MD", experience: 19, imageName: "person.circle.fill"),
        (name: "Dr. Meena Iyer", specialty: "Psychiatry", education: "MBBS, DPM", experience: 6, imageName: "person.circle.fill"),
        (name: "Dr. Rohan Malhotra", specialty: "Urology", education: "MBBS, MS", experience: 13, imageName: "person.circle.fill"),
        (name: "Dr. Sunita Nair", specialty: "Pediatrics", education: "MBBS, MD", experience: 10, imageName: "person.circle.fill"),
        (name: "Dr. Vikrant Singh", specialty: "Cardiology", education: "MBBS, DM", experience: 14, imageName: "person.circle.fill"),
        (name: "Dr. Pooja Reddy", specialty: "Orthopedics", education: "MBBS, DNB", experience: 8, imageName: "person.circle.fill"),
        (name: "Dr. Arjun Kapoor", specialty: "Neurology", education: "MBBS, MD", experience: 16, imageName: "person.circle.fill"),
        (name: "Dr. Shruti Bose", specialty: "Gynecology", education: "MBBS, DGO", experience: 11, imageName: "person.circle.fill"),
        (name: "Dr. Sameer Khan", specialty: "Surgery", education: "MBBS, FRCS", experience: 17, imageName: "person.circle.fill"),
        (name: "Dr. Ritu Sharma", specialty: "Dermatology", education: "MBBS, MD", experience: 7, imageName: "person.circle.fill"),
        (name: "Dr. Karan Seth", specialty: "Endocrinology", education: "MBBS, DM", experience: 12, imageName: "person.circle.fill"),
        (name: "Dr. Leela Menon", specialty: "ENT", education: "MBBS, MS", experience: 9, imageName: "person.circle.fill")
    ]
    @State private var sortByExp = false // Toggle for sorting by experience

    var filteredDoctors: [(name: String, specialty: String, education: String, experience: Int, imageName: String)] {
        var filtered = doctors.filter { $0.specialty == selectedSpecialty }
        if searchText.isEmpty == false {
            filtered = filtered.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        if sortByExp {
            filtered.sort { $0.experience > $1.experience } // Sort descending by experience
        }
        return filtered
    }

    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            // Gradient overlay with purple shade #6D57FC
            LinearGradient(
                colors: [
                    Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.4), // #6D57FC
                    Color.white.opacity(0.9),
                    Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 15) {
                    // Search Bar with Filter Button
                    HStack {
                        TextField("Search by doctor name...", text: $searchText)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.leading, 10)
                        
                        Menu {
                            Button(action: { sortByExp.toggle() }) {
                                Text(sortByExp ? "Sort by Exp (High to Low)" : "Sort by Exp (Low to High)")
                            }
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                                .font(.title2)
                                .padding(.trailing, 10)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 20)

                    // Doctor Cards
                    ForEach(filteredDoctors, id: \.name) { doctor in
                        DoctorCard(
                            name: doctor.name,
                            specialty: doctor.specialty,
                            education: doctor.education,
                            experience: doctor.experience,
                            imageName: doctor.imageName
                        )
                        .frame(maxWidth: .infinity)
                        .frame(width: UIScreen.main.bounds.width * 0.9)
                        .frame(height: 130)
                        .padding(.vertical, 5)
                    }
                }
                .padding(.horizontal, 10)
            }
        }
        .navigationTitle(selectedSpecialty)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DoctorView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorView()
    }
}
