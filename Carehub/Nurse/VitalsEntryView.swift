import SwiftUI
import Firebase

struct NurseVitalsEntryView: View {
    let patientId: String  // Changed from nurseId to patientId since we're focusing on vitals entry
    @State private var bpSystolic = 120
    @State private var bpDiastolic = 80
    @State private var weight = 70.0
    @State private var height = 170.0
    @State private var allergies = ""
    @State private var heartRate = 72
    @State private var temperature = 98.6
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var patientName = ""
    @State private var activeSheet: ActiveSheet?
    
    enum ActiveSheet: Identifiable {
        case systolic, diastolic, weight, height, heartRate, temperature
        
        var id: Int {
            hashValue
        }
    }

    let primaryColor = Color(red: 109/255, green: 87/255, blue: 252/255)
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                if colorScheme == .dark {
                    Color(.systemBackground)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    LinearGradient(
                        colors: [
                            Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.1),
                            Color(.systemBackground).opacity(0.9),
                            Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .edgesIgnoringSafeArea(.all)
                }
                
                // Content
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: primaryColor))
                } else {
                    ScrollView {
                        VStack(spacing: 32) {
                            patientInfoCard
                            vitalsForm
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Enter Vitals")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(primaryColor)
                }
            }
            .onAppear {
                fetchPatientDetails()
            }
            .alert("Alert", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .sheet(item: $activeSheet) { item in
                pickerSheet(for: item)
            }
        }
    }
    
    // MARK: - View Components
    
    private var patientInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.title2)
                    .foregroundColor(primaryColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Patient Record")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(patientId)
                        .font(.title3.bold())
                }
            }
            .padding(.bottom, 4)
            
            Divider()
            
            if !patientName.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    DetailRow(icon: "person.text.rectangle", label: "Name", value: patientName)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color(.secondarySystemBackground) : .white)
        .cornerRadius(14)
        .shadow(color: colorScheme == .dark ? .clear : .primary.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.top, 16)
    }

    private struct DetailRow: View {
        let icon: String
        let label: String
        let value: String
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(Color(red: 109/255, green: 87/255, blue: 252/255))
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(value)
                        .font(.body)
                }
            }
        }
    }
    
    private var vitalsForm: some View {
        VStack(spacing: 32) {
            Group {
                bloodPressureSection
                vitalValueRow(title: "Weight", value: weight, unit: "kg", systemImage: "scalemass", sheet: .weight)
                vitalValueRow(title: "Height", value: height, unit: "cm", systemImage: "ruler", sheet: .height)
                vitalValueRow(title: "Heart Rate", value: Double(heartRate), unit: "bpm", systemImage: "heart.fill", sheet: .heartRate)
                vitalValueRow(title: "Temperature", value: temperature, unit: "°F", systemImage: "thermometer", sheet: .temperature)
                allergySection
            }
            .padding(.horizontal, 32)
            .padding(.vertical,4)
            saveButton
                .padding(.top, 8)
        }
    }
    
    private var bloodPressureSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .foregroundColor(primaryColor)
                Text("Blood Pressure")
                    .foregroundColor(.secondary)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .font(.title3)
            .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                Button(action: { activeSheet = .systolic }) {
                    vitalValueButton(title: "Systolic", value: "\(bpSystolic)", unit: "mmHg")
                }
                
                Text("/")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Button(action: { activeSheet = .diastolic }) {
                    vitalValueButton(title: "Diastolic", value: "\(bpDiastolic)", unit: "mmHg")
                }
            }
        }
    }
    
    private func vitalValueButton(title: String, value: String, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.custom("SFProDisplay-Medium",size: 18))
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            HStack {
                Text(value)
                    .font(.custom("SFProDisplay-Medium",size: 16))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .fontWeight(.semibold)
                Text(unit)
                    .font(.body)
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(.tertiaryLabel))
            }
            .padding(12)
            .background(colorScheme == .dark ? Color(.tertiarySystemBackground) : .white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.tertiaryLabel).opacity(0.2), lineWidth: 1)
            .cornerRadius(10)
        )}
        .frame(maxWidth: .infinity)
    }
    
    private func vitalValueRow(title: String, value: Double, unit: String, systemImage: String, sheet: ActiveSheet) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(primaryColor)
                Text(title)
                    .foregroundColor(.secondary)
            }
            .font(.title3)
            .fontWeight(.semibold)
            
            Button(action: { activeSheet = sheet }) {
                HStack {
                    Text(String(format: value.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.1f", value))
                        .font(.custom("SFProDisplay-Medium",size: 18))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .fontWeight(.semibold)
                    Text(unit)
                        .font(.body)
                        .foregroundColor(.secondary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(.tertiaryLabel))
                }
                .padding(12)
                .background(colorScheme == .dark ? Color(.tertiarySystemBackground) : .white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.tertiaryLabel).opacity(0.2), lineWidth: 1)
                )
                .cornerRadius(10)
            }
        }
    }
    
    private var allergySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "allergens")
                    .foregroundColor(primaryColor)
                Text("Allergies")
                    .foregroundColor(.secondary)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .font(.title3)
            .fontWeight(.semibold)
            
            TextField("Peanuts, Dust, etc.", text: $allergies)
                .textFieldStyle(.plain)
                .padding(12)
                .background(colorScheme == .dark ? Color(.tertiarySystemBackground) : .white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.tertiaryLabel).opacity(0.2), lineWidth: 1)
                .cornerRadius(10)
       ) }
    }
    
    private var saveButton: some View {
        Button(action: saveVitals) {
            Label("Save Vitals", systemImage: "")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
        }
        .buttonStyle(.borderedProminent)
        .tint(primaryColor)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private func pickerSheet(for item: ActiveSheet) -> some View {
        VStack(spacing: 0) {
            Capsule()
                .frame(width: 36, height: 5)
                .foregroundColor(Color(.systemGray5))
                .padding(.top, 8)
                .padding(.bottom, 16)
            
            Group {
                switch item {
                case .systolic:
                    IntPicker(value: $bpSystolic, range: 80...200, title: "Systolic", unit: "mmHg")
                case .diastolic:
                    IntPicker(value: $bpDiastolic, range: 40...130, title: "Diastolic", unit: "mmHg")
                case .weight:
                    DecimalPicker(value: $weight, range: 30...200, title: "Weight", unit: "kg")
                case .height:
                    DecimalPicker(value: $height, range: 100...220, title: "Height", unit: "cm")
                case .heartRate:
                    IntPicker(value: $heartRate, range: 40...200, title: "Heart Rate", unit: "bpm")
                case .temperature:
                    DecimalPicker(value: $temperature, range: 94...108, title: "Temperature", unit: "°F")
                }
            }
            .padding(.horizontal)
            
            Button(action: { activeSheet = nil }) {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .buttonStyle(.borderedProminent)
            .tint(primaryColor)
            .padding()
        }
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled()
        .background(Color(.systemBackground))
    }
    
    // MARK: - Helper Views
    
    struct IntPicker: View {
        @Binding var value: Int
        let range: ClosedRange<Int>
        let title: String
        let unit: String
        
        var body: some View {
            VStack {
                Text("\(title): \(value) \(unit)")
                    .font(.headline)
                    .padding(.bottom, 8)
                
                Picker("", selection: $value) {
                    ForEach(range, id: \.self) { num in
                        Text("\(num)").tag(num)
                    }
                }
                .pickerStyle(.wheel)
            }
        }
    }
    
    struct DecimalPicker: View {
        @Binding var value: Double
        let range: ClosedRange<Double>
        let title: String
        let unit: String
        let step: Double
        
        init(value: Binding<Double>, range: ClosedRange<Double>, title: String, unit: String, step: Double = 0.1) {
            self._value = value
            self.range = range
            self.title = title
            self.unit = unit
            self.step = step
        }
        
        var body: some View {
            VStack {
                Text("\(title): \(String(format: value.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.1f", value)) \(unit)")
                    .font(.headline)
                    .padding(.bottom, 8)
                
                Picker("", selection: $value) {
                    ForEach(Array(stride(from: range.lowerBound, through: range.upperBound, by: step)), id: \.self) { num in
                        Text(String(format: num.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.1f", num)).tag(num)
                    }
                }
                .pickerStyle(.wheel)
            }
        }
    }
    
    // MARK: - Functions
    
    private func fetchPatientDetails() {
        startLoading()
        FirebaseService.shared.fetchPatientName(patientID: patientId) { result in
            DispatchQueue.main.async {
                self.stopLoading()
                switch result {
                case .success(let name):
                    self.patientName = name
                    self.fetchPatientVitals()
                case .failure(let error):
                    print("Error fetching name: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func fetchPatientVitals() {
        FirebaseService.shared.fetchPatientVitals(patientID: patientId) { result in
            stopLoading()
            
            switch result {
            case .success(let vitals):
                populateVitals(vitals)
            case .failure(let error):
                showAlert(message: "Error loading vitals: \(error.localizedDescription)")
            }
        }
    }
    
    private func saveVitals() {
        uploadVitals()
    }
    
    private func uploadVitals() {
        startLoading()
        
        let vitalsData: [String: Any] = [
            "bp": "\(bpSystolic)/\(bpDiastolic)",
            "weight": String(format: "%.1f", weight),
            "height": String(format: "%.1f", height),
            "allergies": allergies,
            "heartRate": String(heartRate),
            "temperature": String(format: "%.1f", temperature),
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        FirebaseService.shared.savePatientVitals(patientID: patientId, vitals: vitalsData) { result in
            stopLoading()
            
            switch result {
            case .success:
                showAlert(message: "Vitals saved successfully!")
            case .failure(let error):
                showAlert(message: "Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func populateVitals(_ vitals: [String: Any]) {
        if let bp = vitals["bp"] as? String {
            let components = bp.components(separatedBy: "/")
            if components.count == 2 {
                bpSystolic = Int(components[0]) ?? 120
                bpDiastolic = Int(components[1]) ?? 80
            }
        }
        
        if let weightStr = vitals["weight"] as? String, let weightValue = Double(weightStr) {
            weight = weightValue
        }
        
        if let heightStr = vitals["height"] as? String, let heightValue = Double(heightStr) {
            height = heightValue
        }
        
        allergies = vitals["allergies"] as? String ?? ""
        
        if let heartRateStr = vitals["heartRate"] as? String, let heartRateValue = Int(heartRateStr) {
            heartRate = heartRateValue
        }
        
        if let tempStr = vitals["temperature"] as? String, let tempValue = Double(tempStr) {
            temperature = tempValue
        }
    }
    
    private func startLoading() {
        withAnimation { isLoading = true }
    }
    
    private func stopLoading() {
        withAnimation { isLoading = false }
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}

#Preview {
    Group {
        NurseVitalsEntryView(patientId: "PAT001")
            .preferredColorScheme(.light)
    }
}
