//
//  ExerciseCollectionViewCell.swift
//  winnerlights-ios-mobile-client
//
//  Created by human on 2020/09/23.
//

import UIKit

class ExerciseCollectionViewCell: UICollectionViewCell {
    let topMarginWidth: CGFloat = 10
    let bottomMarginWidth: CGFloat = 10
    
    fileprivate let previewView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Here comes preview"
        label.font = UIFont.systemFont(ofSize: 8, weight: .light)
        view.backgroundColor = .white
        view.addSubview(label)
        return view
    }()
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label.text = "title"
        return label
    }()
    
    fileprivate let descritionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 8, weight: .medium)
        label.text = "description"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(previewView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descritionLabel)
        setupConstraints()
        setupStyles()
    }
    
    func setupConstraints() {
        previewView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: topMarginWidth).isActive = true
        previewView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        previewView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        previewView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: previewView.bottomAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: descritionLabel.topAnchor).isActive = true
        descritionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        descritionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        descritionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        descritionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -bottomMarginWidth).isActive = true
    }
    
    func setupStyles() {
        contentView.layer.cornerRadius = 20
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowOpacity = 0.2
        contentView.layer.shadowRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 4, height: 4)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
