import SwiftUI
import FirebaseFirestore
import UniformTypeIdentifiers

struct PrescriptionView: View {
    let appointment: Appointment
    @State private var showActionSheet = false
    @State private var showImagePicker = false
    @State private var showDocumentPicker = false
    @State private var selectedImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isUploading = false
    @State private var uploadStatus: String = ""
    
    private let db = Firestore.firestore()
    
    var body: some View {
        VStack {
            if isUploading {
                ProgressView("Uploading...")
            } else if !uploadStatus.isEmpty {
                Text(uploadStatus)
                    .foregroundColor(uploadStatus.contains("success") ? .green : .red)
                    .padding()
            }
            
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .padding()
            } else if let currentURLString = appointment.prescriptionId, !currentURLString.isEmpty {
                AsyncImage(url: URL(string: currentURLString)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .padding()
                    case .failure:
                        Text("Failed to load prescription image")
                            .foregroundColor(.red)
                            .padding()
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            Button(action: {
                print("Button clicked")
                showActionSheet = true
            }) {
                Text(appointment.prescriptionId == nil ? "Select File" : "Change Prescription")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("Add Prescription")
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("Select Prescription Source"),
                buttons: [
                    .default(Text("Camera")) {
                        sourceType = .camera
                        showImagePicker = true
                    },
                    .default(Text("Photo Library")) {
                        sourceType = .photoLibrary
                        showImagePicker = true
                    },
                    .default(Text("Document")) {
                        showDocumentPicker = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showImagePicker) {
            PrescriptionImagePicker(image: $selectedImage, sourceType: sourceType, onImagePicked: uploadPrescription)
        }
        .sheet(isPresented: $showDocumentPicker) {
            PrescriptionDocumentPicker { url in
                uploadDocument(url: url)
            }
        }
    }
    
    private func uploadPrescription(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            uploadStatus = "Error processing image"
            return
        }
        
        isUploading = true
        uploadStatus = ""
        
        // Simulate upload to Firebase Storage
        let newURL = "simulated_url_\(UUID().uuidString).jpg"
        updatePrescriptionURL(newURL: newURL)
    }
    
    private func uploadDocument(url: URL) {
        isUploading = true
        uploadStatus = ""
        
        // Simulate document upload
        let newURL = "simulated_url_\(UUID().uuidString)_\(url.lastPathComponent)"
        updatePrescriptionURL(newURL: newURL)
    }
    
    private func updatePrescriptionURL(newURL: String) {
        let prescriptionRef = db.collection("appointments").document(appointment.id)
        
        prescriptionRef.updateData([
            "prescriptionId": newURL,
            "Status": "Completed" // Update status to Completed
        ]) { error in
            isUploading = false
            if let error = error {
                uploadStatus = "Upload failed: \(error.localizedDescription)"
            } else {
                uploadStatus = "Prescription uploaded successfully"
            }
        }
    }
}

struct PrescriptionImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: PrescriptionImagePicker
        
        init(_ parent: PrescriptionImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                parent.onImagePicked(uiImage)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

struct PrescriptionDocumentPicker: UIViewControllerRepresentable {
    let onDocumentPicked: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .image])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: PrescriptionDocumentPicker
        
        init(_ parent: PrescriptionDocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                parent.onDocumentPicked(url)
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            controller.dismiss(animated: true)
        }
    }
}

#Preview {
    PrescriptionView(appointment: Appointment(
        id: "1",
        apptId: "APPT001",
        patientId: "PAT001",
        description: "Checkup",
        docId: "DOC001",
        status: "Scheduled",
        billingStatus: "",
        amount: nil,
        date: Date(),
        doctorsNotes: nil,
        prescriptionId: nil,
        followUpRequired: nil,
        followUpDate: nil
    ))
}

