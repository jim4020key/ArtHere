//
//  FavoritesViewController.swift
//  ArtHere
//
//  Created by kimjimin on 1/31/25.
//

import UIKit

final class FavoritesViewController: UIViewController {
    private let viewModel = FavoritesViewModel()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "하트를 눌러 관심 있는 미술관을 추가해보세요"
        label.textColor = .gray
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .body)
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .base
        
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func updateUI() {
        viewModel.loadFavorites()
        emptyStateLabel.isHidden = !viewModel.favoriteMuseums.isEmpty
        tableView.reloadData()
    }
    
    func setOnFavoriteRemoved(callback: @escaping (String) -> Void) {
        viewModel.onFavoriteRemoved = callback
    }
}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.favoriteMuseums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let museum = viewModel.favoriteMuseums[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = museum.name
        content.textProperties.color = .primary
        
        cell.contentConfiguration = content
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.removeFavorite(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            emptyStateLabel.isHidden = !viewModel.isEmpty
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let museum = viewModel.favoriteMuseums[indexPath.row]
        if let name = museum.name {
            
            //TODO: 이름으로 해당 미술관을 검색 후 전달
            let museum = Museum(fcltyNm: name, rdnmadr: "", homepageUrl: "", latitude: "0.0", longitude: "0.0")
            
            let detailViewModel = MuseumDetailViewModel(museum: museum)
            let detailViewController = MuseumDetailViewController(viewModel: detailViewModel)
            detailViewModel.onFavoriteToggled = { [weak self] in
                self?.tableView.reloadData()
            }
            navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
}
