//
//  Bills.swift
//  Carehub
//
//  Created by user@87 on 23/04/25.
//

import SwiftUI
import FirebaseFirestore

struct Billing: Identifiable {
    var id: String { billingId }
    var billingId: String
    var bills: [BillItem]
    var appointmentId: String
    var billingStatus: String
    var date: Date
    var doctorId: String
    var insuranceAmt: Double
    var paidAmt: Double
    var patientId: String
    var paymentMode: String
}

struct BillItem {
    var fee: Double
    var isPaid: Bool
    var itemName: String
}
