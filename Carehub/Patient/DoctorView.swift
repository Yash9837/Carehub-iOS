import SwiftUI

struct DoctorCard: View {
    let name: String
    let specialty: String
    let education: String
    let rating: Double
    let reviews: Int
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
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    
                    Text("\(rating, specifier: "%.1f")")
                        .font(.caption)
                        .foregroundColor(.black)
                    
                    Text("(\(reviews) reviews)")
                        .font(.caption)
                        .foregroundColor(.gray)
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
    @State private var searchText = ""
    @State private var selectedSpecialty = "All"
    @State private var doctors = [
        (name: "Dr. Amit Sharma", specialty: "Cardiology", education: "MBBS, MD", rating: 4.5, reviews: 120, imageName: "person.circle.fill"),
        (name: "Dr. Priya Gupta", specialty: "Orthopedics", education: "MBBS, MS", rating: 4.2, reviews: 85, imageName: "person.circle.fill"),
        (name: "Dr. Rajesh Kumar", specialty: "Neurology", education: "MBBS, DNB", rating: 4.7, reviews: 150, imageName: "person.circle.fill"),
        (name: "Dr. Neha Singh", specialty: "Gynecology", education: "MBBS, DGO", rating: 4.3, reviews: 90, imageName: "person.circle.fill"),
        (name: "Dr. Vikram Patel", specialty: "Surgery", education: "MBBS, FRCS", rating: 4.8, reviews: 200, imageName: "person.circle.fill"),
        (name: "Dr. Anjali Desai", specialty: "Dermatology", education: "MBBS, MD", rating: 4.1, reviews: 70, imageName: "person.circle.fill"),
        (name: "Dr. Sanjay Mehta", specialty: "Endocrinology", education: "MBBS, DM", rating: 4.6, reviews: 110, imageName: "person.circle.fill"),
        (name: "Dr. Kavita Rao", specialty: "ENT", education: "MBBS, MS", rating: 4.4, reviews: 95, imageName: "person.circle.fill"),
        (name: "Dr. Anil Joshi", specialty: "Oncology", education: "MBBS, MD", rating: 4.9, reviews: 180, imageName: "person.circle.fill"),
        (name: "Dr. Meena Iyer", specialty: "Psychiatry", education: "MBBS, DPM", rating: 4.0, reviews: 60, imageName: "person.circle.fill"),
        (name: "Dr. Rohan Malhotra", specialty: "Urology", education: "MBBS, MS", rating: 4.5, reviews: 130, imageName: "person.circle.fill"),
        (name: "Dr. Sunita Nair", specialty: "Pediatrics", education: "MBBS, MD", rating: 4.3, reviews: 100, imageName: "person.circle.fill"),
        (name: "Dr. Vikrant Singh", specialty: "Cardiology", education: "MBBS, DM", rating: 4.6, reviews: 140, imageName: "person.circle.fill"),
        (name: "Dr. Pooja Reddy", specialty: "Orthopedics", education: "MBBS, DNB", rating: 4.2, reviews: 80, imageName: "person.circle.fill"),
        (name: "Dr. Arjun Kapoor", specialty: "Neurology", education: "MBBS, MD", rating: 4.7, reviews: 160, imageName: "person.circle.fill"),
        (name: "Dr. Shruti Bose", specialty: "Gynecology", education: "MBBS, DGO", rating: 4.4, reviews: 110, imageName: "person.circle.fill"),
        (name: "Dr. Sameer Khan", specialty: "Surgery", education: "MBBS, FRCS", rating: 4.8, reviews: 190, imageName: "person.circle.fill"),
        (name: "Dr. Ritu Sharma", specialty: "Dermatology", education: "MBBS, MD", rating: 4.1, reviews: 75, imageName: "person.circle.fill"),
        (name: "Dr. Karan Seth", specialty: "Endocrinology", education: "MBBS, DM", rating: 4.5, reviews: 120, imageName: "person.circle.fill"),
        (name: "Dr. Leela Menon", specialty: "ENT", education: "MBBS, MS", rating: 4.3, reviews: 90, imageName: "person.circle.fill")
    ]
    
    let specialties = ["All", "Cardiology", "Orthopedics", "Neurology", "Gynecology", "Surgery", "Dermatology", "Endocrinology", "ENT", "Oncology", "Psychiatry", "Urology", "Pediatrics"]

    var filteredDoctors: [(name: String, specialty: String, education: String, rating: Double, reviews: Int, imageName: String)] {
        doctors.filter { doctor in
            (searchText.isEmpty || doctor.name.lowercased().contains(searchText.lowercased())) &&
            (selectedSpecialty == "All" || doctor.specialty == selectedSpecialty)
        }
    }

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
                    VStack(spacing: 2) {
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
                                Picker("Filter by Specialty", selection: $selectedSpecialty) {
                                    ForEach(specialties, id: \.self) { specialty in
                                        Text(specialty)
                                            .foregroundColor(.black)
                                    }
                                }
                            } label: {
                                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                    .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                                    .font(.title2)
                                    .padding(.trailing, 10)
                            }
                        }
                        .padding(.horizontal, 10)

                        // Doctor Cards
                        ForEach(filteredDoctors, id: \.name) { doctor in
                            DoctorCard(
                                name: doctor.name,
                                specialty: doctor.specialty,
                                education: doctor.education,
                                rating: doctor.rating,
                                reviews: doctor.reviews,
                                imageName: doctor.imageName
                            )
                            .frame(maxWidth: .infinity)
                            .frame(width: UIScreen.main.bounds.width * 0.9)
                            .frame(height: 130)
                            .padding(.vertical, 5)
                        }
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Doctors")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct DoctorView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorView()
    }
}
