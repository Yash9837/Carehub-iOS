//
//  NotesView.swift
//  Carehub
//
//  Created by user@76 on 27/04/25.
//


import SwiftUI
import FirebaseFirestore

struct NotesView: View {
    let appointment: Appointment
    @State private var notes: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @Environment(\.dismiss) private var dismiss
    
    private let db = Firestore.firestore()
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    
    init(appointment: Appointment) {
        self.appointment = appointment
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            Text("Add Notes for Appointment")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundColor(.primary)
                .padding(.top, 16)
            
            // Text Editor
            TextEditor(text: $notes)
                .font(.system(.body, design: .rounded))
                .frame(minHeight: 200)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(purpleColor, lineWidth: 1)
                )
            
            // Buttons
            HStack(spacing: 16) {
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .font(.system(.body, design: .rounded, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    saveNotes()
                }) {
                    Text("Save")
                        .font(.system(.body, design: .rounded, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(purpleColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Notes"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                if alertMessage.contains("successfully") {
                    dismiss()
                }
            })
        }
        .navigationTitle("Notes")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchNotes()
        }
    }
    
    private func fetchNotes() {
        db.collection("doctors")
            .document(appointment.docId)
            .collection("notes")
            .document(appointment.apptId)
            .getDocument { document, error in
                if let error = error {
                    alertMessage = "Error fetching notes: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                
                if let document = document, document.exists {
                    notes = document.get("note") as? String ?? ""
                } else {
                    // If no notes exist, try to load from appointment.doctorsNotes
                    notes = appointment.doctorsNotes ?? ""
                }
            }
    }
    
    private func saveNotes() {
        // Ensure notes is not empty
        guard !notes.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Please enter some notes before saving."
            showAlert = true
            return
        }
        
        let notesData: [String: Any] = [
            "patientID": appointment.patientId,
            "appointmentID": appointment.apptId,
            "note": notes,
            "timestamp": Timestamp(date: Date())
        ]
        
        print("Saving to: doctors/\(appointment.docId)/notes/\(appointment.apptId)")
        
        db.collection("doctors")
            .document(appointment.docId)
            .collection("notes")
            .document(appointment.apptId)
            .setData(notesData, merge: true) { error in
                if let error = error {
                    alertMessage = "Error saving notes: \(error.localizedDescription)"
                } else {
                    alertMessage = "Notes saved successfully"
                    // Update the appointments collection as well to keep it in sync
                    db.collection("appointments")
                        .document(appointment.id)
                        .updateData(["doctorsNotes": notes]) { updateError in
                            if let updateError = updateError {
                                print("Error updating appointments collection: \(updateError.localizedDescription)")
                            }
                        }
                    fetchNotes() // Refresh the UI
                }
                showAlert = true
            }
    }
}


#Preview {
    NotesView(appointment: Appointment(
        id: "1",
        apptId: "APT5A1D18",
        patientId: "PT001",
        description: "Mild Headache",
        docId: "DOC001",
        status: "scheduled",
        billingStatus: "unpaid",
        amount: 300.0,
        date: Date(),
        doctorsNotes: "Hiwhen chdnk nsjdjad",
        prescriptionId: nil,
        followUpRequired: false,
        followUpDate: nil
    ))
}
