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
    let buttonHeight: CGFloat = 60
    
    fileprivate lazy var currentStateDisplayCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = cornerRadius
        view.layer.shadowOpacity = shadowOpacity
        view.layer.shadowRadius = cornerRadius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = shadowOffset
        return view
    }()
    
    fileprivate lazy var exerciseTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Exercise Title"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    fileprivate lazy var pitch: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 6
        view.layer.shadowOpacity = shadowOpacity
        view.layer.shadowRadius = 6
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        view.layer.shadowOffset = shadowOffset
        return view
    }()
    
    fileprivate lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 6
        view.layer.shadowOpacity = shadowOpacity
        view.layer.shadowRadius = 6
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = shadowOffset
        return view
    }()
    
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
    
    fileprivate lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.setTitle("Back", for: .normal)
        return button
    }()
    
    fileprivate lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.setTitle("Next", for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Exercise Execution"
        view.backgroundColor = .white
        currentStateDisplayCard.addSubview(exerciseTitle)
        currentStateDisplayCard.addSubview(pitch)
        currentStateDisplayCard.addSubview(progressView)
        view.addSubview(currentStateDisplayCard)
        view.addSubview(startAndPauseButton)
        view.addSubview(backButton)
        view.addSubview(nextButton)
        setupConstraints()
    }
    
    func setupConstraints() {
        currentStateDisplayCard.bottomAnchor.constraint(equalTo: startAndPauseButton.topAnchor, constant: -marginWidth).isActive = true
        currentStateDisplayCard.topAnchor.constraint(equalTo: view.topAnchor, constant: marginWidth).isActive = true
        currentStateDisplayCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: marginWidth).isActive = true
        currentStateDisplayCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -marginWidth).isActive = true
        exerciseTitle.topAnchor.constraint(equalTo: currentStateDisplayCard.topAnchor, constant: marginWidth).isActive = true
        exerciseTitle.leadingAnchor.constraint(equalTo: currentStateDisplayCard.leadingAnchor, constant: marginWidth).isActive = true
        exerciseTitle.trailingAnchor.constraint(equalTo: currentStateDisplayCard.trailingAnchor, constant: -marginWidth).isActive = true
        exerciseTitle.bottomAnchor.constraint(equalTo: pitch.topAnchor, constant: -marginWidth).isActive = true
        pitch.topAnchor.constraint(equalTo: exerciseTitle.bottomAnchor, constant: marginWidth).isActive = true
        pitch.leadingAnchor.constraint(equalTo: currentStateDisplayCard.leadingAnchor, constant: marginWidth).isActive = true
        pitch.trailingAnchor.constraint(equalTo: currentStateDisplayCard.trailingAnchor, constant: -marginWidth).isActive = true
        pitch.bottomAnchor.constraint(equalTo: progressView.topAnchor, constant: -marginWidth).isActive = true
        progressView.topAnchor.constraint(equalTo: pitch.bottomAnchor, constant: marginWidth).isActive = true
        progressView.leadingAnchor.constraint(equalTo: currentStateDisplayCard.leadingAnchor, constant: marginWidth).isActive = true
        progressView.trailingAnchor.constraint(equalTo: currentStateDisplayCard.trailingAnchor, constant: -marginWidth).isActive = true
        progressView.bottomAnchor.constraint(equalTo: currentStateDisplayCard.bottomAnchor, constant: -marginWidth).isActive = true
        backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: marginWidth).isActive = true
        backButton.trailingAnchor.constraint(equalTo: startAndPauseButton.leadingAnchor, constant: -marginWidth).isActive = true
        backButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -marginWidth).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        startAndPauseButton.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: marginWidth).isActive = true
        startAndPauseButton.trailingAnchor.constraint(equalTo: nextButton.leadingAnchor, constant: -marginWidth).isActive = true
        startAndPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        startAndPauseButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -marginWidth).isActive = true
        startAndPauseButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        startAndPauseButton.widthAnchor.constraint(equalToConstant: (view.frame.width-4*marginWidth)/3).isActive = true
        nextButton.leadingAnchor.constraint(equalTo: startAndPauseButton.trailingAnchor, constant: marginWidth).isActive = true
        nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -marginWidth).isActive = true
        nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -marginWidth).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
    }
}
