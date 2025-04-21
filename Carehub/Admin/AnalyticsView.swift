// AnalyticsView.swift
struct AnalyticsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Hospital Analytics")
                        .font(.title)
                        .padding()
                    
                    // Placeholder analytics cards
                    HStack(spacing: 15) {
                        AnalyticsCard(title: "Appointments", value: "247", trend: .up(12))
                        AnalyticsCard(title: "Patients", value: "189", trend: .up(5))
                    }
                    
                    HStack(spacing: 15) {
                        AnalyticsCard(title: "Revenue", value: "$48,750", trend: .up(8))
                        AnalyticsCard(title: "Staff", value: "42", trend: .steady)
                    }
                    
                    // Chart placeholder
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .frame(height: 200)
                        .overlay(
                            Text("Appointments Over Time Chart")
                                .foregroundColor(.secondary)
                        )
                        .padding()
                }
                .padding()
            }
            .navigationTitle("Analytics")
        }
    }
}

struct AnalyticsCard: View {
    enum Trend {
        case up(Int)
        case down(Int)
        case steady
    }
    
    let title: String
    let value: String
    let trend: Trend
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Group {
                    switch trend {
                    case .up(let percent):
                        Image(systemName: "arrow.up")
                        Text("\(percent)%")
                    case .down(let percent):
                        Image(systemName: "arrow.down")
                        Text("\(percent)%")
                    case .steady:
                        Image(systemName: "minus")
                        Text("0%")
                    }
                }
                .font(.caption)
                .foregroundColor(trendColor)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var trendColor: Color {
        switch trend {
        case .up: return .green
        case .down: return .red
        case .steady: return .orange
        }
    }
}

// AdminSettingsView.swift
struct AdminSettingsView: View {
    @State private var hospitalName = "City General Hospital"
    @State private var hospitalLogo: UIImage?
    @State private var showImagePicker = false
    @State private var notificationEnabled = true
    @State private var darkModeEnabled = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Hospital Information")) {
                    TextField("Hospital Name", text: $hospitalName)
                    
                    Button {
                        showImagePicker = true
                    } label: {
                        HStack {
                            Text("Hospital Logo")
                            Spacer()
                            if let logo = hospitalLogo {
                                Image(uiImage: logo)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                            } else {
                                Image(systemName: "photo")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                Section(header: Text("Preferences")) {
                    Toggle("Enable Notifications", isOn: $notificationEnabled)
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                }
                
                Section {
                    Button(role: .destructive) {
                        // Handle logout
                    } label: {
                        Text("Log Out")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $hospitalLogo)
            }
        }
    }
}

// ImagePicker.swift (for AdminSettingsView)
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
    }
}