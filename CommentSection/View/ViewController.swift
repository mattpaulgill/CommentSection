//
//  ViewController.swift
//  CommentSection
//
//  Created by Matthew Gill on 12/31/22.
//

import UIKit

protocol ViewControllerProtocol: AnyObject {
//    var interactor: SchoolsInteractorProtocol? { get set }
    var viewModel: ViewModel? { get set }
    func updateTableView()
}

class ViewController: UIViewController, ViewControllerProtocol {

    private let cellIdentifier = "cellIdentifier"
    private let countButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.darkText, for: .normal)
        button.setTitle("Count", for: .normal)
        button.layer.cornerRadius = 3
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.darkGray.cgColor
        return button
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Matt Gill Rethink Interview"
        label.textColor = .darkText
        label.font = .monospacedSystemFont(ofSize: 12, weight: .light)
        return label
    }()

    let padding = 15.0
    let tableView = UITableView()
    let offsetToNextModel = 1
    var viewModel: ViewModel?
    var interactor: Interactor?

    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpCountButton()
        Task {
            await interactor?.fetchData()
        }
        setUpTitleLabel()
        setUpTable()
    }

    func setUpCountButton() {
        view.addSubview(countButton)
        countButton.addTarget(self, action: #selector(countButtonTapped), for: .touchUpInside)
        countButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            countButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            countButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            countButton.heightAnchor.constraint(equalToConstant: 25),
            countButton.widthAnchor.constraint(equalToConstant: 90)
        ])
    }

    @objc func countButtonTapped() {
        if let viewModel = viewModel {
            let countText = String(viewModel.users.count + viewModel.posts.count + viewModel.comments.count)
            let countAlert = UIAlertController(title: "Total Fetched", message: "Users, Posts & Comments\n\(countText)", preferredStyle: .alert)
            countAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(countAlert, animated: true)
        }
    }

    func setUpTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            titleLabel.heightAnchor.constraint(equalToConstant: 25),
        ])
    }

    func setUpTable() {
        tableView.register(CustomCellTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: countButton.bottomAnchor, constant: padding),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func updateTableView() {
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let visibleCells = viewModel?.visibleCellModels.count else {
            return 0
        }
        return visibleCells
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CustomCellTableViewCell else {
            print("Unable to dequeue custom cell")
            return UITableViewCell()
        }

        guard let viewModel = viewModel else {
            print("No view model found")
            return cell
        }

        let selectedModel = viewModel.visibleCellModels[indexPath.row]
        cell.selectionStyle = .none
        cell.configure(with: selectedModel)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        var numOfCellsToModify = 0

        if viewModel.visibleCellModels[indexPath.row] is Post {
            numOfCellsToModify = countAndModifyPostModels(for: indexPath)
        } else if viewModel.visibleCellModels[indexPath.row] is User {
            numOfCellsToModify = countAndModifyUserModels(for: indexPath)
        } else {
            updateCommentModelAndCell(for: indexPath)
        }

        //Insert or delete cells using an array of index paths and update visibleCellModels
        tableView.beginUpdates()
        let indices = Array((indexPath.row + offsetToNextModel)..<(indexPath.row + offsetToNextModel + numOfCellsToModify))
        let indexPaths = indices.map{ IndexPath(row: $0, section: indexPath.section) }
        viewModel.visibleCellModels[indexPath.row].isExpanded ? tableView.insertRows(at: indexPaths, with: .automatic) : tableView.deleteRows(at: indexPaths, with: .top)
        tableView.endUpdates()
    }

    private func updateCommentModelAndCell(for indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        guard let selectedModel = viewModel.visibleCellModels[indexPath.row] as? Comment else { return }

        viewModel.visibleCellModels[indexPath.row].isExpanded = !selectedModel.isExpanded
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    private func countAndModifyPostModels(for indexPath: IndexPath) -> Int {
        guard let viewModel = viewModel else { return 0 }
        guard let selectedModel = viewModel.visibleCellModels[indexPath.row] as? Post else { return 0 }

        var startIndex: Int? = nil
        var numOfCellsToModify = 0

        startIndex = viewModel.flatDataModels.firstIndex(where: {
            $0 is Post && $0.id == selectedModel.id
        })

        guard var startIndex = startIndex else { return 0 }
        if !selectedModel.isExpanded {
            startIndex += offsetToNextModel
            for model in viewModel.flatDataModels[startIndex...] {
                if model is Comment {
                    viewModel.visibleCellModels.insert(model, at: indexPath.row + offsetToNextModel + numOfCellsToModify)
                    numOfCellsToModify += 1
                } else {
                    break
                }
            }
        } else {
            for model in viewModel.visibleCellModels[(indexPath.row + offsetToNextModel)...] {
                if model is Comment {
                    viewModel.visibleCellModels.remove(at: indexPath.row + offsetToNextModel)
                    numOfCellsToModify += 1
                } else {
                    break
                }
            }
        }
        viewModel.visibleCellModels[indexPath.row].isExpanded = !selectedModel.isExpanded

        return numOfCellsToModify
    }

    private func countAndModifyUserModels(for indexPath: IndexPath) -> Int {
        guard let viewModel = viewModel else { return 0 }
        guard let selectedModel = viewModel.visibleCellModels[indexPath.row] as? User else { return 0 }

        var startIndex: Int? = nil
        var numOfCellsToModify = 0

        startIndex = viewModel.flatDataModels.firstIndex(where: {
            $0 is User && $0.id == selectedModel.id
        })

        guard var startIndex = startIndex else { return 0 }
        if !selectedModel.isExpanded {
            startIndex += offsetToNextModel
            for model in viewModel.flatDataModels[startIndex...] {
                if model is Post {
                    viewModel.visibleCellModels.insert(model, at: indexPath.row + offsetToNextModel + numOfCellsToModify)
                    numOfCellsToModify += 1
                } else if model is User {
                    break
                }
            }
        } else {
            for model in viewModel.visibleCellModels[(indexPath.row + offsetToNextModel)...] {
                if model is Post || model is Comment {
                    viewModel.visibleCellModels.remove(at: indexPath.row + offsetToNextModel)
                    numOfCellsToModify += 1
                } else if model is User {
                    break
                }
            }
        }
        viewModel.visibleCellModels[indexPath.row].isExpanded = !selectedModel.isExpanded

        return numOfCellsToModify
    }
}

