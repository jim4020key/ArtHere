//
//  MuseumCell.swift
//  ArtHere
//
//  Created by kimjimin on 2/2/25.
//

import UIKit

class MuseumCell: UICollectionViewCell {
    static let identifier = "MuseumCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .primary
        view.layer.cornerRadius = 40
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .medium)
        return label
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let shakeLabel: UILabel = {
        let label = UILabel()
        label.text = "shake device to mark!"
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(favoriteButton)
        containerView.addSubview(shakeLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        shakeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.5),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            favoriteButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            favoriteButton.widthAnchor.constraint(equalToConstant: 24),
            favoriteButton.heightAnchor.constraint(equalToConstant: 24),
            
            shakeLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            shakeLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
    }
    
    func configure(with museum: Museum) {
        nameLabel.text = museum.name
        imageView.image = UIImage(named: museum.pageURL)
    }
}
