//
//  ExerciseExecutionViewController.swift
//  winnerlights-ios-mobile-client
//
//  Created by human on 2020/09/23.
//

import UIKit

struct Goal {
    let position: GoalPosition
    let color: GoalColor
}
enum GoalPosition {
    case upperLeft
    case lowerLeft
    case upperRight
    case lowerRight
}
enum GoalColor {
    case pink
    case blue
}
struct Phase {
    let duration: Float
    let goals: [Goal]
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
    let cornerRadius: CGFloat = 20
    let shadowOpacity: Float = 0.2
    let marginWidth: CGFloat = 16
    let shadowOffset: CGSize = CGSize(width: 4, height: 4)
    let buttonHeight: CGFloat = 60
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
            let totalDurationTilCurrentPhase = exercise.phases[0 ..< currentPhaseIndex+1].reduce(0.0, {$0 + $1.duration})
            circularProgressView.updateProgress(
                currentPahseTime: totalDurationTilCurrentPhase - currentTime,
                currentPhaseProgress: (totalDurationTilCurrentPhase - currentTime)/exercise.phases[currentPhaseIndex].duration)
            let totalDuration: Float = exercise.phases.reduce(0.0, {$0 + $1.duration})
            progressView.setProgress(currentTime/totalDuration, animated: true)
            phaseCountLabel.text = "Phase" + " " + "\(String(currentPhaseIndex+1))/\(String(exercise.phases.count))"
            currentTimeLabel.text = String(format:"%.0f", (currentTime/60.0).rounded(.towardZero))+":"+String(format:"%02.0f", floor(currentTime.truncatingRemainder(dividingBy: 60.0)))
            currentRemainingTimeLabel.text = String(format:"%.0f", ((totalDuration-currentTime)/60.0).rounded(.towardZero))+":"+String(format:"%02.0f", ceil((totalDuration-currentTime).truncatingRemainder(dividingBy: 60.0)))
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
    
    fileprivate lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = String(format:"%.0f", (currentTime/60.0).rounded(.towardZero))+":"+String(format:"%02.0f", floor(currentTime.truncatingRemainder(dividingBy: 60.0)))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    fileprivate lazy var currentRemainingTimeLabel: UILabel = {
        let label = UILabel()
        let totalDuration: Float = exercise.phases.reduce(0.0, {$0 + $1.duration})
        label.text = String(format:"%.0f", (totalDuration/60.0).rounded(.towardZero))+":"+String(format:"%02.0f", floor(totalDuration.truncatingRemainder(dividingBy: 60.0)))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .medium)
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
        let view = PartitionBarGroupView(phases: exercise.phases)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate lazy var circularProgressView: CircularProgressView = {
        let view = CircularProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate lazy var teamuniformA: UIImageView = {
        let imageview = UIImageView(image: UIImage(named: "t-shirt-black-silhouette")?.withRenderingMode(.alwaysTemplate))
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.tintColor = .systemPink
        return imageview
    }()
    
    fileprivate lazy var teamuniformB: UIImageView = {
        let imageview = UIImageView(image: UIImage(named: "t-shirt-black-silhouette")?.withRenderingMode(.alwaysTemplate))
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.tintColor = .systemBlue
        return imageview
    }()
    
    fileprivate lazy var teamnameA: UILabel = {
        let label = UILabel()
        label.text = String("A")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    fileprivate lazy var teamnameB: UILabel = {
        let label = UILabel()
        label.text = String("B")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    fileprivate lazy var startAndPauseButton: UIButton = {
        let startImage = UIImage(systemName: "play.fill")
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor.black
        button.backgroundColor = .white
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.imageEdgeInsets = UIEdgeInsets(top: 15,left: 15,bottom: 15,right: 15)
        button.setImage(startImage, for: .normal)
        button.addTarget(self, action: #selector(startAndPauseExercise), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var backButton: UIButton = {
        let restartImage = UIImage(systemName: "backward.end.fill")!
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor.black
        button.backgroundColor = .white
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.imageEdgeInsets = UIEdgeInsets(top: 15,left: 15,bottom: 15,right: 15)
        button.setImage(restartImage, for: .normal)
        button.addTarget(self, action: #selector(moveToBeginning), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var nextButton: UIButton = {
        let nextImage = UIImage(systemName: "forward.fill")!
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor.black
        button.backgroundColor = .white
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.imageEdgeInsets = UIEdgeInsets(top: 15,left: 15,bottom: 15,right: 15)
        button.setImage(nextImage, for: .normal)
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
        currentStateDisplayCard.addSubview(teamuniformA)
        currentStateDisplayCard.addSubview(teamuniformB)
        currentStateDisplayCard.addSubview(teamnameA)
        currentStateDisplayCard.addSubview(teamnameB)
        view.addSubview(currentStateDisplayCard)
        view.addSubview(startAndPauseButton)
        view.addSubview(backButton)
        view.addSubview(nextButton)
        setupConstraints()
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(timerInterval), target:self,selector:#selector(self.updateCurrentTime), userInfo: nil, repeats: true)
        circularProgressView.updateProgress(
            currentPahseTime: exercise.phases[0].duration,
            currentPhaseProgress: 1.0
        )
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
        progressView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
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
        //circularProgressView.leadingAnchor.constraint(equalTo: teamuniformA.leadingAnchor, constant: marginWidth/4).isActive = true
        //circularProgressView.trailingAnchor.constraint(equalTo: currentStateDisplayCard.trailingAnchor, constant: -marginWidth).isActive = true
        circularProgressView.bottomAnchor.constraint(equalTo: currentStateDisplayCard.bottomAnchor, constant: -marginWidth).isActive = true
        circularProgressView.heightAnchor.constraint(equalToConstant: 160).isActive = true
        circularProgressView.widthAnchor.constraint(equalToConstant: 160).isActive = true
        circularProgressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        teamuniformA.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: marginWidth*2).isActive = true
        teamuniformA.leadingAnchor.constraint(equalTo: currentStateDisplayCard.leadingAnchor, constant: marginWidth).isActive = true
        teamuniformA.trailingAnchor.constraint(equalTo: circularProgressView.leadingAnchor, constant: -marginWidth).isActive = true
        teamuniformA.bottomAnchor.constraint(equalTo: currentStateDisplayCard.bottomAnchor, constant: -marginWidth*3.7).isActive = true
        teamuniformA.centerYAnchor.constraint(equalTo: circularProgressView.centerYAnchor).isActive = true
        
        teamuniformB.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: marginWidth*2).isActive = true
        teamuniformB.leadingAnchor.constraint(equalTo: circularProgressView.trailingAnchor, constant: marginWidth).isActive = true
        teamuniformB.trailingAnchor.constraint(equalTo: currentStateDisplayCard.trailingAnchor, constant: -marginWidth).isActive = true
        teamuniformB.bottomAnchor.constraint(equalTo: currentStateDisplayCard.bottomAnchor, constant: -marginWidth*3.7).isActive = true
        teamuniformB.centerYAnchor.constraint(equalTo: circularProgressView.centerYAnchor).isActive = true
        
        teamnameA.centerXAnchor.constraint(equalTo: teamuniformA.centerXAnchor).isActive = true
        teamnameA.centerYAnchor.constraint(equalTo: teamuniformA.centerYAnchor).isActive = true
        
        teamnameB.centerXAnchor.constraint(equalTo: teamuniformB.centerXAnchor).isActive = true
        teamnameB.centerYAnchor.constraint(equalTo: teamuniformB.centerYAnchor).isActive = true
        
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
        let pauseImage = UIImage(systemName: "pause.fill")!
        let startImage = UIImage(systemName: "play.fill")!
        if !isExerciseRunning {
            startAndPauseButton.setImage(pauseImage, for: .normal)
            isExerciseRunning = true
        }else{
            startAndPauseButton.setImage(startImage, for: .normal)
            isExerciseRunning = false
        }
    }
    
    @objc func moveToNextPhase() {
        if currentPhaseIndex < 4 {
            currentTime = exercise.phases[0 ..< currentPhaseIndex+1].reduce(0.0, {$0 + $1.duration})
        }
    }
    
    @objc func moveToBeginning() {
            currentTime = 0
    }
}


class CircularProgressView: UIView {
    private let initialProgress: CGFloat = 1.0
    private var circleLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    private var circularPath: UIBezierPath!
    
    fileprivate lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 30, weight: .medium)
        label.text = String(format:"%.0f", 0)
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
        circularPath = UIBezierPath(arcCenter: CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0), radius: self.frame.size.height/2.5, startAngle: 3 * .pi / 2, endAngle: -.pi / 2, clockwise: false)
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
    
    func updateProgress(currentPahseTime: Float, currentPhaseProgress: Float) {
        progressLayer.strokeEnd = CGFloat(currentPhaseProgress)
        let formattedCurrentPahseTime = String(format:"%.0f", ceil(currentPahseTime.truncatingRemainder(dividingBy: 60.0)))
        let formattedCurrentPahseTimeMinute = String(format:"%.0f", (currentPahseTime/60.0).rounded(.towardZero))
        let formattedCurrentPahseTimeSecond = String(format:"%02.0f", ceil(currentPahseTime.truncatingRemainder(dividingBy: 60.0)))
        if  currentPahseTime > 60.0{
        progressLabel.text = "\(formattedCurrentPahseTimeMinute):\(formattedCurrentPahseTimeSecond)"
        } else if ceil(currentPahseTime.truncatingRemainder(dividingBy: 60.0)) == 60.0 {
        let formattedCurrentPahseTimeSpecialMinute = String(format:"%.0f", (currentPahseTime/60.0).rounded(.towardZero)+1)
        progressLabel.text = "\(formattedCurrentPahseTimeSpecialMinute):00"
        }
        else {
        progressLabel.text = "\(formattedCurrentPahseTime)"
        }
    }
}

class PartitionBarGroupView: UIView {
    var phases: [Phase]!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    init(phases: [Phase]) {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.phases = phases
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let totalDuration: Float = phases.reduce(0.0, {$0 + $1.duration})
        for phaseIndex in 0 ..< phases.count-1 {
            let totalDuration_ = phases[0 ... phaseIndex].reduce(0.0, {$0 + $1.duration})
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

class PitchView: UIView {
    var phase: Phase!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }

    init(phase: Phase) {
        super.init(frame: .zero)
        self.phase = phase
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let goalWidth: CGFloat = 0.02 * self.frame.width
        let goalHeight: CGFloat = 0.2 * self.frame.height
        let verticalMarginToNearestHorizontalLine: CGFloat = 0.1 * self.frame.width
        for goal in phase.goals {
            switch goal.color {
                case .pink:
                    UIColor.systemPink.setFill()
                case .blue:
                    UIColor.systemBlue.setFill()
            }
            switch goal.position {
                case .upperLeft:
                    drawGoal(rect: CGRect(x: 0, y: verticalMarginToNearestHorizontalLine, width: goalWidth, height: goalHeight))
                case .lowerLeft:
                    drawGoal(rect: CGRect(x: 0, y: self.frame.height - verticalMarginToNearestHorizontalLine - goalHeight, width: goalWidth, height: goalHeight))
                case .upperRight:
                    drawGoal(rect: CGRect(x: self.frame.width - goalWidth, y: verticalMarginToNearestHorizontalLine, width: goalWidth, height: goalHeight))
                case .lowerRight:
                    drawGoal(rect: CGRect(x: self.frame.width - goalWidth, y: self.frame.height - verticalMarginToNearestHorizontalLine - goalHeight, width: goalWidth, height: goalHeight))
            }
        }
        self.addSubview(Player1)
        self.addSubview(Player2)
        
        //drawPlayer1()
//        drawPlayer2()
//        drawPlayer3()
//        drawPlayer4()
//        drawPlayer5()
//        drawPlayer6()
//        drawPlayer7()
//        drawPlayer8()
        drawCenterVerticalLine()
        drawCenterCircle()
        playerConstraints()
    }

        func playerConstraints() {
            Player1.topAnchor.constraint(equalTo: self.topAnchor, constant: self.frame.height*0.3).isActive = true
            Player1.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.frame.width*0.135).isActive = true
            Player1.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.frame.width*0.735).isActive = true
            Player1.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.frame.height*0.55).isActive = true


            Player2.topAnchor.constraint(equalTo: self.topAnchor, constant: self.frame.height*0.3).isActive = true
            Player2.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1).isActive = true
            Player2.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.frame.height*0.55).isActive = true
        }

    func drawGoal(rect: CGRect) {
        let goalRect = UIBezierPath(rect: rect)
        goalRect.fill()
    }
    
    fileprivate lazy var Player1: UIImageView = {
            let imageview = UIImageView(image: UIImage(named: "t-shirt-black-silhouette")?.withRenderingMode(.alwaysTemplate))
            imageview.translatesAutoresizingMaskIntoConstraints = false
            imageview.tintColor = .systemPink
        imageview.contentMode = UIView.ContentMode.scaleAspectFit
            return imageview
        }()
    fileprivate lazy var Player2: UIImageView = {
            let imageview = UIImageView(image: UIImage(named: "t-shirt-black-silhouette")?.withRenderingMode(.alwaysTemplate))
            imageview.translatesAutoresizingMaskIntoConstraints = false
            imageview.tintColor = .systemPink
        imageview.contentMode = UIView.ContentMode.scaleAspectFit
            return imageview
        }()
    

//    func drawPlayer1() {
//        let head = UIBezierPath(arcCenter: CGPoint(x: self.frame.width*0.165, y: self.frame.height*0.275), radius: self.frame.height*0.03, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
//        UIColor.systemPink.setFill()
//        head.fill()
//        let body = UIBezierPath()
//        body.move(to: CGPoint(x: self.frame.width*0.165, y: self.frame.height*0.445))
//        body.addLine(to: CGPoint(x: self.frame.width*0.135, y: self.frame.height*0.325))
//        body.addLine(to: CGPoint(x: self.frame.width*0.195, y: self.frame.height*0.325))
//        body.close()
//        UIColor.systemPink.setFill()
//        body.fill()
//    }
    
//    func drawPlayer2() {
//        let head = UIBezierPath(arcCenter: CGPoint(x: self.frame.width*0.335, y: self.frame.height*0.275), radius: self.frame.height*0.03, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
//        UIColor.systemPink.setFill()
//        head.fill()
//        let body = UIBezierPath()
//        body.move(to: CGPoint(x: self.frame.width*0.335, y: self.frame.height*0.445))
//        body.addLine(to: CGPoint(x: self.frame.width*0.305, y: self.frame.height*0.325))
//        body.addLine(to: CGPoint(x: self.frame.width*0.365, y: self.frame.height*0.325))
//        body.close()
//        UIColor.systemPink.setFill()
//        body.fill()
//    }
//
//    func drawPlayer3() {
//        let head = UIBezierPath(arcCenter: CGPoint(x: self.frame.width*0.165, y: self.frame.height*0.6), radius: self.frame.height*0.03, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
//        UIColor.systemPink.setFill()
//        head.fill()
//        let body = UIBezierPath()
//        body.move(to: CGPoint(x: self.frame.width*0.165, y: self.frame.height*0.77))
//        body.addLine(to: CGPoint(x: self.frame.width*0.135, y: self.frame.height*0.65))
//        body.addLine(to: CGPoint(x: self.frame.width*0.195, y: self.frame.height*0.65))
//        body.close()
//        UIColor.systemPink.setFill()
//        body.fill()
//    }
//    func drawPlayer4() {
//        let head = UIBezierPath(arcCenter: CGPoint(x: self.frame.width*0.335, y: self.frame.height*0.6), radius: self.frame.height*0.03, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
//        UIColor.systemPink.setFill()
//        head.fill()
//        let body = UIBezierPath()
//        body.move(to: CGPoint(x: self.frame.width*0.335, y: self.frame.height*0.77))
//        body.addLine(to: CGPoint(x: self.frame.width*0.305, y: self.frame.height*0.65))
//        body.addLine(to: CGPoint(x: self.frame.width*0.365, y: self.frame.height*0.65))
//        body.close()
//        UIColor.systemPink.setFill()
//        body.fill()
//    }
//    func drawPlayer5() {
//        let head = UIBezierPath(arcCenter: CGPoint(x: self.frame.width*0.665, y: self.frame.height*0.275), radius: self.frame.height*0.03, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
//        UIColor.systemBlue.setFill()
//        head.fill()
//        let body = UIBezierPath()
//        body.move(to: CGPoint(x: self.frame.width*0.665, y: self.frame.height*0.445))
//        body.addLine(to: CGPoint(x: self.frame.width*0.635, y: self.frame.height*0.325))
//        body.addLine(to: CGPoint(x: self.frame.width*0.695, y: self.frame.height*0.325))
//        body.close()
//        UIColor.systemBlue.setFill()
//        body.fill()
//    }
//    func drawPlayer6() {
//        let head = UIBezierPath(arcCenter: CGPoint(x: self.frame.width*0.835, y: self.frame.height*0.275), radius: self.frame.height*0.03, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
//        UIColor.systemBlue.setFill()
//        head.fill()
//        let body = UIBezierPath()
//        body.move(to: CGPoint(x: self.frame.width*0.835, y: self.frame.height*0.445))
//        body.addLine(to: CGPoint(x: self.frame.width*0.805, y: self.frame.height*0.325))
//        body.addLine(to: CGPoint(x: self.frame.width*0.865, y: self.frame.height*0.325))
//        body.close()
//        UIColor.systemBlue.setFill()
//        body.fill()
//    }
//    func drawPlayer7() {
//        let head = UIBezierPath(arcCenter: CGPoint(x: self.frame.width*0.665, y: self.frame.height*0.6), radius: self.frame.height*0.03, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
//        UIColor.systemBlue.setFill()
//        head.fill()
//        let body = UIBezierPath()
//        body.move(to: CGPoint(x: self.frame.width*0.665, y: self.frame.height*0.77))
//        body.addLine(to: CGPoint(x: self.frame.width*0.635, y: self.frame.height*0.65))
//        body.addLine(to: CGPoint(x: self.frame.width*0.695, y: self.frame.height*0.65))
//        body.close()
//        UIColor.systemBlue.setFill()
//        body.fill()
//    }
//    func drawPlayer8() {
//        let head = UIBezierPath(arcCenter: CGPoint(x: self.frame.width*0.835, y: self.frame.height*0.6), radius: self.frame.height*0.03, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
//        UIColor.systemBlue.setFill()
//        head.fill()
//        let body = UIBezierPath()
//        body.move(to: CGPoint(x: self.frame.width*0.835, y: self.frame.height*0.77))
//        body.addLine(to: CGPoint(x: self.frame.width*0.805, y: self.frame.height*0.65))
//        body.addLine(to: CGPoint(x: self.frame.width*0.865, y: self.frame.height*0.65))
//        body.close()
//        UIColor.systemBlue.setFill()
//        body.fill()
//    }
//
    func drawCenterVerticalLine() {
        let line = UIBezierPath()
        line.move(to: CGPoint(x: self.frame.width/2, y: 0))
        line.addLine(to:CGPoint(x: self.frame.width/2, y: self.frame.height))
        line.close()
        UIColor.black.setStroke()
        line.stroke()
    }
    
    func drawCenterCircle() {
        let centerCircle = UIBezierPath(arcCenter: CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0), radius: 0.3 * self.frame.size.height / 2, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        UIColor.black.setStroke()
        centerCircle.stroke()
    }
}
