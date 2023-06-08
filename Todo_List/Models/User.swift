//
//  User.swift
//  Todo_List
//
//  Created by Cosmin Ghinea on 26.05.2023.
//

import Foundation

struct User: Codable {
    let id: String
    let name: String
    let email: String
    let joined: TimeInterval
}
