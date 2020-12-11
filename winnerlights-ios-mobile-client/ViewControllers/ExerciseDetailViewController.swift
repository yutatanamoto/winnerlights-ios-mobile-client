//
//  ExerciseDetailViewController.swift
//  winnerlights-ios-mobile-client
//
//  Created by human on 2020/09/23.
//

import UIKit

class ExerciseDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let cornerRadius: CGFloat = 20
    let shadowOpacity: Float = 0.2
    let marginWidth: CGFloat = 16
    let shadowOffset: CGSize = CGSize(width: 4, height: 4)
    let topMarginWidth: CGFloat = 10
    let bottomMarginWidth: CGFloat = 10
    let buttonHeight: CGFloat = 60
    let dataSource:[Int] = ([Int])(1...60)
    var backButtonTappedAt: Float = 0
    var exercise: Exercise = Exercise(
        title: "Basic",
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
            let totalDuration: Float = exercise.phases.reduce(0.0, {$0 + $1.duration})
            
            phaseCountLabel.text = "Phase" + " " + "\(String(currentPhaseIndex+1))/\(String(exercise.phases.count))"
            
            currentTimeLabel.text = String(format:"%.0f", (currentTime/60.0).rounded(.towardZero))+":"+String(format:"%02.0f", floor(currentTime.truncatingRemainder(dividingBy: 60.0)))
            currentRemainingTimeLabel.text = String(format:"%.0f", ((totalDuration - currentTime)/60.0).rounded(.towardZero))+":"+String(format:"%02.0f", floor((totalDuration - currentTime).truncatingRemainder(dividingBy: 60.0)))
            if currentTime == 0 {
                progressView.setProgress(currentTime/totalDuration, animated: false)
            } else {
                progressView.setProgress(currentTime/totalDuration, animated: true)
            }
        }
    }
    var timer: Timer!
    var timerInterval: Float = 0.1
    var isExerciseRunning: Bool = true
    
    fileprivate lazy var exerciseTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Switching Goal"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    fileprivate lazy var exerciseDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Here comes some description."
        label.textAlignment = .center
        label.textColor = .black
        return label
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
    
    fileprivate lazy var phaseCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Phase" + " " + "\(String(currentPhaseIndex+1))/\(String(exercise.phases.count))"
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    

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

    
    fileprivate lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 6
        view.layer.shadowOpacity = shadowOpacity
        view.layer.shadowRadius = 6
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = shadowOffset
        view.setProgress(currentTime, animated: true)
        return view
    }()
    
    fileprivate lazy var partitionBarGroupView: PartitionBarGroupView = {
        let view = PartitionBarGroupView(phases: exercise.phases)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate lazy var circularProgressView: CircularProgressView = {
        let view = CircularProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    @objc func navigateToExecutionView() {
        let vc = ExerciseExecutionViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = String(format:"%.0f", (currentTime/60.0).rounded(.towardZero))+":"+String(format:"%02.0f", floor(currentTime.truncatingRemainder(dividingBy: 60.0)))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    fileprivate lazy var currentRemainingTimeLabel: UILabel = {
        let label = UILabel()
        let totalDuration: Float = exercise.phases.reduce(0.0, {$0 + $1.duration})
        label.text = String(format:"%.0f", (totalDuration/60.0).rounded(.towardZero))+":"+String(format:"%02.0f", floor(totalDuration.truncatingRemainder(dividingBy: 60.0)))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    fileprivate lazy var phaseTimeRoll: UIPickerView = {
            let pickerView = UIPickerView()
            pickerView.translatesAutoresizingMaskIntoConstraints = false
            //pickerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300)
            pickerView.backgroundColor = .clear
            pickerView.isHidden = true
            pickerView.delegate   = self
            pickerView.dataSource = self
            return pickerView
        }()
        
        fileprivate lazy var phaseTimeButton: UIButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.backgroundColor = .white
            button.layer.cornerRadius = cornerRadius
            button.layer.shadowOpacity = shadowOpacity
            button.layer.shadowRadius = cornerRadius
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = shadowOffset
            button.setTitle("30", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 25)
            button.setTitleColor(.black, for: .normal)
            button.addTarget(self, action: #selector(pickerViewDisplay), for: .touchUpInside)
            return button
        }()
        
        @objc func pickerViewDisplay() {
            phaseTimeButton.isHidden = true
            phaseTimeRoll.isHidden = false
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?  {
            return String(dataSource[row])
            }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
                return 1
            }
        
        func rowSize(in pickerView: UIPickerView) -> Int {
                return 1
            }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
                return dataSource.count
            }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            phaseTimeButton.setTitle(String(dataSource[row]), for: .normal)
            phaseTimeRoll.isHidden = true
            phaseTimeButton.isHidden = false
            }
    
    fileprivate lazy var phaseTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "Phase Time"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 25, weight: .medium)
        label.textAlignment = .center
        label.textColor = .black
        return label
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
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(navigateToExecutionView), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Exercise Detail"
        self.navigationController?.navigationBar.isTranslucent = false
        self.tabBarController?.tabBar.isTranslucent = false
        view.backgroundColor = .white
        descriptionContainerView.addSubview(exerciseTitle)
        descriptionContainerView.addSubview(exerciseDescription)
        view.addSubview(descriptionContainerView)
        previewContainerView.addSubview(pitch)
        previewContainerView.addSubview(phaseCountLabel)
        previewContainerView.addSubview(progressView)
        previewContainerView.addSubview(partitionBarGroupView)
        previewContainerView.addSubview(currentTimeLabel)
        previewContainerView.addSubview(currentRemainingTimeLabel)
        previewContainerView.addSubview(phaseTimeLabel)
        previewContainerView.addSubview(phaseTimeButton)
        previewContainerView.addSubview(phaseTimeRoll)
        view.addSubview(previewContainerView)
        view.addSubview(executionButton)
        setupConstraints()
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(0.1*timerInterval), target:self,selector:#selector(self.updateCurrentTime), userInfo: nil, repeats: true)
    }
    
    func setupConstraints() {
        exerciseTitle.topAnchor.constraint(equalTo: descriptionContainerView.topAnchor, constant: marginWidth).isActive = true
        exerciseTitle.leadingAnchor.constraint(equalTo: descriptionContainerView.leadingAnchor).isActive = true
        exerciseTitle.trailingAnchor.constraint(equalTo: descriptionContainerView.trailingAnchor).isActive = true
        
        exerciseDescription.topAnchor.constraint(equalTo: exerciseTitle.bottomAnchor, constant: marginWidth).isActive = true
        exerciseDescription.leadingAnchor.constraint(equalTo: descriptionContainerView.leadingAnchor).isActive = true
        exerciseDescription.trailingAnchor.constraint(equalTo: descriptionContainerView.trailingAnchor).isActive = true
        
        pitch.topAnchor.constraint(equalTo: previewContainerView.topAnchor, constant: marginWidth).isActive = true
        pitch.leadingAnchor.constraint(equalTo: previewContainerView.leadingAnchor, constant: marginWidth).isActive = true
        pitch.trailingAnchor.constraint(equalTo: previewContainerView.trailingAnchor, constant: -marginWidth).isActive = true
        pitch.bottomAnchor.constraint(equalTo: previewContainerView.centerYAnchor).isActive = true
        
        phaseCountLabel.topAnchor.constraint(equalTo: previewContainerView.centerYAnchor,constant: marginWidth*0.5).isActive = true
        phaseCountLabel.centerXAnchor.constraint(equalTo: previewContainerView.centerXAnchor).isActive = true
                
        progressView.leadingAnchor.constraint(equalTo: previewContainerView.leadingAnchor, constant: marginWidth).isActive = true
        progressView.trailingAnchor.constraint(equalTo: previewContainerView.trailingAnchor, constant: -marginWidth).isActive = true
        progressView.topAnchor.constraint(equalTo: phaseCountLabel.bottomAnchor, constant: -marginWidth*0.5).isActive = true
        progressView.bottomAnchor.constraint(equalTo: currentTimeLabel.topAnchor, constant: -marginWidth).isActive = true
        progressView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        partitionBarGroupView.centerXAnchor.constraint(equalTo: progressView.centerXAnchor).isActive = true
        partitionBarGroupView.centerYAnchor.constraint(equalTo: progressView.centerYAnchor).isActive = true
        partitionBarGroupView.widthAnchor.constraint(equalTo: progressView.widthAnchor).isActive = true
        partitionBarGroupView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        descriptionContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: marginWidth).isActive = true
        descriptionContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: marginWidth).isActive = true
        descriptionContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -marginWidth).isActive = true
        descriptionContainerView.heightAnchor.constraint(equalToConstant: 140).isActive = true
        
        previewContainerView.topAnchor.constraint(equalTo: descriptionContainerView.bottomAnchor, constant: marginWidth).isActive = true
        previewContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: marginWidth).isActive = true
        previewContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -marginWidth).isActive = true
        
        currentTimeLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8).isActive = true
        currentTimeLabel.leadingAnchor.constraint(equalTo: previewContainerView.leadingAnchor, constant: marginWidth).isActive = true
        
        currentRemainingTimeLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8).isActive = true
        currentRemainingTimeLabel.trailingAnchor.constraint(equalTo: previewContainerView.trailingAnchor, constant: -marginWidth).isActive = true
        
        phaseTimeLabel.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: marginWidth*2).isActive = true
        phaseTimeLabel.trailingAnchor.constraint(equalTo: previewContainerView.centerXAnchor).isActive = true
        phaseTimeLabel.bottomAnchor.constraint(equalTo: previewContainerView.bottomAnchor, constant: -marginWidth*2).isActive = true
        
        phaseTimeButton.leadingAnchor.constraint(equalTo: previewContainerView.centerXAnchor, constant: marginWidth*2).isActive = true
        phaseTimeButton.centerYAnchor.constraint(equalTo: phaseTimeLabel.centerYAnchor).isActive = true
        
        phaseTimeRoll.leadingAnchor.constraint(equalTo: previewContainerView.centerXAnchor, constant: marginWidth).isActive = true
        phaseTimeRoll.trailingAnchor.constraint(equalTo: previewContainerView.trailingAnchor, constant: -marginWidth).isActive = true
        phaseTimeRoll.centerXAnchor.constraint(equalTo: phaseTimeButton.centerXAnchor).isActive = true
        phaseTimeRoll.centerYAnchor.constraint(equalTo: phaseTimeButton.centerYAnchor).isActive = true
        
        executionButton.topAnchor.constraint(equalTo: previewContainerView.bottomAnchor, constant: marginWidth).isActive = true
        executionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100).isActive = true
        executionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100).isActive = true
        executionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -marginWidth).isActive = true
        executionButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    @objc func updateCurrentTime() {
        if isExerciseRunning{
            let totalDuration: Float = exercise.phases.reduce(0.0, {$0 + $1.duration})
            if currentTime + timerInterval < totalDuration {
                currentTime = currentTime + timerInterval
            }else{
                currentTime = 0.0
            }
        }
    }
}
