//
//  Firestore.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class AIMessagesViewModel: ObservableObject {

    @Published var messages = [ChatMessage]()
    private var db = Firestore.firestore()

    func fetchData() {
        self.db.collection("messages")
            .whereField("uid", isEqualTo: String(Auth.auth().currentUser!.uid))
            .addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }

                self.messages = documents.map { (queryDocumentSnapshot) -> ChatMessage in
                    let data = queryDocumentSnapshot.data()
                    let uid = data["uid"] as? String ?? ""
                    let sender = data["sender"] as? String ?? ""
                    let content = data["content"] as? String ?? ""
                    let timestamp = data["timestamp"] as? Date ?? Date()

                    return ChatMessage(sender: sender, content: content, timestamp: timestamp)
                }
            }
    }
}

