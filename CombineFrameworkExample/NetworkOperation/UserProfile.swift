//
//  UserProfile.swift
//  CombineFrameworkExample
//
//  Created by Sujeet kumar on 08/08/26.
//

import Foundation

struct UserProfile: Codable, Identifiable {
    let id : UUID
    let name: String?
    let email: String?
    let lastName: String?
}
