import SwiftUI

struct HomeView_patient: View {
    let username: String
    @Environment(\.colorScheme) private var colorScheme
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99) // #6D57FC
    
    let upcomingSchedules = [
        (doctorName: "Dr. Rasheed Idris", specialty: "Cardiovascular", date: "Nov 24, 9:00am", imageName: "doctor1"),
        (doctorName: "Dr. Aisha Bello", specialty: "Orthopedics", date: "Nov 25, 10:00am", imageName: "doctor2"),
        (doctorName: "Dr. Musa Ibrahim", specialty: "Neurology", date: "Nov 26, 2:00pm", imageName: "doctor3")
    ]
    
    let topDoctors = [
        (name: "Dr. Kenny Adeola", specialty: "General Practitioner", rating: 4.4, reviews: 54, imageName: "doctor2"),
        (name: "Dr. Taiwo", specialty: "General Practitioner", rating: 4.5, reviews: 56, imageName: "doctor3"),
        (name: "Dr. Johnson", specialty: "Pediatrician", rating: 4.8, reviews: 280, imageName: "doctor4"),
        (name: "Dr. Nkechi Okeli", specialty: "Oncologist", rating: 4.3, reviews: 130, imageName: "doctor5")
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.94, blue: 1.0)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hello, \(username)")
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
                    
                    // Upcoming Appointment Cards (Horizontal Scroll)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Upcoming Appointment")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Text("See All")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(purpleColor)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(upcomingSchedules, id: \.doctorName) { schedule in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(LinearGradient(
                                                gradient: Gradient(colors: [purpleColor, Color(red: 0.55, green: 0.48, blue: 0.99)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ))
                                            .shadow(color: purpleColor.opacity(0.2), radius: 10, x: 0, y: 5)
                                        
                                        HStack(spacing: 16) {
                                            Image(schedule.imageName)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                            
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text(schedule.doctorName)
                                                    .font(.system(size: 18, weight: .bold))
                                                    .foregroundColor(.white)
                                                
                                                Text(schedule.specialty)
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(.white.opacity(0.8))
                                                
                                                HStack(spacing: 6) {
                                                    Image(systemName: "calendar")
                                                        .foregroundColor(.white)
                                                        .font(.system(size: 14))
                                                    
                                                    Text(schedule.date)
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
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        HStack(spacing: 16) {
                            QuickActionButton(icon: "stethoscope", title: "Doctor")
                            QuickActionButton(icon: "pills", title: "Pharmacy")
                            QuickActionButton(icon: "cross.case.fill", title: "Hospital")
                            QuickActionButton(icon: "car.fill", title: "Ambulance")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                    
                    // Top Doctors Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Top Doctors")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Text("See All")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(purpleColor)
                        }
                        
                        VStack(spacing: 12) {
                            ForEach(topDoctors, id: \.name) { doctor in
                                HomeDoctorCard(
                                    name: doctor.name,
                                    specialty: doctor.specialty,
                                    rating: doctor.rating,
                                    reviews: doctor.reviews,
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
        .navigationBarBackButtonHidden(true)
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(purpleColor.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .foregroundColor(purpleColor)
                    .font(.system(size: 20, weight: .bold))
            }
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
    }
}

struct HomeDoctorCard: View {
    let name: String
    let specialty: String
    let rating: Double
    let reviews: Int
    let imageName: String
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    
    var body: some View {
        HStack(spacing: 16) {
            // Doctor Image with improved styling
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
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
            
            // Doctor Details
            VStack(alignment: .leading, spacing: 8) {
                Text(name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Text(specialty)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color.yellow)
                        .font(.system(size: 14))
                    
                    Text(String(format: "%.1f", rating))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.black.opacity(0.7))
                    
                    Text("(\(reviews) reviews)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Disclosure indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(purpleColor)
                .padding(.trailing, 8)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    HomeView_patient(username: "Azeez")
}
