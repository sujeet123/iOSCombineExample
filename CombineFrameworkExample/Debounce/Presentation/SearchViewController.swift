//
//  SearchViewController.swift
//  CombineFrameworkExample
//
//  Created by Sujeet kumar on 18/08/26.
//

//Key UIKit-specific detail
//
//UIKit's UITextField doesn't have Combine support out of the box, so we bridge it using NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: searchTextField) — this converts the standard .editingChanged UIControl event into a Combine publisher, letting the same $query debounce pipeline in the ViewModel work identically for both UIKit and SwiftUI.



import Foundation
import UIKit
import Combine


class SearchViewController: UIViewController {
    private let searchViewModel: SearchViewModel
    private var cancelables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search.."
        textField.translatesAutoresizingMaskIntoConstraints =  false
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var searchResult: [SearchResult] = []
    
    init(searchViewModel: SearchViewModel = SearchViewModel()) {
        self.searchViewModel = searchViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Search"
        setupLayout()
        setupTableView()
        bindTextField()
        bindViewModel()
    }
    
    private func setupLayout() {
        view.addSubview(searchTextField)
        view.addSubview(activityIndicator)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 44),
            
            activityIndicator.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 16),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 8),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // Bridge UIKit's target-action to Combine
    private func bindTextField() {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: searchTextField)
            .compactMap { ($0.object as? UITextField)?.text }
            .sink { [weak self] text in
                self?.searchViewModel.query = text
                
            }
            .store(in: &cancelables)
    }
    
    private func bindViewModel() {
        searchViewModel.$results
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.searchResult = result
                self?.tableView.reloadData()
            }
            .store(in: &cancelables)
        
        searchViewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            }
            .store(in: &cancelables)
        
        searchViewModel.$errorMessage
            .compactMap{ $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showAlertView(message: errorMessage)
            }
            .store(in: &cancelables)
    }
    
    private func showAlertView(message: String) {
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "ok", style: .default))
        present(alertController, animated: true)
    }
    
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = searchResult[indexPath.row].title
        return cell
    }
}

