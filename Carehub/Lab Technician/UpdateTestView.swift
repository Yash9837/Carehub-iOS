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


import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import UniformTypeIdentifiers

// ... [Keep the DocumentPicker struct unchanged] ...

struct UpdateTestView: View {
    let medicalTestId: String
    @State private var isCompleted: Bool = false
    @State private var isLoading = false
    @State private var pdfURL: URL? = nil
    @State private var isShowingPDFPicker = false
    @State private var firestoreDocumentId: String? = nil
    @State private var showValidationError = false // Combined error state
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
                }
                .padding(.horizontal, 20)
                
                // Save Button
                Button(action: {
                    validateAndSave()
                }) {
                    ZStack {
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
                        
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.2)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .disabled(isLoading)
                
                Spacer()
            }
            .navigationBarTitle("", displayMode: .inline)
            .onAppear {
                loadTestData()
            }
            .alert(isPresented: $showValidationError) {
                Alert(
                    title: Text("Cannot Save Changes"),
                    message: Text(validationErrorMessage()),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func validationErrorMessage() -> String {
        var errors = [String]()
        
        if !isCompleted {
            errors.append("• Status must be set to 'Completed'")
        }
        
        if pdfURL == nil {
            errors.append("• You must select a PDF file")
        }
        
        return errors.joined(separator: "\n")
    }
    
    private func validateAndSave() {
        guard isCompleted else {
            showValidationError = true
            return
        }
        
        guard pdfURL != nil else {
            showValidationError = true
            return
        }
        
        saveChanges()
    }
    
    private func loadTestData() {
        isLoading = true
        let db = Firestore.firestore()
        
        db.collection("medicalTests")
            .whereField("id", isEqualTo: medicalTestId)
            .getDocuments { (querySnapshot, error) in
                isLoading = false
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                    return
                }
                
                guard let document = querySnapshot?.documents.first else {
                    print("No matching document found")
                    return
                }
                
                self.firestoreDocumentId = document.documentID
                let data = document.data()
                let status = data["status"] as? String ?? "Pending"
                isCompleted = (status == "Completed")
            }
    }
    
    private func saveChanges() {
        guard let firestoreDocumentId = firestoreDocumentId else {
            print("No Firestore document ID found")
            isLoading = false
            return
        }
        
        guard let pdfURL = pdfURL else {
            print("No PDF selected")
            isLoading = false
            return
        }
        
        isLoading = true
        let db = Firestore.firestore()
        var data: [String: Any] = [
            "status": "Completed" // Force status to be Completed since we validated
        ]
        
        let dispatchGroup = DispatchGroup()
        
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
                    data["pdfUrl"] = downloadURL.absoluteString
                } else if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            db.collection("medicalTests").document(firestoreDocumentId).updateData(data) { error in
                isLoading = false
                if let error = error {
                    print("Error updating document: \(error.localizedDescription)")
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    private func uploadPDF(to url: URL) {
        pdfURL = url
    }
}
