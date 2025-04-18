import SwiftUI

struct HomeView_patient: View {
    let username: String // Accept username as a parameter
    @Environment(\.colorScheme) private var colorScheme

    // Sample data for upcoming schedule and top doctors
    let upcomingSchedule = (doctorName: "Dr. Rasheed Idris", specialty: "Cardiovascular", date: "Nov 24, 9:00am", imageName: "doctor1")
    let topDoctors = [
        (name: "Dr. Kenny Adeola", specialty: "General Practitioner", rating: 4.4, reviews: 54, imageName: "doctor2"),
        (name: "Dr. Taiwo", specialty: "General Practitioner", rating: 4.5, reviews: 56, imageName: "doctor3"),
        (name: "Dr. Johnson", specialty: "Pediatrician", rating: 4.8, reviews: 280, imageName: "doctor4"),
        (name: "Dr. Nkechi Okeli", specialty: "Oncologist", rating: 4.3, reviews: 130, imageName: "doctor5")
    ]
    var body: some View {
        ZStack {
            // Background gradient adjusted for dark and light mode
            LinearGradient(
                colors: colorScheme == .dark ? [Color.black, Color(.systemGray6)] : [Color.white, Color(.systemGray5)],
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 20) {
                    // Greeting
                    HStack {
                        Image("profile") // Replace with actual user profile image or placeholder
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        VStack(alignment: .leading) {
                            Text("Hi, \(username)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Text("How are you today?")
                                .font(.system(size: 14))
                                .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                        }
                        Spacer()
                        Image(systemName: "bell")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .font(.system(size: 20))
                    }
                    .padding(.horizontal)

                    // Search Bar
                    HStack {
                        TextField("Search doctor, Pharmacy...", text: .constant(""))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .frame(height: 40)
                            .background(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray4))
                            .cornerRadius(10)
                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(colorScheme == .dark ? Color.green : Color.green)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)

                    // Upcoming Schedule
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Upcoming schedule")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                            Text("See All")
                                .font(.system(size: 14))
                                .foregroundColor(colorScheme == .dark ? .green : .blue)
                        }
                        .padding(.horizontal)

                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(colorScheme == .dark ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                                .frame(height: 120)

                            HStack(spacing: 15) {
                                Image(upcomingSchedule.imageName) // Replace with actual image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 90, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(upcomingSchedule.doctorName)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                    Text(upcomingSchedule.specialty)
                                        .font(.system(size: 14))
                                        .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                                    Text(upcomingSchedule.date)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                }
                                Spacer()
                            }
                            .padding()
                        }
                        .padding(.horizontal)
                    }

                    // Quick Actions
                    HStack(spacing: 20) {
                        QuickActionButton(icon: "stethoscope", title: "Doctor")
                        QuickActionButton(icon: "pills", title: "Pharmacy")
                        QuickActionButton(icon: "car", title: "Ambulance")
                        QuickActionButton(icon: "house", title: "Hospital")
                    }
                    .padding(.horizontal)

                    // Top Doctors
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Top Doctor")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                            Text("See All")
                                .font(.system(size: 14))
                                .foregroundColor(colorScheme == .dark ? .green : .blue)
                        }
                        .padding(.horizontal)

                        ForEach(topDoctors, id: \.name) { doctor in
                            DoctorCard(doctor: doctor)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Home")
        .navigationBarBackButtonHidden(true)
    }
}

// Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack {
            Image(systemName: icon)
                .foregroundColor(colorScheme == .dark ? .green : .blue)
                .font(.system(size: 24))
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
        .frame(maxWidth: .infinity)
    }
}

// Doctor Card
struct DoctorCard: View {
    let doctor: (name: String, specialty: String, rating: Double, reviews: Int, imageName: String)
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 15) {
            Image(doctor.imageName) // Replace with actual image
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 5) {
                Text(doctor.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Text(doctor.specialty)
                    .font(.system(size: 14))
                    .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                HStack(spacing: 5) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", doctor.rating))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text("(\(doctor.reviews) reviews)")
                        .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
        .padding()
        .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray5))
        .cornerRadius(10)
    }
}

#Preview {
    HomeView_patient(username: "Azeez")
}
