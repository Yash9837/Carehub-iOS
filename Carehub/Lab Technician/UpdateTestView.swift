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
    @State private var status: String = ""
    @State private var notes: String = ""
    @State private var results: String = ""
    @State private var selectedStatus: String = "Pending"
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
                Text("Medical Test")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                    .padding(.top, 20)
                
                // Form Fields
                VStack(spacing: 15) {
                    // Status Dropdown
                    Text("Update Status")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    Picker("Select Status", selection: $selectedStatus) {
                        Text("Pending").tag("Pending")
                        Text("Completed").tag("Completed")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                    
                    // Notes
                    Text("Add Notes")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    TextField("Enter notes here", text: $notes)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                    
                    // Results
                    Text("Test Results")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    TextField("Enter results here", text: $results)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                    
                    // PDF Upload
                    Text("Upload Test Reports")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    Button(action: {
                        isShowingPDFPicker = true
                    }) {
                        Text("Select Pdf Report")
                            .font(.system(size: 16, weight: .semibold))
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
                    .sheet(isPresented: $isShowingPDFPicker) {
                        DocumentPicker(pdfURL: $pdfURL, onPDFSelected: uploadPDF)
                    }
                    
                    if let pdfURL = pdfURL {
                        Text("Selected PDF: \(pdfURL.lastPathComponent)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
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
                status = data["status"] as? String ?? ""
                selectedStatus = status // Sync with dropdown
                notes = data["notes"] as? String ?? ""
                results = data["results"] as? String ?? ""
            } else {
                print("Error or document not found: \(error?.localizedDescription ?? "No error details")")
            }
        }
    }
    
    private func saveChanges() {
        isLoading = true
        let db = Firestore.firestore()
        var data: [String: Any] = [
            "status": selectedStatus,
            "notes": notes,
            "results": results
        ]
        
        let dispatchGroup = DispatchGroup()
        
        if let pdfURL = pdfURL {
            let storageRef = Storage.storage().reference().child("medicalTests/\(medicalTestId)/result.pdf")
            dispatchGroup.enter()
            storageRef.putFile(from: pdfURL, metadata: nil) { metadata, error in
                if let error = error {
                    print("Upload failed: \(error.localizedDescription)")
                    dispatchGroup.leave()
                    isLoading = false // Ensure loading state is reset on error
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
//        else {
//            dispatchGroup.leave() // Leave immediately if no PDF
//        }
        
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
        pdfURL = url // Store the selected URL
    }
}

#Preview {
    UpdateTestView(medicalTestId: "884ADFO9-474D-4507-92DF-FC8D0FBC81A7")
}
