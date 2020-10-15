//
//  ExerciseExecutionViewController.swift
//  winnerlights-ios-mobile-client
//
//  Created by human on 2020/09/23.
//

import UIKit

struct Phase {
    var duration: Float
}
struct Exercise {
    var title: String
    var description: String
    var phases: [Phase]
}

class ExerciseExecutionViewController: UIViewController {
    var exercise: Exercise = Exercise(
        title: "Basic",
        description: "Basic exercise. There are 2 goals and 4 players on each team.",
        phases: [
            Phase(duration: 10),
            Phase(duration: 20),
            Phase(duration: 15),
            Phase(duration: 30)
        ]
    )
    let cornerRadius: CGFloat = 20
    let shadowOpacity: Float = 0.2
    let marginWidth: CGFloat = 16
    let shadowOffset: CGSize = CGSize(width: 4, height: 4)
    let buttonHeight: CGFloat = 60
    var currentPhaseIndex: Int = 0
    var currentTime: Float = 0.0 {
        didSet {
            for phaseIndex in 0 ..< exercise.phases.count {
                let duration = exercise.phases[0 ..< phaseIndex].reduce(0) { (summension, phase) -> Float in
                    summension + phase.duration
                }
                if (duration < currentTime) {
                    currentPhaseIndex = phaseIndex
                }
            }
            let totalDurationTilLastPhase = exercise.phases[0 ..< currentPhaseIndex].reduce(0) { (summension, phase) -> Float in
                summension + phase.duration
            }
            circularProgressView.progressAnimation(
                currentPahseTime: currentTime-totalDurationTilLastPhase,
                currentPhaseProgress: (currentTime-totalDurationTilLastPhase)/exercise.phases[currentPhaseIndex].duration)
            let totalDuration: Float = exercise.phases.reduce(0.0, {$0 + $1.duration})
            progressView.setProgress(currentTime/totalDuration, animated: true)
            phaseCountLabel.text = "\(String(currentPhaseIndex+1))/\(String(exercise.phases.count))"
            currentTimeLabel.text = String(format:"%.0f", currentTime)
            currentRemainingTimeLabel.text = String(format:"%.0f", totalDuration - currentTime)
        }
    }
    var timer: Timer!
    var timerInterval: Float = 0.1
    var isExerciseRunning: Bool = false
    
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
        label.text = exercise.title
        label.font = .systemFont(ofSize: 16, weight: .medium)
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
    
    fileprivate lazy var phaseCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(String(currentPhaseIndex+1))/\(String(exercise.phases.count))"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    fileprivate lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = String(format:"%.0f", 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    fileprivate lazy var currentRemainingTimeLabel: UILabel = {
        let label = UILabel()
        let totalDuration: Float = exercise.phases.reduce(0.0, {$0 + $1.duration})
        label.text = String(format:"%.0f", totalDuration)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        return label
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
        let view = PartitionBarGroupView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate lazy var circularProgressView: CircularProgressView = {
        let view = CircularProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
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
        button.setTitle("Start", for: .normal)
        button.addTarget(self, action: #selector(startAndPauseExercise), for: .touchUpInside)
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
        button.addTarget(self, action: #selector(moveToPrevPhase), for: .touchUpInside)
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
        button.addTarget(self, action: #selector(moveToNextPhase), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Exercise Execution"
        view.backgroundColor = .white
        currentStateDisplayCard.addSubview(exerciseTitle)
        currentStateDisplayCard.addSubview(pitch)
        currentStateDisplayCard.addSubview(phaseCountLabel)
        currentStateDisplayCard.addSubview(progressView)
        currentStateDisplayCard.addSubview(partitionBarGroupView)
        currentStateDisplayCard.addSubview(currentTimeLabel)
        currentStateDisplayCard.addSubview(currentRemainingTimeLabel)
        currentStateDisplayCard.addSubview(circularProgressView)
        view.addSubview(currentStateDisplayCard)
        view.addSubview(startAndPauseButton)
        view.addSubview(backButton)
        view.addSubview(nextButton)
        setupConstraints()
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(timerInterval), target:self,selector:#selector(self.updateCurrentTime), userInfo: nil, repeats: true)
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
        pitch.bottomAnchor.constraint(equalTo: phaseCountLabel.topAnchor, constant: -marginWidth).isActive = true
        phaseCountLabel.topAnchor.constraint(equalTo: pitch.bottomAnchor, constant: marginWidth).isActive = true
        phaseCountLabel.leadingAnchor.constraint(equalTo: currentStateDisplayCard.leadingAnchor, constant: marginWidth).isActive = true
        phaseCountLabel.trailingAnchor.constraint(equalTo: currentStateDisplayCard.trailingAnchor, constant: -marginWidth).isActive = true
        phaseCountLabel.bottomAnchor.constraint(equalTo: progressView.topAnchor, constant: -marginWidth).isActive = true
        progressView.topAnchor.constraint(equalTo: phaseCountLabel.bottomAnchor, constant: marginWidth).isActive = true
        progressView.leadingAnchor.constraint(equalTo: currentStateDisplayCard.leadingAnchor, constant: marginWidth).isActive = true
        progressView.trailingAnchor.constraint(equalTo: currentStateDisplayCard.trailingAnchor, constant: -marginWidth).isActive = true
        progressView.bottomAnchor.constraint(equalTo: currentTimeLabel.topAnchor, constant: -8).isActive = true
        
        partitionBarGroupView.centerXAnchor.constraint(equalTo: progressView.centerXAnchor).isActive = true
        partitionBarGroupView.centerYAnchor.constraint(equalTo: progressView.centerYAnchor).isActive = true
        partitionBarGroupView.widthAnchor.constraint(equalTo: progressView.widthAnchor).isActive = true
        partitionBarGroupView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        currentTimeLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8).isActive = true
        currentTimeLabel.leadingAnchor.constraint(equalTo: currentStateDisplayCard.leadingAnchor, constant: marginWidth).isActive = true
        currentTimeLabel.bottomAnchor.constraint(equalTo: circularProgressView.topAnchor, constant: -marginWidth).isActive = true
        
        currentRemainingTimeLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8).isActive = true
        currentRemainingTimeLabel.trailingAnchor.constraint(equalTo: currentStateDisplayCard.trailingAnchor, constant: -marginWidth).isActive = true
        currentRemainingTimeLabel.bottomAnchor.constraint(equalTo: circularProgressView.topAnchor, constant: -marginWidth).isActive = true
        
        circularProgressView.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: marginWidth).isActive = true
        circularProgressView.leadingAnchor.constraint(equalTo: currentStateDisplayCard.leadingAnchor, constant: marginWidth).isActive = true
        circularProgressView.trailingAnchor.constraint(equalTo: currentStateDisplayCard.trailingAnchor, constant: -marginWidth).isActive = true
        circularProgressView.bottomAnchor.constraint(equalTo: currentStateDisplayCard.bottomAnchor, constant: -marginWidth).isActive = true
        circularProgressView.heightAnchor.constraint(equalToConstant: 160).isActive = true
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
    
    @objc func startAndPauseExercise() {
        if !isExerciseRunning {
            startAndPauseButton.setTitle("Pause", for: .normal)
            isExerciseRunning = true
        }else{
            startAndPauseButton.setTitle("Start", for: .normal)
            isExerciseRunning = false
        }
    }
    
    @objc func moveToNextPhase() {
        if currentPhaseIndex < 4 {
            currentTime = exercise.phases[0 ..< currentPhaseIndex+1].reduce(0.0, {$0 + $1.duration})
        }
    }
    
    @objc func moveToPrevPhase() {
        if currentPhaseIndex > 0 {
            currentTime = exercise.phases[0 ..< currentPhaseIndex-1].reduce(0.0, {$0 + $1.duration})
        } else {
            currentTime = 0
        }
    }
}


class CircularProgressView: UIView {
    private let initialProgress: CGFloat = 0.0
    private var circleLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    private var circularPath: UIBezierPath!
    
    fileprivate lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "\(String(format:"%.1f", 0)) sec."
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func draw(_ rect: CGRect) {
        circularPath = UIBezierPath(arcCenter: CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0), radius: self.frame.size.height/2, startAngle: -.pi / 2, endAngle: 3 * .pi / 2, clockwise: true)
        circleLayer.path = circularPath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = .round
        circleLayer.lineWidth = 16
        circleLayer.strokeColor = UIColor.white.cgColor
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 10.0
        progressLayer.strokeEnd = initialProgress
        progressLayer.strokeColor = UIColor.systemBlue.cgColor
        layer.addSublayer(circleLayer)
        layer.addSublayer(progressLayer)
        layer.shadowOpacity = 0.2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 4, height: 4)
    }
    
    func setupView() {
        self.addSubview(progressLabel)
        setupConstraints()
    }
    
    func setupConstraints() {
        progressLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        progressLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    func progressAnimation(currentPahseTime: Float, currentPhaseProgress: Float) {
        progressLayer.strokeEnd = CGFloat(currentPhaseProgress)
        let formattedCurrentPahseTime = String(format:"%.1f", currentPahseTime)
        progressLabel.text = "\(formattedCurrentPahseTime) sec."
    }
}

class PartitionBarGroupView: UIView {
    var exercise: Exercise = Exercise(
        title: "Basic",
        description: "Basic exercise. There are 2 goals and 4 players on each team.",
        phases: [
            Phase(duration: 10),
            Phase(duration: 20),
            Phase(duration: 15),
            Phase(duration: 30)
        ]
    )
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let totalDuration: Float = exercise.phases.reduce(0.0, {$0 + $1.duration})
        for phaseIndex in 0 ..< exercise.phases.count-1 {
            let totalDuration_ = exercise.phases[0 ... phaseIndex].reduce(0.0, {$0 + $1.duration})
            let partitionBarX = Int(Float(self.frame.size.width) * Float(totalDuration_) /  Float(totalDuration))
            let line = UIBezierPath()
            line.move(to: CGPoint(x: partitionBarX, y: 0))
            line.addLine(to:CGPoint(x: partitionBarX, y: Int(self.frame.size.height)))
            line.close()
            UIColor.black.setStroke()
            line.lineWidth = 2.0
            line.stroke()
        }
    }
}
