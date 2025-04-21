import SwiftUI

struct ProfileView_patient: View {
    let patient: Patient
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.94, green: 0.94, blue: 1.0)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(spacing: 12) {
                            HStack(spacing: 16) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.43, green: 0.34, blue: 0.99),
                                                Color(red: 0.55, green: 0.48, blue: 0.99)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(Circle())
                                    .shadow(color: Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.3), radius: 5, x: 0, y: 3)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(patient.fullName)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.black)
                                    Text("ID: \(patient.generatedID)")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                                }
                                Spacer()
                            }
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        
                        // Personal Information Card - No changes needed
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Personal Information")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                                .padding(.horizontal, 16)
                            
                            ProfileRow(title: "Patient ID", value: patient.generatedID, icon: "number")
                            ProfileRow(title: "Full Name", value: patient.fullName, icon: "person.fill")
                            ProfileRow(title: "Age", value: patient.age, icon: "calendar")
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        
                        // Updated Medical Information Card
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Medical Information")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                                .padding(.horizontal, 16)
                            
                            // Updated to use the new MultiItemProfileRow for medical information
                            MultiItemProfileRow(
                                title: "Previous Problems",
                                value: patient.previousProblems,
                                icon: "bandage"
                            )
                            
                            MultiItemProfileRow(
                                title: "Allergies",
                                value: patient.allergies,
                                icon: "allergens"
                            )
                            
                            MultiItemProfileRow(
                                title: "Current Medications",
                                value: patient.medications,
                                icon: "pills"
                            )
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        
                        // Actions Card - No changes needed
                        VStack(alignment: .leading, spacing: 8) {
                            Button(action: {
                                // Handle sign-out logic
                            }) {
                                Label("Sign Out", systemImage: "arrow.right.circle")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.red)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: EditProfileView(patient: patient)) {
                        Text("Edit")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                    }
                }
            }
        }
    }
}

// Keep the original ProfileRow for simple values
struct ProfileRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.gray)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}

// New component to handle multiple items in a category
struct MultiItemProfileRow: View {
    let title: String
    let value: String
    let icon: String
    
    // Process the comma-separated string into an array
    private var items: [String] {
        if value.isEmpty {
            return ["None"]
        } else {
            return value.components(separatedBy: ", ")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header row with icon and title
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            // Items displayed as pills/tags if multiple, otherwise as text
            if items.count == 1 {
                // If only one item (or "None"), display as regular text
                Text(items[0])
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)
                    .padding(.leading, 36) // Align with title text
            } else {
                // Multiple items - display as wrapped tags
                FlowLayout(spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(red: 0.95, green: 0.95, blue: 1.0))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 0.85, green: 0.85, blue: 1.0), lineWidth: 1)
                            )
                    }
                }
                .padding(.leading, 36) // Align with title text
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}

// Helper view to create a flowing layout of tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 10
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        for view in subviews {
            let viewSize = view.sizeThatFits(.unspecified)
            if x + viewSize.width > width {
                // Move to next row
                x = 0
                y += maxHeight + spacing
                maxHeight = 0
            }
            
            maxHeight = max(maxHeight, viewSize.height)
            x += viewSize.width + spacing
            height = max(height, y + maxHeight)
        }
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        var x = bounds.minX
        var y = bounds.minY
        var maxHeight: CGFloat = 0
        
        for view in subviews {
            let viewSize = view.sizeThatFits(.unspecified)
            if x + viewSize.width > bounds.maxX {
                // Move to next row
                x = bounds.minX
                y += maxHeight + spacing
                maxHeight = 0
            }
            
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: viewSize.width, height: viewSize.height))
            maxHeight = max(maxHeight, viewSize.height)
            x += viewSize.width + spacing
        }
    }
}

struct EditProfileView: View {
    let patient: Patient
    @State private var fullName: String
    @State private var age: String
    
    // Separate arrays for each medical information category
    @State private var previousProblems: [String] = []
    @State private var allergies: [String] = []
    @State private var medications: [String] = []
    
    init(patient: Patient) {
        self.patient = patient
        self._fullName = State(initialValue: patient.fullName)
        self._age = State(initialValue: patient.age)
        
        // Split the initial values by comma if they contain multiple items
        self._previousProblems = State(initialValue: patient.previousProblems.isEmpty ?
            [] : patient.previousProblems.components(separatedBy: ", "))
        self._allergies = State(initialValue: patient.allergies.isEmpty ?
            [] : patient.allergies.components(separatedBy: ", "))
        self._medications = State(initialValue: patient.medications.isEmpty ?
            [] : patient.medications.components(separatedBy: ", "))
    }
    
    // Breaking the body into smaller components
    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.94, blue: 1.0)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 16) {
                    personalInfoSection
                    medicalInfoSection
                    saveButton
                }
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Extracted View Components
    
    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Information")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                .padding(.horizontal, 16)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Full Name")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
                
                TextField("Full Name", text: $fullName)
                    .font(.system(size: 16))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Age")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
                
                TextField("Age", text: $age)
                    .font(.system(size: 16))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private var medicalInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Medical Information")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                .padding(.horizontal, 16)
            
            // Previous Problems
            EditableItemsSection(
                title: "Previous Problems",
                placeholder: "Problem",
                items: $previousProblems,
                addButtonLabel: "Add Problem"
            )
            
            // Allergies
            EditableItemsSection(
                title: "Allergies",
                placeholder: "Allergy",
                items: $allergies,
                addButtonLabel: "Add Allergy"
            )
            
            // Medications
            EditableItemsSection(
                title: "Current Medications",
                placeholder: "Medication",
                items: $medications,
                addButtonLabel: "Add Medication"
            )
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private var saveButton: some View {
        Button(action: {
            // Join arrays into comma-separated strings and save
            let updatedPatient = Patient(
                fullName: fullName,
                generatedID: patient.generatedID,
                age: age,
                previousProblems: previousProblems.filter { !$0.isEmpty }.joined(separator: ", "),
                allergies: allergies.filter { !$0.isEmpty }.joined(separator: ", "),
                medications: medications.filter { !$0.isEmpty }.joined(separator: ", ")
            )
            // Here you would handle saving the updated patient data
        }) {
            Text("Save Changes")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
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
                .cornerRadius(10)
                .shadow(color: Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.3), radius: 5, x: 0, y: 3)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// Extracted reusable component for editable sections
struct EditableItemsSection: View {
    let title: String
    let placeholder: String
    @Binding var items: [String]
    let addButtonLabel: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 16)
            
            // If empty, show add button immediately
            if items.isEmpty {
                addButton
            } else {
                // Otherwise show the list of items
                ForEach(items.indices, id: \.self) { index in
                    itemRow(for: index)
                }
                
                addButton
            }
        }
    }
    
    private func itemRow(for index: Int) -> some View {
        HStack {
            TextField(placeholder, text: $items[index])
                .font(.system(size: 16))
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            
            Button(action: {
                withAnimation {
                    // Fix for ambiguous 'remove(at:)' error
                    var updatedItems = items
                    updatedItems.remove(at: index)
                    items = updatedItems
                }
            }) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 22))
            }
            .padding(.trailing, 8)  // Fixed: using correct number format
        }
    }
    
    private var addButton: some View {
        Button(action: {
            withAnimation {
                // Fix for potential ambiguous append error
                var updatedItems = items
                updatedItems.append("")
                items = updatedItems
            }
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text(addButtonLabel)
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    let samplePatient = Patient(
        fullName: "John Doe",
        generatedID: "P123456",
        age: "30",
        previousProblems: "Asthma",
        allergies: "Peanuts",
        medications: "Inhaler"
    )
    return ProfileView_patient(patient: samplePatient)
}
