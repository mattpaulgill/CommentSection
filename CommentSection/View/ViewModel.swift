//
//  ViewModel.swift
//  CommentSection
//
//  Created by Matthew Gill on 12/31/22.
//

import Foundation

class ViewModel {
    
    var users = [User]()
    var posts = [Post]()
    var comments = [Comment]()
    var flatDataModels = [DataModel]()
    var visibleCellModels = [DataModel]()
    
    init(users: [User] = [User](), posts: [Post] = [Post](), comments: [Comment] = [Comment]()) {
        self.users = users
        self.posts = posts
        self.comments = comments
    }
}
