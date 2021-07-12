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
    let cornerRadius: CGFloat = 20
    let shadowOpacity: Float = 0.2
    let marginWidth: CGFloat = 16
    let shadowOffset: CGSize = CGSize(width: 4, height: 4)
    let buttonHeight: CGFloat = 60
    var backButtonTappedAt: Float = 0
//    var exercise: Exercise!
    var exercise: Exercise = Exercise(
        title: "Counter attack",
        description: "Basic exercise. There are 2 goals and 4 players on each team.",
        phases: [
            Phase(
                duration: 65,
                goals: [
                    Goal(position: .upperLeft, color: .pink),
                    Goal(position: .lowerLeft, color: .pink),
                    Goal(position: .upperRight, color: .blue),
                    Goal(position: .lowerRight, color: .blue),
                ]
            ),
            Phase(
                duration: 20,
                goals: [
                    Goal(position: .upperLeft, color: .blue),
                    Goal(position: .lowerLeft, color: .blue),
                    Goal(position: .upperRight, color: .pink),
                    Goal(position: .lowerRight, color: .pink),
                ]
            ),
            Phase(
                duration: 15,
                goals: [
                    Goal(position: .upperLeft, color: .pink),
                    Goal(position: .lowerLeft, color: .pink),
                    Goal(position: .upperRight, color: .blue),
                    Goal(position: .lowerRight, color: .blue),
                ]
            ),
            Phase(
                duration: 30,
                goals: [
                    Goal(position: .upperLeft, color: .blue),
                    Goal(position: .lowerLeft, color: .blue),
                    Goal(position: .upperRight, color: .pink),
                    Goal(position: .lowerRight, color: .pink),
                ]
            )
        ]
    )
    var currentPhaseIndex: Int = 0 {
        didSet {
            if currentPhaseIndex != oldValue  {
                pitch.phase = exercise.phases[currentPhaseIndex]
                pitch.setNeedsDisplay()
            }
        }
    }
    var currentTime: Float = 0.0 {
        didSet {
            for phaseIndex in 0 ..< exercise.phases.count {
                let partialTotalDuration = exercise.phases[0 ..< phaseIndex].reduce(0.0, {$0 + $1.duration})
                if (partialTotalDuration <= currentTime) {
                    currentPhaseIndex = phaseIndex
                }
            }
        }
    }
    var timer: Timer!
    var timerInterval: Float = 0.1
    var isExerciseRunning: Bool = false
    
    fileprivate let previewView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate lazy var pitch: PitchView = {
        let view = PitchView(phase: exercise.phases[currentPhaseIndex])
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
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
//        label.text = exercise.title
        label.textColor = .black
        return label
    }()
    
    fileprivate lazy var descritionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 8, weight: .medium)
//        label.text = "Phase\t"+String(exercise.phases.count)
        label.textColor = .black
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        previewView.addSubview(pitch)
        contentView.addSubview(previewView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descritionLabel)
        setupConstraints()
        setupStyles()
    }
    
    func setupConstraints() {
        pitch.topAnchor.constraint(equalTo: previewView.topAnchor, constant: topMarginWidth).isActive = true
        pitch.leadingAnchor.constraint(equalTo: previewView.leadingAnchor, constant: topMarginWidth).isActive = true
        pitch.trailingAnchor.constraint(equalTo: previewView.trailingAnchor, constant: -topMarginWidth).isActive = true
        pitch.bottomAnchor.constraint(equalTo: previewView.bottomAnchor, constant: -topMarginWidth).isActive = true
        previewView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
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
    
    func exerciseChange(exercise: Exercise){
        titleLabel.text = exercise.title
        descritionLabel.text = "Phase\t"+String(exercise.phases.count)
    }
}
