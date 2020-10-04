//
//  ExerciseExecutionViewController.swift
//  winnerlights-ios-mobile-client
//
//  Created by human on 2020/09/23.
//

import UIKit

class ExerciseExecutionViewController: UIViewController {
    
    let cornerRadius: CGFloat = 20
    let shadowOpacity: Float = 0.2
    let marginWidth: CGFloat = 16
    let shadowOffset: CGSize = CGSize(width: 4, height: 4)
    let startAndPauseButtonHeight: CGFloat = 100
    
    fileprivate lazy var startAndPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.setTitle("StartAndPause", for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Exercise Execution"
        view.backgroundColor = .white
        view.addSubview(startAndPauseButton)
        setupConstraints()
    }
    
    func setupConstraints() {
        startAndPauseButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: marginWidth).isActive = true
        startAndPauseButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -marginWidth).isActive = true
        startAndPauseButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -marginWidth).isActive = true
        startAndPauseButton.heightAnchor.constraint(equalToConstant: startAndPauseButtonHeight).isActive = true
    }
}
