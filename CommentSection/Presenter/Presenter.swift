//
//  Presenter.swift
//  CommentSection
//
//  Created by Matthew Gill on 12/31/22.
//

import Foundation

class Presenter {

    var viewController: ViewControllerProtocol?
    var interactor: Interactor?

    var users: [User]
    var posts: [Post]
    var comments: [Comment]

    init(viewController: ViewControllerProtocol? = nil, interactor: Interactor? = nil, users: [User] = [User](), posts: [Post] = [Post](), comments: [Comment] = [Comment]()) {
        self.viewController = viewController
        self.interactor = interactor
        self.users = users
        self.posts = posts
        self.comments = comments
    }

    func loadComments() {
        var commentsCopy = comments
        for postIndex in (0..<posts.count).reversed() {
            for commentIndex in (0..<commentsCopy.count).reversed() {
                if commentsCopy[commentIndex].postId == posts[postIndex].id {
                    posts[postIndex].comments.insert(commentsCopy.remove(at: commentIndex), at: 0)
                }
                if commentsCopy.count > 1, commentsCopy[commentIndex - 1].postId < posts[postIndex].id {
                    break
                }
            }
        }
    }

    func loadPosts() {
        var postsCopy = posts
        for userIndex in (0..<users.count).reversed() {
            for postIndex in (0..<postsCopy.count).reversed() {
                if postsCopy[postIndex].userId == users[userIndex].id {
                    users[userIndex].posts.insert(postsCopy.remove(at: postIndex), at: 0)
                }
                if postsCopy.count > 1, postsCopy[postIndex - 1].userId < users[userIndex].id {
                    break
                }
            }
        }
    }

    func setUpViewModel() {
        guard !users.isEmpty && !posts.isEmpty && !comments.isEmpty else {
            return
        }

        viewController?.viewModel = ViewModel(users: users, posts: posts, comments: comments)
        guard let viewModel = viewController?.viewModel else { return }

        //Set up visibleCellModels & flatDataModels in viewModel from users, posts & comments
        users.forEach{ viewModel.flatDataModels.append($0) }
        viewModel.visibleCellModels = viewModel.flatDataModels
        for post in posts.reversed() {
            viewModel.flatDataModels.insert(post, at: post.userId)
            for comment in comments.reversed() {
                if comment.postId == post.id {
                    viewModel.flatDataModels.insert(comment, at: post.userId + 1)
                }
            }
        }
        viewController?.updateTableView()
    }
}
