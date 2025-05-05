import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import UniformTypeIdentifiers

// UIViewControllerRepresentable to handle PDF picking on iOS
struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var pdfURL: URL?
    var onPDFSelected: (URL) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf], asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                parent.pdfURL = url
                parent.onPDFSelected(url)
                parent.presentationMode.wrappedValue.dismiss()
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct UpdateTestView: View {
    let medicalTestId: String
    @State private var isCompleted: Bool = false
    @State private var isLoading = false
    @State private var pdfURL: URL? = nil
    @State private var isShowingPDFPicker = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.94, blue: 1.0)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Header
                Text("Update Medical Test Reports")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                    .padding(.top, 20)
                
                // Form Fields
                VStack(spacing: 15) {
                    // Status Toggle
                    HStack {
                        Text("Status : ")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Toggle(isOn: $isCompleted) {
                            Text(isCompleted ? "Completed" : "Pending")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        .tint(.green)
                    }
                    .padding(.horizontal, 20)
                    
                    // PDF Upload
                   Button(action: {
                        isShowingPDFPicker = true
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: "document.badge.plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                            
                            Text(pdfURL?.lastPathComponent ?? "Select PDF")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 20)
                    .sheet(isPresented: $isShowingPDFPicker) {
                        DocumentPicker(pdfURL: $pdfURL, onPDFSelected: uploadPDF)
                    }
                }
                .padding(.horizontal, 20)
                
                // Save Button
                Button(action: {
                    saveChanges()
                }) {
                    Text("Save Changes")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.43, green: 0.34, blue: 0.99),
                                    Color(red: 0.55, green: 0.48, blue: 0.99)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                }
                .padding(.horizontal, 20)
                .disabled(isLoading)
                
                Spacer()
            }
            .navigationBarTitle("", displayMode: .inline)
            .onAppear {
                loadTestData()
            }
        }
    }
    
    private func loadTestData() {
        isLoading = true
        let db = Firestore.firestore()
        db.collection("medicalTests").document(medicalTestId).getDocument { (doc, error) in
            isLoading = false
            if let doc = doc, doc.exists, let data = doc.data() {
                let status = data["status"] as? String ?? "Pending"
                isCompleted = (status == "Completed")
            } else {
                print("Error or document not found: \(error?.localizedDescription ?? "No error details")")
            }
        }
    }
    
    private func saveChanges() {
        isLoading = true
        let db = Firestore.firestore()
        var data: [String: Any] = [
            "status": isCompleted ? "Completed" : "Pending"
        ]
        
        let dispatchGroup = DispatchGroup()
        
        if let pdfURL = pdfURL {
            let storageRef = Storage.storage().reference().child("medicalTests/\(medicalTestId)/result.pdf")
            dispatchGroup.enter()
            storageRef.putFile(from: pdfURL, metadata: nil) { metadata, error in
                if let error = error {
                    print("Upload failed: \(error.localizedDescription)")
                    dispatchGroup.leave()
                    isLoading = false
                    return
                }
                storageRef.downloadURL { url, error in
                    defer { dispatchGroup.leave() }
                    if let downloadURL = url {
                        print("Download URL retrieved: \(downloadURL.absoluteString)")
                        data["pdfUrl"] = downloadURL.absoluteString
                    } else if let error = error {
                        print("Error getting download URL: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            db.collection("medicalTests").document(medicalTestId).updateData(data) { error in
                isLoading = false
                if let error = error {
                    print("Error updating document: \(error.localizedDescription)")
                } else {
                    print("Document updated successfully with data: \(data)")
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    private func uploadPDF(to url: URL) {
        pdfURL = url
    }
}
