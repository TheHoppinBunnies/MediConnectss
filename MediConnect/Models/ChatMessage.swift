//
//  ChatMessage.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-22.
//

import Foundation

struct ChatMessage: Identifiable {
    let id: UUID
    let sender: String
    let content: String
    let timestamp: Date
}
