// StaffManager.swift
class StaffManager: ObservableObject {
    @Published var staffList: [Staff] = []
    
    init() {
        loadSampleData()
    }
    
    func addStaff(_ staff: Staff) {
        staffList.append(staff)
        // In a real app, you would save to database here
    }
    
    func updateStaff(_ updatedStaff: Staff) {
        if let index = staffList.firstIndex(where: { $0.id == updatedStaff.id }) {
            staffList[index] = updatedStaff
            // In a real app, you would update database here
        }
    }
    
    func deleteStaff(_ staff: Staff) {
        staffList.removeAll { $0.id == staff.id }
        // In a real app, you would delete from database here
    }
    
    private func loadSampleData() {
        // Sample data for preview/testing
        staffList = [
            Staff(fullName: "Dr. Sarah Johnson", email: "s.johnson@hospital.com", role: .doctor, department: "Cardiology", phoneNumber: "555-0101"),
            Staff(fullName: "Dr. Michael Chen", email: "m.chen@hospital.com", role: .doctor, department: "Neurology", phoneNumber: "555-0102"),
            Staff(fullName: "Nurse Emma Wilson", email: "e.wilson@hospital.com", role: .nurse, department: "Pediatrics", phoneNumber: "555-0103"),
            Staff(fullName: "Nurse David Brown", email: "d.brown@hospital.com", role: .nurse, department: "Emergency", phoneNumber: "555-0104"),
            Staff(fullName: "Lab Tech Olivia Martinez", email: "o.martinez@hospital.com", role: .labTechnician, department: "Pathology", phoneNumber: "555-0105"),
            Staff(fullName: "Admin James Taylor", email: "j.taylor@hospital.com", role: .admin, department: "Administration", phoneNumber: "555-0106")
        ]
    }
}