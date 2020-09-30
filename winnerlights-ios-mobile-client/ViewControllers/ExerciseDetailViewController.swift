//
//  ExerciseDetailViewController.swift
//  winnerlights-ios-mobile-client
//
//  Created by human on 2020/09/23.
//

import UIKit

class ExerciseDetailViewController: UIViewController {
    
    let cornerRadius: CGFloat = 20
    let shadowOpacity: Float = 0.2
    let marginWidth: CGFloat = 16
    let shadowOffset: CGSize = CGSize(width: 4, height: 4)

    fileprivate lazy var descriptionContainerView: UIView = {
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
    
    fileprivate lazy var descriptionView: UIView = {
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
    
    fileprivate lazy var exerciseDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Here comes some description."
        label.textAlignment = .center
        return label
    }()
    
    fileprivate lazy var previewContainerView: UIView = {
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
    
    fileprivate lazy var previewView: UIView = {
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
    
    fileprivate let previewSeekBar: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    fileprivate let previewCircularIndicator: UIView = {
        let view = UIView()
        let mainLayer = CAShapeLayer()
        let progressLabel = UILabel()
        return view
    }()
    
    fileprivate lazy var executionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.setTitle("Execute Exercise", for: .normal)
        button.addTarget(self, action: #selector(navigateToExecutionView), for: .touchUpInside)
        return button
    }()
    
    @objc func navigateToExecutionView() {
        let vc = ExerciseExecutionViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Exercise Detail"
        self.navigationController?.navigationBar.isTranslucent = false
        self.tabBarController?.tabBar.isTranslucent = false
        view.backgroundColor = .white
        descriptionContainerView.addSubview(exerciseTitle)
        descriptionContainerView.addSubview(exerciseDescription)
        view.addSubview(descriptionContainerView)
        previewContainerView.addSubview(previewView)
        previewContainerView.addSubview(previewSeekBar)
        view.addSubview(previewContainerView)
        view.addSubview(executionButton)
        setupConstraints()
    }
    
    func setupConstraints() {
        descriptionContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: marginWidth).isActive = true
        descriptionContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: marginWidth).isActive = true
        descriptionContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -marginWidth).isActive = true
        descriptionContainerView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        exerciseTitle.topAnchor.constraint(equalTo: descriptionContainerView.topAnchor, constant: marginWidth).isActive = true
        exerciseTitle.leadingAnchor.constraint(equalTo: descriptionContainerView.leadingAnchor).isActive = true
        exerciseTitle.trailingAnchor.constraint(equalTo: descriptionContainerView.trailingAnchor).isActive = true
        
        exerciseDescription.topAnchor.constraint(equalTo: exerciseTitle.bottomAnchor, constant: marginWidth).isActive = true
        exerciseDescription.leadingAnchor.constraint(equalTo: descriptionContainerView.leadingAnchor).isActive = true
        exerciseDescription.trailingAnchor.constraint(equalTo: descriptionContainerView.trailingAnchor).isActive = true
        
        previewContainerView.topAnchor.constraint(equalTo: descriptionContainerView.bottomAnchor, constant: marginWidth).isActive = true
        previewContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: marginWidth).isActive = true
        previewContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -marginWidth).isActive = true
        
        previewView.topAnchor.constraint(equalTo: previewContainerView.topAnchor, constant: marginWidth).isActive = true
        previewView.leadingAnchor.constraint(equalTo: previewContainerView.leadingAnchor, constant: marginWidth).isActive = true
        previewView.trailingAnchor.constraint(equalTo: previewContainerView.trailingAnchor, constant: -marginWidth).isActive = true
        previewView.bottomAnchor.constraint(equalTo: previewContainerView.bottomAnchor, constant: -200).isActive = true
        
        previewSeekBar.topAnchor.constraint(equalTo: previewView.bottomAnchor, constant: marginWidth).isActive = true
        previewSeekBar.leadingAnchor.constraint(equalTo: previewContainerView.leadingAnchor, constant: marginWidth).isActive = true
        previewSeekBar.trailingAnchor.constraint(equalTo: previewContainerView.trailingAnchor, constant: -marginWidth).isActive = true
        previewSeekBar.bottomAnchor.constraint(equalTo: previewContainerView.bottomAnchor, constant: -100).isActive = true
        
        executionButton.topAnchor.constraint(equalTo: previewContainerView.bottomAnchor, constant: marginWidth).isActive = true
        executionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100).isActive = true
        executionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100).isActive = true
        executionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -marginWidth).isActive = true
        executionButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}
