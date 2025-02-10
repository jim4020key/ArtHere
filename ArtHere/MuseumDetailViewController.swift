//
//  MuseumDetailViewController.swift
//  ArtHere
//
//  Created by kimjimin on 2/10/25.
//

import UIKit

class MuseumDetailViewController: UIViewController {
    private let viewModel: MuseumDetailViewModel
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.textColor = .primary
        return label
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .primary
        return button
    }()
    
    private let homepageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrowshape.turn.up.right.circle.fill"), for: .normal)
        button.tintColor = .primary
        return button
    }()
    
    private let whatsOnLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: "현재전시", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.textColor = .primary
        return label
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.tintColor = .primary
        return button
    }()
    
    init(viewModel: MuseumDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        titleLabel.text = viewModel.museumName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFavoriteButton()
    }
    
    private func setupUI() {
        view.backgroundColor = .base
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(favoriteButton)
        contentView.addSubview(homepageButton)
        contentView.addSubview(whatsOnLabel)
        contentView.addSubview(shareButton)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        homepageButton.translatesAutoresizingMaskIntoConstraints = false
        whatsOnLabel.translatesAutoresizingMaskIntoConstraints = false
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            favoriteButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: homepageButton.leadingAnchor, constant: -16),
            
            homepageButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            homepageButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            whatsOnLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            whatsOnLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            shareButton.topAnchor.constraint(equalTo: whatsOnLabel.bottomAnchor, constant: 100),
            shareButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            shareButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
        
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        homepageButton.addTarget(self, action: #selector(homepageButtonTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
    }
    
    private func updateFavoriteButton() {
        let isFavorite = viewModel.isFavorite()
        let image = isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        favoriteButton.setImage(image, for: .normal)
        favoriteButton.tintColor = isFavorite ? .accent : .primary
    }
    
    @objc private func favoriteButtonTapped() {
        viewModel.toggleFavorite()
        updateFavoriteButton()
    }
    
    @objc private func homepageButtonTapped() {
        if let url = URL(string: viewModel.homepageURL) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func shareButtonTapped() {
        let items = [viewModel.museumName]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityViewController, animated: true)
    }
}
