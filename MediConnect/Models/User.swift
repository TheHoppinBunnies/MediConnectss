//
//  User.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-22.
//

import Foundation

struct User: Identifiable {
    let id: String
    let name: String
    let email: String
    var profileImage: String? = "person.circle.fill"
    var dateOfBirth: Date = Date(timeIntervalSince1970: 0)
    var bloodType: String = "O+"
    var allergies: [String] = ["Peanuts", "Penicillin"]
    var conditions: [String] = ["Asthma"]
}
