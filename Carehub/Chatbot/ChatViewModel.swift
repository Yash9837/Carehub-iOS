//
//  ChatViewModel.swift
//  Carehub
//
//  Created by Yash Gupta on 08/05/25.
//

import SwiftUI
import FirebaseFirestore

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let geminiService = GeminiService.shared
    private let db = Firestore.firestore()
    
    init() {
        addWelcomeMessage()
    }
    
    private func addWelcomeMessage() {
        messages.append(ChatMessage(
            id: UUID(),
            role: .doctor,
            content: "Hello! I'm your Health Assistant powered by Gemini. I can suggest doctors based on your symptoms. Please describe your symptoms (e.g., 'I have a fever and cough') or select from the options below.",
            timestamp: Date()
        ))
    }
    
    func sendMessage() async {
        guard !inputText.isEmpty else { return }
        
        let userMessage = ChatMessage(
            id: UUID(),
            role: .patient,
            content: inputText,
            timestamp: Date()
        )
        messages.append(userMessage)
        isLoading = true
        let tempInput = inputText
        inputText = ""
        
        do {
            let response = try await geminiService.sendMessage(tempInput)
            let department = extractDepartment(from: response)
            let doctors = try await fetchDoctors(for: department)
            
            if doctors.isEmpty {
                messages.append(ChatMessage(
                    id: UUID(),
                    role: .doctor,
                    content: "No doctors found for \(department). \(response)",
                    timestamp: Date()
                ))
            } else {
                let doctorDetails = doctors.map { doctor in
                    let emailInfo = doctor.email != nil ? "Email: \(doctor.email!)" : ""
                    let phoneInfo = doctor.phoneNo != nil ? "Phone: \(doctor.phoneNo!)" : ""
                    return "Dr. \(doctor.doctor_name) (\(doctor.department), \(doctor.doctor_experience ?? 0) yrs, Fee: \(doctor.consultationFee ?? 0))\n\(emailInfo) \(phoneInfo)"
                }.joined(separator: "\n")
                
                messages.append(ChatMessage(
                    id: UUID(),
                    role: .doctor,
                    content: "Visit a \(department):\n\(doctorDetails)\n\(response)",
                    timestamp: Date()
                ))
            }
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    private func extractDepartment(from response: String) -> String {
        let lowercasedResponse = response.lowercased()
        if lowercasedResponse.contains("cardiologist") || lowercasedResponse.contains("cardiology") {
            return "Cardiology"
        } else if lowercasedResponse.contains("orthopedist") || lowercasedResponse.contains("orthopedics") {
            return "Orthopedics"
        } else if lowercasedResponse.contains("neurologist") || lowercasedResponse.contains("neurology") {
            return "Neurology"
        } else if lowercasedResponse.contains("gynecologist") || lowercasedResponse.contains("gynecology") {
            return "Gynecology"
        } else if lowercasedResponse.contains("surgeon") || lowercasedResponse.contains("surgery") {
            return "Surgery"
        } else if lowercasedResponse.contains("dermatologist") || lowercasedResponse.contains("dermatology") {
            return "Dermatology"
        } else if lowercasedResponse.contains("endocrinologist") || lowercasedResponse.contains("endocrinology") {
            return "Endocrinology"
        } else if lowercasedResponse.contains("ent") {
            return "ENT"
        } else if lowercasedResponse.contains("oncologist") || lowercasedResponse.contains("oncology") {
            return "Oncology"
        } else if lowercasedResponse.contains("psychiatrist") || lowercasedResponse.contains("psychiatry") {
            return "Psychiatry"
        } else if lowercasedResponse.contains("urologist") || lowercasedResponse.contains("urology") {
            return "Urology"
        } else if lowercasedResponse.contains("pediatrician") || lowercasedResponse.contains("pediatrics") {
            return "Pediatrics"
        } else {
            return "General Practitioner"
        }
    }
    
    private func fetchDoctors(for department: String) async throws -> [Doctor] {
        let snapshot = try await db.collection("doctors")
            .whereField("Filed_name", isEqualTo: department)
            .getDocuments()
        
        return try snapshot.documents.compactMap { document in
            try document.data(as: Doctor.self)
        }
    }
    
    private func handleError(_ error: Error) {
        let errorMessage = "Error: \(error.localizedDescription)"
        messages.append(ChatMessage(
            id: UUID(),
            role: .doctor,
            content: "⚠️ \(errorMessage)",
            timestamp: Date()
        ))
        self.showError = true
        self.errorMessage = errorMessage
        print("❌ Error: \(error)")
    }
}

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let role: MessageRole
    let content: String
    let timestamp: Date
    
    enum MessageRole {
        case patient
        case doctor
    }
}

