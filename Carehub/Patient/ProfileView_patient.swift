import SwiftUI

struct ProfileView_patient: View {
    let patient: PatientF
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
                                    Text(patient.userData.Name)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.black)
                                    Text("ID: \(patient.patientId)")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                                    Text("Username: \(patient.username)")
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
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Personal Information")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                                .padding(.horizontal, 16)
                            
                            ProfileRow(title: "Patient ID", value: patient.patientId, icon: "number")
                            ProfileRow(title: "Full Name", value: patient.userData.Name, icon: "person.fill")
                            ProfileRow(title: "Date of Birth", value: patient.userData.Dob, icon: "calendar")
                            ProfileRow(title: "Username", value: patient.username, icon: "person.fill")
                            ProfileRow(title: "Email", value: patient.userData.Email, icon: "envelope.fill")
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
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Contact Information")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                                .padding(.horizontal, 16)
                            
                            ProfileRow(title: "Phone Number", value: patient.userData.phoneNo, icon: "phone.fill")
                            ProfileRow(title: "Address", value: patient.userData.Address, icon: "house.fill")
                            ProfileRow(title: "Aadhar Number", value: patient.userData.aadharNo.isEmpty ? "Not Provided" : patient.userData.aadharNo, icon: "person.text.rectangle")
                            
                            MultiItemProfileRow(
                                title: "Emergency Contacts",
                                value: patient.emergencyContact.map { "\($0.name) (\($0.Number))" }.joined(separator: ", "),
                                icon: "person.fill"
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
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Medical Information")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                                .padding(.horizontal, 16)
                            
                            MultiItemProfileRow(
                                title: "Allergies",
                                value: patient.vitals.allergies.joined(separator: ", "),
                                icon: "allergens"
                            )
                            
                            ProfileRow(
                                title: "Latest Blood Pressure",
                                value: patient.vitals.bp.last?.value ?? "Not Recorded",
                                icon: "heart.fill"
                            )
                            
                            ProfileRow(
                                title: "Latest Heart Rate",
                                value: patient.vitals.heartRate.last?.value ?? "Not Recorded",
                                icon: "heart.fill"
                            )
                            
                            ProfileRow(
                                title: "Latest Height",
                                value: patient.vitals.height.last?.value ?? "Not Recorded",
                                icon: "ruler"
                            )
                            
                            ProfileRow(
                                title: "Latest Temperature",
                                value: patient.vitals.temperature.last?.value ?? "Not Recorded",
                                icon: "thermometer"
                            )
                            
                            ProfileRow(
                                title: "Latest Weight",
                                value: patient.vitals.weight.last?.value ?? "Not Recorded",
                                icon: "scalemass"
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
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Button(action: {
                                UserDefaults.standard.removeObject(forKey: "patientF")
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
            .navigationBarTitleDisplayMode(.large)
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

struct MultiItemProfileRow: View {
    let title: String
    let value: String
    let icon: String
    
    private var items: [String] {
        if value.isEmpty {
            return ["None"]
        } else {
            return value.components(separatedBy: ", ")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
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
            
            if items.count == 1 {
                Text(items[0])
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)
                    .padding(.leading, 36)
            } else {
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
                .padding(.leading, 36)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}

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
    let patient: PatientF
    @State private var fullName: String
    @State private var email: String
    @State private var dob: String
    @State private var phoneNo: String
    @State private var address: String
    @State private var aadharNo: String
    @State private var emergencyContacts: [EmergencyContact]
    @State private var allergies: [String]
    @Environment(\.dismiss) private var dismiss
    
    init(patient: PatientF) {
        self.patient = patient
        self._fullName = State(initialValue: patient.userData.Name)
        self._email = State(initialValue: patient.userData.Email)
        self._dob = State(initialValue: patient.userData.Dob)
        self._phoneNo = State(initialValue: patient.userData.phoneNo)
        self._address = State(initialValue: patient.userData.Address)
        self._aadharNo = State(initialValue: patient.userData.aadharNo)
        self._emergencyContacts = State(initialValue: patient.emergencyContact)
        self._allergies = State(initialValue: patient.vitals.allergies)
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.94, blue: 1.0)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 16) {
                    personalInfoSection
                    contactInfoSection
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
                Text("Email")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
                
                TextField("Email", text: $email)
                    .font(.system(size: 16))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Date of Birth (DD/MM/YYYY)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
                
                TextField("Date of Birth", text: $dob)
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
    
    private var contactInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contact Information")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                .padding(.horizontal, 16)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Phone Number")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
                
                TextField("Phone Number", text: $phoneNo)
                    .font(.system(size: 16))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Address")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
                
                TextField("Address", text: $address)
                    .font(.system(size: 16))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Aadhar Number (Optional)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
                
                TextField("Aadhar Number", text: $aadharNo)
                    .font(.system(size: 16))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            
            EditableEmergencyContactsSection(
                title: "Emergency Contacts",
                contacts: $emergencyContacts
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
    
    private var medicalInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Medical Information")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                .padding(.horizontal, 16)
            
            EditableItemsSection(
                title: "Allergies",
                placeholder: "Allergy",
                items: $allergies,
                addButtonLabel: "Add Allergy"
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
            let updatedPatient = PatientF(
                emergencyContact: emergencyContacts,
                medicalRecords: patient.medicalRecords,
                testResults: patient.testResults,
                userData: UserData(
                    Address: address,
                    Dob: dob,
                    Email: email,
                    Name: fullName,
                    Password: patient.userData.Password,
                    aadharNo: aadharNo,
                    phoneNo: phoneNo
                ),
                vitals: Vitals(
                    allergies: allergies,
                    bp: patient.vitals.bp,
                    heartRate: patient.vitals.heartRate,
                    height: patient.vitals.height,
                    temperature: patient.vitals.temperature,
                    weight: patient.vitals.weight
                ),
                lastModified: Date(),
                patientId: patient.patientId,
                username: patient.username
            )
            
            if let encoded = try? JSONEncoder().encode(updatedPatient) {
                UserDefaults.standard.set(encoded, forKey: "patientF")
            }
            
            dismiss()
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

struct EditableEmergencyContactsSection: View {
    let title: String
    @Binding var contacts: [EmergencyContact]
    @State private var newContactName: String = ""
    @State private var newContactNumber: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 16)
            
            ForEach(contacts) { contact in
                HStack {
                    VStack(alignment: .leading) {
                        TextField("Name", text: .constant(contact.name))
                            .font(.system(size: 16))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                            .disabled(true)
                        
                        TextField("Number", text: .constant(contact.Number))
                            .font(.system(size: 16))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                            .disabled(true)
                    }
                    
                    Button(action: {
                        withAnimation {
                            contacts.removeAll { $0.id == contact.id }
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 22))
                    }
                    .padding(.trailing, 8)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                TextField("New Contact Name", text: $newContactName)
                    .font(.system(size: 16))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                
                TextField("New Contact Number", text: $newContactNumber)
                    .font(.system(size: 16))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            
            Button(action: {
                if !newContactName.isEmpty && !newContactNumber.isEmpty {
                    withAnimation {
                        contacts.append(EmergencyContact(Number: newContactNumber, name: newContactName))
                        newContactName = ""
                        newContactNumber = ""
                    }
                }
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Contact")
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
            }
        }
    }
}

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
            
            if items.isEmpty {
                addButton
            } else {
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
                    var updatedItems = items
                    updatedItems.remove(at: index)
                    items = updatedItems
                }
            }) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 22))
            }
            .padding(.trailing, 8)
        }
    }
    
    private var addButton: some View {
        Button(action: {
            withAnimation {
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
    let samplePatient = PatientF(
        emergencyContact: [EmergencyContact(Number: "1234567890", name: "Emergency Contact")],
        medicalRecords: [],
        testResults: [],
        userData: UserData(
            Address: "123 Main St, City",
            Dob: "01/01/1990",
            Email: "john@example.com",
            Name: "John Doe",
            Password: "hashedpassword",
            aadharNo: "123456789012",
            phoneNo: "9876543210"
        ),
        vitals: Vitals(
            allergies: ["Peanuts"],
            bp: [VitalEntry(timestamp: Date(), value: "120/80")],
            heartRate: [VitalEntry(timestamp: Date(), value: "72")],
            height: [VitalEntry(timestamp: Date(), value: "175 cm")],
            temperature: [VitalEntry(timestamp: Date(), value: "36.6°C")],
            weight: [VitalEntry(timestamp: Date(), value: "70 kg")]
        ),
        lastModified: Date(),
        patientId: "P123456",
        username: "johndoe123"
    )
    ProfileView_patient(patient: samplePatient)
}
