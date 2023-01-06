//
//  Comment.swift
//  CommentSection
//
//  Created by Matthew Gill on 12/31/22.
//

import Foundation

struct Comment: DataModel, Decodable {
    var id: Int
    var postId: Int
    var name: String
    var email: String
    var body: String
    var isExpanded: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case id
        case postId
        case name
        case email
        case body
    }
}
