//
//  ChatBubble.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-22.
//

import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.sender == "user" {
                Spacer()
            }

            VStack(alignment: message.sender == "user" ? .trailing : .leading, spacing: 2) {
                Text(senderName)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(message.content)
                    .padding(10)
                    .background(bubbleColor)
                    .foregroundColor(textColor)
                    .cornerRadius(15)

                Text(timeFormatter.string(from: message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if message.sender != "user" {
                Spacer()
            }
        }
    }

    private var senderName: String {
        switch message.sender {
        case "user":
            return "You"
        case "AI":
            return "AI Assistant"
        default:
            return "You"
        }
    }

    private var bubbleColor: Color {
        switch message.sender {
        case "user":
            return .blue
        case "AI":
            return Color(.systemGray5)
        default:
            return Color(.systemGray5)
        }
    }

    private var textColor: Color {
        message.sender == "user" ? .white : .primary
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }
}
