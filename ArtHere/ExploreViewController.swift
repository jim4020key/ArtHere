//
//  ExploreViewController.swift
//  ArtHere
//
//  Created by kimjimin on 1/31/25.
//

import UIKit

class ExploreViewController: UIViewController {
    private var viewModel = ExploreViewModel()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 60, height: UIScreen.main.bounds.width - 60)
        layout.minimumLineSpacing = 20
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.dataSource = self
        collection.delegate = self
        collection.register(MuseumCell.self, forCellWithReuseIdentifier: MuseumCell.identifier)
        collection.contentInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        collection.decelerationRate = .fast
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let toggleButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "rectangle.stack"), for: .normal)
        button.tintColor = .primary
        return button
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.tintColor = .primary
        return button
    }()
    
    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.currentPageIndicatorTintColor = .primary
        control.pageIndicatorTintColor = .lightGray
        control.addTarget(self, action: #selector(pageControlValueChanged(_:)), for: .valueChanged)
        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configurePageControl()
    }
    
    private func setupUI() {
        view.backgroundColor = .base
        
        view.addSubview(collectionView)
        view.addSubview(tableView)
        view.addSubview(toggleButton)
        view.addSubview(searchButton)
        view.addSubview(pageControl)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toggleButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            toggleButton.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -16),
            toggleButton.centerYAnchor.constraint(equalTo: searchButton.centerYAnchor),
            
            searchButton.topAnchor.constraint(equalTo: toggleButton.topAnchor),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: toggleButton.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            
            tableView.topAnchor.constraint(equalTo: toggleButton.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        tableView.isHidden = true
        toggleButton.addTarget(self, action: #selector(toggleButtonTapped), for: .touchUpInside)
    }
    
    private func configurePageControl() {
        pageControl.numberOfPages = viewModel.museums.count
    }
    
    @objc private func toggleButtonTapped() {
        viewModel.toggleViewMode()
        collectionView.isHidden = !viewModel.isCarouselMode
        tableView.isHidden = viewModel.isCarouselMode
        pageControl.isHidden = !viewModel.isCarouselMode
    }
    
    @objc private func pageControlValueChanged(_ sender: UIPageControl) {
        let indexPath = IndexPath(item: sender.currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

extension ExploreViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.museums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MuseumCell.identifier, for: indexPath) as? MuseumCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: viewModel.museums[indexPath.item])
        return cell
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        let offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        targetContentOffset.pointee = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: 0)
        pageControl.currentPage = Int(roundedIndex)
    }
}

extension ExploreViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.museums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let museum = viewModel.museums[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = museum.name
        content.textProperties.color = .primary
        
        cell.contentConfiguration = content
        
        //TODO: chevron이 표시되지 않는 문제 해결
        cell.accessoryType = .disclosureIndicator
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        return cell
    }
}
