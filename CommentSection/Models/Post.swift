//
//  Post.swift
//  CommentSection
//
//  Created by Matthew Gill on 12/31/22.
//

import Foundation

struct Post: DataModel, Decodable {
    var userId: Int
    var id: Int
    var title: String
    var body: String
    var comments = [Comment]()
    var isExpanded: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case userId
        case id
        case title
        case body
    }
}
