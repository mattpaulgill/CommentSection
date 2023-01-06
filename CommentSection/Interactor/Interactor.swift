//
//  Interactor.swift
//  CommentSection
//
//  Created by Matthew Gill on 12/31/22.
//

import Foundation

enum NetworkError: Error {
    case failedToFetchUsers
    case failedToFetchPosts
    case failedToFetchComments
}

enum DataType {
    case user
    case post
    case comment
}

class Interactor {
    
    let usersUrl = URL(string: "https://jsonplaceholder.typicode.com/users")
    let postsUrl = URL(string: "https://jsonplaceholder.typicode.com/posts")
    let commentsUrl = URL(string: "https://jsonplaceholder.typicode.com/comments")
    let decoder = JSONDecoder()
    
    var presenter = Presenter()
    var urlSession = URLSession.shared
    
    func fetchData() async {
        async let usersResult = fetchUsers()
        async let postsResult = fetchPosts()
        async let commentsResult = fetchComments()
        
        switch await usersResult {
        case .success(let users):
            presenter.users = users
            DispatchQueue.main.async {
                self.presenter.setUpViewModel()
            }
        case .failure(let error):
            print(error)
        }
        switch await postsResult {
        case .success(let posts):
            presenter.posts = posts
            DispatchQueue.main.async {
                self.presenter.loadPosts()
                self.presenter.setUpViewModel()
            }
        case .failure(let error):
            print(error)
        }
        switch await commentsResult {
        case .success(let comments):
            presenter.comments = comments
            DispatchQueue.main.async {
                self.presenter.loadComments()
                self.presenter.setUpViewModel()
            }
        case .failure(let error):
            print(error)
        }
    }
    
    private func fetchUsers() async -> Result<[User], Error> {
        guard let url = usersUrl else { return .failure(NetworkError.failedToFetchUsers) }
        
        do {
            let (data, _) = try await urlSession.data(from: url)
            let users = try JSONDecoder().decode([User].self, from: data)
            return .success(users)
        } catch {
            return .failure(NetworkError.failedToFetchUsers)
        }
    }
    
    private func fetchPosts() async -> Result<[Post], Error> {
        guard let url = postsUrl else { return .failure(NetworkError.failedToFetchPosts) }
        
        do {
            let (data, _) = try await urlSession.data(from: url)
            let posts = try JSONDecoder().decode([Post].self, from: data)
            return .success(posts)
        } catch {
            return .failure(NetworkError.failedToFetchPosts)
        }
    }
    
    private func fetchComments() async -> Result<[Comment], Error> {
        guard let url = commentsUrl else { return .failure(NetworkError.failedToFetchComments) }
        
        do {
            let (data, _) = try await urlSession.data(from: url)
            let comments = try JSONDecoder().decode([Comment].self, from: data)
            return .success(comments)
        } catch {
            return .failure(NetworkError.failedToFetchComments)
        }
    }
}
