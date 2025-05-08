//
//  ChatViewModel.swift
//  Carehub
//
//  Created by Yash Gupta on 08/05/25.
//


//
//  ChatViewModel.swift
//  chatwat
//
//  Created by Yash Gupta on 07/05/25.
//

//
//  ChatViewModel.swift
//  chatwat
//
//  Created by Yash Gupta on 07/05/25.
//

import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let geminiService = GeminiService.shared
    
    init() {
        addWelcomeMessage()
    }
    
    private func addWelcomeMessage() {
        messages.append(ChatMessage(
            id: UUID(),
            role: .doctor,
            content: "Hello! I'm your Health Assistant powered by Gemini. I can help you understand your symptoms and suggest which doctor to consult. Please describe your symptoms or health concerns (e.g., 'I have a fever and cough'). Note: I am not a doctor, so for a proper diagnosis, please consult a healthcare professional.",
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
               let response = try await GeminiService.shared.sendMessage(tempInput)
               
               messages.append(ChatMessage(
                   id: UUID(),
                   role: .doctor,
                   content: response,
                   timestamp: Date()
               ))
           } catch {
               handleNetworkError(error)
           }
           
           isLoading = false
       }
       
       private func handleNetworkError(_ error: Error) {
           let errorMessage: String
           
           if let urlError = error as? URLError {
               switch urlError.code {
               case .notConnectedToInternet, .networkConnectionLost:
                   errorMessage = "Network connection lost. Please check your internet."
               case .timedOut:
                   errorMessage = "Request timed out. Please try again."
               default:
                   errorMessage = "Network error: \(urlError.localizedDescription)"
               }
           } else {
               errorMessage = "Error: \(error.localizedDescription)"
           }
           
           DispatchQueue.main.async {
               self.messages.append(ChatMessage(
                   id: UUID(),
                   role: .doctor,
                   content: "⚠️ \(errorMessage)",
                   timestamp: Date()
               ))
               self.showError = true
               self.errorMessage = errorMessage
           }
           
           print("❌ Network Error: \(error)")
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
