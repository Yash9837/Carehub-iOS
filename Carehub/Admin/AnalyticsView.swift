import SwiftUI

struct AnalyticsView: View {
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    private let gradientColors = [Color(red: 0.43, green: 0.34, blue: 0.99), Color(red: 0.55, green: 0.48, blue: 0.99)]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.94, green: 0.94, blue: 1.0)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Hospital Analytics")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                            .padding()
                        
                        HStack(spacing: 15) {
                            AnalyticsCard(title: "Appointments", value: "247", trend: .up(12))
                            AnalyticsCard(title: "Patients", value: "189", trend: .up(5))
                        }
                        .padding(.horizontal, 20)
                        
                        HStack(spacing: 15) {
                            AnalyticsCard(title: "Revenue", value: "$48,750", trend: .up(8))
                            AnalyticsCard(title: "Staff", value: "42", trend: .steady)
                        }
                        .padding(.horizontal, 20)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                            Text("Appointments Over Time Chart")
                                .foregroundColor(.gray)
                                .frame(height: 200)
                        }
                        .padding(.horizontal, 20)
                    }
                }
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
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                    
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
                    .font(.system(size: 14))
                    .foregroundColor(trendColor)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var trendColor: Color {
        switch trend {
        case .up: return .green
        case .down: return .red
        case .steady: return .orange
        }
    }
}

struct AdminSettingsView: View {
    @State private var hospitalName = "City General Hospital"
    @State private var hospitalLogo: UIImage?
    @State private var showImagePicker = false
    @State private var notificationEnabled = true
    @State private var darkModeEnabled = false
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    private let gradientColors = [Color(red: 0.43, green: 0.34, blue: 0.99), Color(red: 0.55, green: 0.48, blue: 0.99)]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.94, green: 0.94, blue: 1.0)
                    .edgesIgnoringSafeArea(.all)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                        .padding(.horizontal, 20)
                    
                    Form {
                        Section(header: Text("Hospital Information")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)) {
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
                                            .foregroundColor(purpleColor)
                                    }
                                }
                            }
                        }
                        
                        Section(header: Text("Preferences")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)) {
                            Toggle("Enable Notifications", isOn: $notificationEnabled)
                            Toggle("Dark Mode", isOn: $darkModeEnabled)
                        }
                        
                        Section {
                            Button(role: .destructive) {
                                // Handle logout
                            } label: {
                                Text("Log Out")
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .background(Color.clear)
                }
                .padding(.top, 10)
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
