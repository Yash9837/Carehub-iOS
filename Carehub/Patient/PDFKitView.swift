import SwiftUI
import PDFKit

struct PDFKitViewPatient: View {
    let url: URL
    
    var body: some View {
        PDFKitRepresentable(url: url)
            .navigationTitle("Prescription")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct PDFKitRepresentable: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        print("Loading PDF from URL: \(url)")
        if let document = PDFDocument(url: url) {
            pdfView.document = document
            print("Successfully loaded PDF document")
        } else {
            print("Failed to load PDF document from URL: \(url)")
        }
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        // Update if needed; not required for static PDFs
    }
}
