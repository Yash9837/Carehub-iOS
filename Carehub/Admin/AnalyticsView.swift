import SwiftUI
import FirebaseFirestore

// MARK: - Appointment Model


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
                            
                            // Appointments by Status Chart
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                AppointmentsByStatusChart(appointmentsByStatus: analyticsManager.appointmentsByStatus)
                                    .frame(height: 200)
                                    .padding()
                            }
                            .padding(.horizontal, 20)
                            
                            // Daily Appointments Chart
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                DailyAppointmentsChart(dailyAppointments: analyticsManager.dailyAppointments)
                                    .frame(height: 200)
                                    .padding()
                            }
                            .padding(.horizontal, 20)
                            
                            // Weekly Appointments Chart
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                WeeklyAppointmentsChart(weeklyAppointments: analyticsManager.weeklyAppointments)
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

// MARK: - Daily Appointments Chart (Enhanced Line Chart)
struct DailyAppointmentsChart: View {
    let dailyAppointments: [(date: Date, count: Int)]
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)

    var body: some View {
        VStack {
            Text("Appointments by Day (Last 30 Days)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 5)
            
            GeometryReader { geometry in
                let maxCount = dailyAppointments.map { $0.count }.max() ?? 1
                let chartHeight = geometry.size.height - 40
                let chartWidth = geometry.size.width - 40
                
                let points = dailyAppointments.enumerated().map { index, data in
                    let x = CGFloat(index) / CGFloat(dailyAppointments.count - 1) * chartWidth + 40
                    let y = (1 - CGFloat(data.count) / CGFloat(maxCount)) * chartHeight + 20
                    return CGPoint(x: x, y: y)
                }
                
                ZStack {
                    // Grid Lines and Y-Axis Labels
                    ForEach(0..<5) { i in
                        let y = CGFloat(i) / 4 * chartHeight + 20
                        let count = Int(CGFloat(maxCount) * (1 - CGFloat(i) / 4))
                        Path { path in
                            path.move(to: CGPoint(x: 40, y: y))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                        }
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        
                        Text("\(count)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .position(x: 20, y: y)
                    }
                    
                    // Area Fill
                    Path { path in
                        path.move(to: CGPoint(x: points.first?.x ?? 40, y: chartHeight + 20))
                        for point in points {
                            path.addLine(to: point)
                        }
                        path.addLine(to: CGPoint(x: points.last?.x ?? chartWidth + 40, y: chartHeight + 20))
                        path.closeSubpath()
                    }
                    .fill(purpleColor.opacity(0.1))
                    
                    // Line
                    Path { path in
                        path.move(to: points.first ?? .zero)
                        for point in points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                    .strokedPath(StrokeStyle(lineWidth: 4, lineCap: .round))
                    .foregroundColor(purpleColor)
                    
                    // Points
                    ForEach(0..<points.count, id: \.self) { index in
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(purpleColor)
                            .position(points[index])
                    }
                    
                    // X-Axis Labels
                    ForEach(dailyAppointments.indices, id: \.self) { index in
                        if index % 5 == 0 {
                            Text(dateFormatter.string(from: dailyAppointments[index].date))
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .position(x: points[index].x, y: geometry.size.height - 10)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter
    }()
}

// MARK: - Weekly Appointments Chart (Enhanced Bar Chart)
struct WeeklyAppointmentsChart: View {
    let weeklyAppointments: [(weekStart: Date, count: Int)]
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)

    var body: some View {
        VStack {
            Text("Appointments by Week (Last 12 Weeks)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 5)
            
            GeometryReader { geometry in
                let maxCount = weeklyAppointments.map { $0.count }.max() ?? 1
                let chartHeight = geometry.size.height - 40
                let chartWidth = geometry.size.width - 40
                let barWidth = chartWidth / CGFloat(weeklyAppointments.count) * 0.6
                let barSpacing = chartWidth / CGFloat(weeklyAppointments.count) * 0.4
                
                ZStack {
                    // Grid Lines and Y-Axis Labels
                    ForEach(0..<5) { i in
                        let y = CGFloat(i) / 4 * chartHeight + 20
                        let count = Int(CGFloat(maxCount) * (1 - CGFloat(i) / 4))
                        Path { path in
                            path.move(to: CGPoint(x: 40, y: y))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                        }
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        
                        Text("\(count)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .position(x: 20, y: y)
                    }
                    
                    // Bars
                    HStack(alignment: .bottom, spacing: barSpacing) {
                        ForEach(weeklyAppointments.indices, id: \.self) { index in
                            let data = weeklyAppointments[index]
                            let height = CGFloat(data.count) / CGFloat(maxCount) * chartHeight
                            let xPosition = CGFloat(index) * (barWidth + barSpacing) + barWidth / 2 + 40
                            VStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(purpleColor.opacity(0.9))
                                        .frame(width: barWidth, height: height)
                                    Text("\(data.count)")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .offset(y: -height / 2)
                                }
                                Text(weekFormatter.string(from: data.weekStart))
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                    .rotationEffect(.degrees(-45))
                                    .frame(height: 40)
                            }
                            .position(x: xPosition, y: (chartHeight - height) / 2 + 20 + height / 2)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private let weekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter
    }()
}

// MARK: - Analytics Manager
class AnalyticsManager: ObservableObject {
    @Published var totalAppointments: Int = 0
    @Published var cancellationRate: Double = 0.0
    @Published var totalRevenue: Double = 0.0
    @Published var averageRevenuePerAppointment: Double = 0.0
    @Published var appointmentsByStatus: [(status: String, count: Int)] = []
    @Published var dailyAppointments: [(date: Date, count: Int)] = []
    @Published var weeklyAppointments: [(weekStart: Date, count: Int)] = []
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
                
                guard let apptId = data["apptId"] as? String,
                      let patientId = data["patientId"] as? String,
                      let description = data["description"] as? String,
                      let docId = data["docId"] as? String,
                      let status = data["status"] as? String,
                      let billingStatus = data["billingStatus"] as? String else {
                    print("Missing required fields for document \(doc.documentID)")
                    return nil
                }
                
                let amount = data["amount"] as? Double
                let doctorsNotes = data["doctorsNotes"] as? String
                let prescriptionId = data["prescriptionId"] as? String
                let followUpRequired = data["followUpRequired"] as? Bool
                
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
        totalAppointments = appointments.count
        
        let cancelledAppointments = appointments.filter { $0.billingStatus == "cancelled" }.count
        cancellationRate = totalAppointments > 0 ? (Double(cancelledAppointments) / Double(totalAppointments)) * 100 : 0.0
        
        let totalRevenue = appointments.compactMap { $0.amount }.reduce(0, +)
        self.totalRevenue = totalRevenue
        self.averageRevenuePerAppointment = totalAppointments > 0 ? totalRevenue / Double(totalAppointments) : 0.0
        
        var statusDict: [String: Int] = [:]
        for appt in appointments {
            let status = appt.status.lowercased()
            statusDict[status, default: 0] += 1
        }
        appointmentsByStatus = statusDict.map { (status: $0.key, count: $0.value) }
            .sorted { $0.status < $1.status }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Daily Appointments (Last 30 Days)
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today)!
        var dailyDict: [Date: Int] = [:]
        
        for i in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            dailyDict[date] = 0
        }
        
        for appt in appointments {
            if let date = appt.date, date >= thirtyDaysAgo {
                let startOfDay = calendar.startOfDay(for: date)
                dailyDict[startOfDay, default: 0] += 1
            }
        }
        
        dailyAppointments = dailyDict.map { (date: $0.key, count: $0.value) }
            .sorted { $0.date < $1.date }
        
        // Weekly Appointments (Last 12 Weeks)
        let twelveWeeksAgo = calendar.date(byAdding: .weekOfYear, value: -12, to: today)!
        var weeklyDict: [Date: Int] = [:]
        
        for i in 0..<12 {
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -i, to: today)!
            weeklyDict[weekStart] = 0
        }
        
        for appt in appointments {
            if let date = appt.date, date >= twelveWeeksAgo {
                let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
                if let weekStart = calendar.date(from: components) {
                    weeklyDict[weekStart, default: 0] += 1
                }
            }
        }
        
        weeklyAppointments = weeklyDict.map { (weekStart: $0.key, count: $0.value) }
            .sorted { $0.weekStart < $1.weekStart }
    }
}

// MARK: - Preview
struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
    }
}
