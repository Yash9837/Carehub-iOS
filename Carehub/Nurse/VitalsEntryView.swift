import SwiftUI
import Firebase

struct NurseVitalsEntryView: View {
    @State private var patientID = ""
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
    @State private var patientFound = false
    @State private var patientName = ""
    @State private var activeSheet: ActiveSheet?
    
    enum ActiveSheet: Identifiable {
        case systolic, diastolic, weight, height, heartRate, temperature
        
        var id: Int {
            hashValue
        }
    }

    let primaryColor = Color(red: 109/255, green: 87/255, blue: 252/255)
    let backgroundColor = Color(.systemGroupedBackground)
    let cardBackground = Color(.secondarySystemBackground)
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)

                LinearGradient(
                    colors: [
                        Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.4),
                        Color.white.opacity(0.9),
                        Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: primaryColor))
                } else if patientFound {
                    ScrollView {
                        VStack(spacing: 32) {
                            patientInfoCard
                            vitalsForm
                        }
                        .padding(.vertical)
                    }
                    .navigationTitle("Enter Vitals")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: resetForm) {
                                HStack(spacing: 14) {
                                    Image(systemName: "chevron.backward")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Back")
                                }
                                .foregroundColor(primaryColor)
                            }
                        }
                    }
                } else {
                    patientSearchView
                }
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
            // Header with patient ID
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.title2)
                    .foregroundColor(primaryColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Patient Record")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(patientID)
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
        .background(.white)
        .cornerRadius(14)
        .shadow(color: .primary.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.top, 16)
    }

    private struct DetailRow: View {
        let icon: String
        let label: String
        let value: String
        
        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(Color(UIColor(Color(hex: "6D57FC"))))
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
                .foregroundColor(.black)
            
            HStack {
                Text(value)
                    .font(.custom("SFProDisplay-Medium",size: 16))
                    .foregroundStyle(.black)
                    .fontWeight(.semibold)
                Text(unit)
                    .font(.body)
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(.tertiaryLabel))
            }
            .padding(12)
            .background(.white)
            .border(Color(.tertiaryLabel).opacity(0.2))
            .cornerRadius(10)
        }
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
                        .foregroundStyle(.black)
                        .fontWeight(.semibold)
                    Text(unit)
                        .font(.body)
                        .foregroundColor(.secondary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(.tertiaryLabel))
                }
                .padding(12)
                .background(.white)
                .border(Color(.tertiaryLabel).opacity(0.2))
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
                .background(.white)
                .border(Color(.tertiaryLabel).opacity(0.2))
                .cornerRadius(10)
        }
    }
    
    private var saveButton: some View {
        Button(action: saveVitals) {
            Label("Save Vitals", systemImage: "square.and.arrow.down")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
        }
        .buttonStyle(.borderedProminent)
        .tint(primaryColor)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private var patientSearchView: some View {
        VStack {
            VStack(spacing: 20) {
                Image(systemName: "stethoscope")
                    .font(.system(size: 48))
                    .foregroundColor(primaryColor)
                
                Text("Enter Patient ID")
                    .font(.title2.bold())
                
                // Search field and button
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(primaryColor)
                        TextField("Patient ID", text: $patientID)
                            .textFieldStyle(.plain)
                            .background(.white)
                            .foregroundStyle(.black)
                    }
                    .padding(12)
                    .background(.white)
                    .cornerRadius(10)
                    
                    Button(action: checkPatient) {
                        Label("Find Patient", systemImage: "person.crop.circle.badge.checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(primaryColor)
                }
                .padding(.horizontal)
            }
            .padding(.top, 40)
            Spacer()
        }
        .navigationTitle("Vitals Entry")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func pickerSheet(for item: ActiveSheet) -> some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .frame(width: 36, height: 5)
                .foregroundColor(Color(.systemGray5))
                .padding(.top, 8)
                .padding(.bottom, 16)
            
            // Picker content
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
            
            // Done button
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
    
    // MARK: - Functions
    
    private func checkPatient() {
        guard !patientID.isEmpty else {
            showAlert(message: "Please enter a patient ID.")
            return
        }
        
        startLoading()
        
        FirebaseService.shared.patientExists(patientID: patientID) { result in
            stopLoading()
            
            switch result {
            case .success(let exists):
                if exists {
                    fetchPatientDetails()
                } else {
                    showAlert(message: "Patient with ID \(patientID) not found.")
                }
            case .failure(let error):
                showAlert(message: "Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchPatientDetails() {
        startLoading()
        
        FirebaseService.shared.fetchPatientName(patientID: patientID) { result in
            switch result {
            case .success(let name):
                patientName = name
                fetchPatientVitals()
            case .failure(let error):
                stopLoading()
                print("Error fetching name: \(error.localizedDescription)")
                patientFound = true
            }
        }
    }
    
    private func fetchPatientVitals() {
        FirebaseService.shared.fetchPatientVitals(patientID: patientID) { result in
            stopLoading()
            
            switch result {
            case .success(let vitals):
                populateVitals(vitals)
                patientFound = true
            case .failure(let error):
                showAlert(message: "Error loading vitals: \(error.localizedDescription)")
                patientFound = true
            }
        }
    }
    
    private func saveVitals() {
        uploadVitals()
        resetForm()
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
        
        FirebaseService.shared.savePatientVitals(patientID: patientID, vitals: vitalsData) { result in
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
    
    private func resetForm() {
        patientFound = false
        patientName = ""
        bpSystolic = 120
        bpDiastolic = 80
        weight = 70.0
        height = 170.0
        allergies = ""
        heartRate = 72
        temperature = 98.6
        patientID = ""
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

// MARK: - Picker Components

struct IntPicker: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let title: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("\(value) \(unit)")
                .font(.title2.bold())
                .foregroundColor(.primary)
            
            Picker("", selection: $value) {
                ForEach(Array(range), id: \.self) { num in
                    Text("\(num)")
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(height: 120)
        }
    }
}

struct DecimalPicker: View {
    @Binding var value: Double
    let range: ClosedRange<Int>
    let title: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(String(format: value.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f %@" : "%.1f %@", value, unit))
                .font(.title2.bold())
                .foregroundColor(.primary)
            
            HStack(spacing: 0) {
                Picker("", selection: Binding(
                    get: { Int(value) },
                    set: { value = Double($0) + (value - Double(Int(value))) }
                )) {
                    ForEach(Array(range), id: \.self) { num in
                        Text("\(num)")
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                .frame(width: 100)
                
                Text(".")
                    .font(.title2.bold())
                
                Picker("", selection: Binding(
                    get: { Int((value - Double(Int(value))) * 10) },
                    set: { value = Double(Int(value)) + Double($0) / 10.0 }
                )) {
                    ForEach(0..<10, id: \.self) { num in
                        Text("\(num)")
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                .frame(width: 80)
            }
            .frame(height: 120)
        }
    }
}

// MARK: - Previews

struct NurseVitalsEntryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NurseVitalsEntryView()
                .preferredColorScheme(.light)
            
            NurseVitalsEntryView()
                .preferredColorScheme(.dark)
        }
    }
}
