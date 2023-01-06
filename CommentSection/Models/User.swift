//
//  User.swift
//  CommentSection
//
//  Created by Matthew Gill on 12/31/22.
//

import Foundation

protocol DataModel {
    var id: Int { get set }
    var isExpanded: Bool { get set }
}

struct User: DataModel, Decodable {
    var id: Int
    var name: String
    var username: String
    var posts = [Post]()
    var isExpanded: Bool = false

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case username
    }
}
