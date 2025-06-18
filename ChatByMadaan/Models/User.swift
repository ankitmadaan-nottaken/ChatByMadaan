//
//  User.swift
//  ChatByMadaan
//
//  Created by Ankit Madan on 6/11/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let avatarURL: String?

    init(id: String, name: String, email: String, avatarURL: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
    }
}
