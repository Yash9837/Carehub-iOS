import SwiftUI
import FirebaseFirestore

// MARK: - Main View
struct AnalyticsView: View {
    @StateObject private var analyticsManager = AnalyticsManager()
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.94, green: 0.94, blue: 1.0)
                    .edgesIgnoringSafeArea(.all)
                
                if analyticsManager.isLoading {
                    ProgressView("Loading analytics...")
                        .tint(purpleColor)
                        .scaleEffect(1.5)
                        .padding()
                        .background(purpleColor.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    ScrollView {
                        VStack(spacing: 25) {
                            Text("Hospital Analytics Dashboard")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .padding(.top, 20)
                            
                            HStack(spacing: 15) {
                                AnalyticsCard(
                                    title: "Total Appointments",
                                    value: "\(analyticsManager.totalAppointments)",
                                    icon: "calendar"
                                )
                                AnalyticsCard(
                                    title: "Cancellation Rate",
                                    value: String(format: "%.1f%%", analyticsManager.cancellationRate),
                                    icon: "xmark.circle"
                                )
                            }
                            .padding(.horizontal, 20)
                            
                            HStack(spacing: 15) {
                                AnalyticsCard(
                                    title: "Total Revenue",
                                    value: "₹\(String(format: "%.2f", analyticsManager.totalRevenue))",
                                    icon: "indianrupeesign.circle"
                                )
                                AnalyticsCard(
                                    title: "Avg Revenue/Appointment",
                                    value: "₹\(String(format: "%.2f", analyticsManager.averageRevenuePerAppointment))",
                                    icon: "chart.bar"
                                )
                            }
                            .padding(.horizontal, 20)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                AppointmentsByStatusChart(appointmentsByStatus: analyticsManager.appointmentsByStatus)
                                    .frame(height: 200)
                                    .padding()
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                analyticsManager.fetchAnalytics()
            }
        }
    }
}

// MARK: - Analytics Card
struct AnalyticsCard: View {
    let title: String
    let value: String
    let icon: String
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                    
                    Text(value)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                }
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(purpleColor.opacity(0.8))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Appointments by Status Chart (Bar Chart)
struct AppointmentsByStatusChart: View {
    let appointmentsByStatus: [(status: String, count: Int)]
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)

    var body: some View {
        VStack {
            Text("Appointments by Status")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            GeometryReader { geometry in
                let maxCount = appointmentsByStatus.map { $0.count }.max() ?? 1
                let barWidth = geometry.size.width / CGFloat(appointmentsByStatus.count) * 0.8
                let barSpacing = geometry.size.width / CGFloat(appointmentsByStatus.count) * 0.2
                
                HStack(alignment: .bottom, spacing: barSpacing) {
                    ForEach(appointmentsByStatus, id: \.status) { statusData in
                        let height = CGFloat(statusData.count) / CGFloat(maxCount) * (geometry.size.height - 60)
                        VStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(purpleColor.opacity(0.8))
                                    .frame(width: barWidth, height: height)
                                Text("\(statusData.count)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .offset(y: -height / 2)
                            }
                            Text(statusData.status.capitalized)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.gray)
                                .rotationEffect(.degrees(-45))
                                .frame(height: 40)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

// MARK: - Analytics Manager
class AnalyticsManager: ObservableObject {
    @Published var totalAppointments: Int = 0
    @Published var cancellationRate: Double = 0.0
    @Published var totalRevenue: Double = 0.0
    @Published var averageRevenuePerAppointment: Double = 0.0
    @Published var appointmentsByStatus: [(status: String, count: Int)] = []
    @Published var isLoading: Bool = false
    
    private let db = Firestore.firestore()
    
    func fetchAnalytics() {
        isLoading = true
        
        db.collection("appointments").getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching appointments: \(error.localizedDescription)")
                self.isLoading = false
                return
            }
            
            guard let documents = snapshot?.documents else {
                self.isLoading = false
                return
            }
            
            let today = Calendar.current.startOfDay(for: Date())
            
            let appointments = documents.compactMap { doc -> Appointment? in
                let data = doc.data()
                
                // Extract required fields
                guard let apptId = data["apptId"] as? String,
                      let patientId = data["patientId"] as? String,
                      let description = data["description"] as? String,
                      let docId = data["docId"] as? String,
                      let status = data["status"] as? String,
                      let billingStatus = data["billingStatus"] as? String else {
                    print("Missing required fields for document \(doc.documentID)")
                    return nil
                }
                
                // Handle optional fields
                let amount = data["amount"] as? Double
                let doctorsNotes = data["doctorsNotes"] as? String
                let prescriptionId = data["prescriptionId"] as? String
                let followUpRequired = data["followUpRequired"] as? Bool
                
                // Handle date fields (which may be Timestamps)
                var date: Date?
                if let dateTimestamp = data["date"] as? Timestamp {
                    date = dateTimestamp.dateValue()
                } else if let dateString = data["date"] as? String {
                    let fullDateFormatter = DateFormatter()
                    fullDateFormatter.dateFormat = "d MMM yyyy 'at' HH:mm:ss 'UTC'Z"
                    let dateOnlyFormatter = DateFormatter()
                    dateOnlyFormatter.dateFormat = "d MMM yyyy"
                    if let parsedDate = fullDateFormatter.date(from: dateString) {
                        date = parsedDate
                    } else if let parsedDateOnly = dateOnlyFormatter.date(from: dateString) {
                        date = Calendar.current.startOfDay(for: parsedDateOnly)
                    }
                }
                if date == nil {
                    print("date is nil for document \(doc.documentID), setting to today: \(today)")
                    date = today
                }
                
                var followUpDate: Date?
                if let followUpTimestamp = data["followUpDate"] as? Timestamp {
                    followUpDate = followUpTimestamp.dateValue()
                } else if let followUpDateString = data["followUpDate"] as? String {
                    let fullDateFormatter = DateFormatter()
                    fullDateFormatter.dateFormat = "d MMM yyyy 'at' HH:mm:ss 'UTC'Z"
                    let dateOnlyFormatter = DateFormatter()
                    dateOnlyFormatter.dateFormat = "d MMM yyyy"
                    if let parsedFollowUpDate = fullDateFormatter.date(from: followUpDateString) {
                        followUpDate = parsedFollowUpDate
                    } else if let parsedFollowUpDateOnly = dateOnlyFormatter.date(from: followUpDateString) {
                        followUpDate = Calendar.current.startOfDay(for: parsedFollowUpDateOnly)
                    }
                }
                if followUpDate == nil && followUpRequired == true {
                    print("followUpDate is nil for document \(doc.documentID), setting to today: \(today)")
                    followUpDate = today
                }
                
                return Appointment(
                    id: doc.documentID,
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
            }
            
            self.calculateAnalytics(from: appointments)
            self.isLoading = false
        }
    }
    
    private func calculateAnalytics(from appointments: [Appointment]) {
        // Total Appointments
        totalAppointments = appointments.count
        
        // Cancellation Rate
        let cancelledAppointments = appointments.filter { $0.billingStatus == "cancelled" }.count
        cancellationRate = totalAppointments > 0 ? (Double(cancelledAppointments) / Double(totalAppointments)) * 100 : 0.0
        
        // Revenue Calculations
        let totalRevenue = appointments.compactMap { $0.amount }.reduce(0, +)
        self.totalRevenue = totalRevenue
        self.averageRevenuePerAppointment = totalAppointments > 0 ? totalRevenue / Double(totalAppointments) : 0.0
        
        // Appointments by Status
        var statusDict: [String: Int] = [:]
        for appt in appointments {
            let status = appt.status.lowercased()
            statusDict[status, default: 0] += 1
        }
        appointmentsByStatus = statusDict.map { (status: $0.key, count: $0.value) }
            .sorted { $0.status < $1.status }
    }
}

// MARK: - Preview
struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
    }
}
