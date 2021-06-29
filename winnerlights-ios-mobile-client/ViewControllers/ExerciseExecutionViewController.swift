//
//  ExerciseExecutionViewController.swift
//  winnerlights-ios-mobile-client
//
//  Created by human on 2020/09/23.
//

import UIKit
import nRFMeshProvision

protocol ModelControlDelegate: AnyObject {
    func publish(_ message: MeshMessage, description: String, fromModel model: Model)
}

protocol PublicationDelegate {
    /// This method is called when the publication has changed.
    func publicationChanged()
}

struct Goal {
    let position: GoalPosition
    let color: GoalColor
    var node: Node!
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
    var duration: Float
    let goals: [Goal]
}
struct Exercise {
    var title: String
    var description: String
    var phases: [Phase]
}
struct GoalNodeRelation {
    var position: GoalPosition
    var node: Node
}
struct Job {
    var clientModel: Model
    var address: MeshAddress
    var targetState: Bool
    var colorCode: UInt8
}
struct _Job {
    var clientModel: Model
    var address: MeshAddress
    var targetState: Bool
}

class ExerciseExecutionViewController: ProgressViewController {
    var LEDGroup: Group!
    var LeftGroup: Group!
    var RightGroup: Group!
    var LEDGroupAddress: MeshAddress? = MeshAddress(0xC007)
    var LeftGroupAddress: MeshAddress? = MeshAddress(0xC001)
    var RightGroupAddress: MeshAddress? = MeshAddress(0xC002)
    var j: Int = 0
    var k: Int = 4
    var exercise: Exercise!
    let cornerRadius: CGFloat = 20
    let shadowOpacity: Float = 0.2
    let marginWidth: CGFloat = 16
    let shadowOffset: CGSize = CGSize(width: 4, height: 4)
    let buttonHeight: CGFloat = 60
    var currentPhaseIndex: Int = 0 {
        didSet {
            if currentPhaseIndex != oldValue  {
                let phase: Phase = exercise.phases[currentPhaseIndex]
                
                for goal in phase.goals {
                    let position: GoalPosition = goal.position
                    let filteredRelations = relations.filter{$0.position == position}
                    if filteredRelations.count != 0 {
                        let goalColor = goal.color
                        var colorCode: UInt8!
                        switch goalColor {
                        case .pink:
                            colorCode = 2
                            color.append(colorCode)
                        case .blue:
                            colorCode = 4
                            color.append(colorCode)
                        }
                    }
                }
                
//              グループ用
//                if color[k] != color[j] {
//                    publishColorMessage(clientModel: clientModel, colorCode: color[k])
//                }
//                if color[k+2] != color[j+2] {
//                    publishColorMessage(clientModel: _clientModel, colorCode: color[k+2])
//                }
                
//              1つずつ用
                for i in 0..<phase.goals.count{
                    if color[k+i] != color[j+i] {
                        publishColorMessage(clientModel: clientModelMatrix[i], colorCode: color[k+i])
                    }
                }
                
                // 5つの非同期処理を実行
//            let dispatchQueue = DispatchQueue.global(qos: .userInteractive)
//
//            print("Ω color publish")
//            for i in 0..<phase.goals.count {
//                dispatchQueue.async { [weak self] in
//                    self?.publishColorMessage(clientModel: (self?.clientModelMatrix[i])!, colorCode: self!.color[k+i])
//                    print("Ω ",i)
//                }
//            }
                
                j += phase.goals.count
                k += phase.goals.count
                pitch.phase = phase
                pitch.setNeedsDisplay()
            }
        }
    }
    var currentTime: Float = 0.0 {
        didSet {
            var _currentPhaseIndex: Int = 0
            for phaseIndex in 0 ..< exercise.phases.count {
                let partialTotalDuration = exercise.phases[0 ..< phaseIndex].reduce(0.0, {$0 + $1.duration})
                if (partialTotalDuration <= currentTime) {
                    _currentPhaseIndex = phaseIndex
                }
            }
            currentPhaseIndex = _currentPhaseIndex
            let totalDurationTilCurrentPhase = exercise.phases[0 ..< currentPhaseIndex+1].reduce(0.0, {$0 + $1.duration})
            circularProgressView.updateProgress(
                currentPahseTime: totalDurationTilCurrentPhase - currentTime,
                currentPhaseProgress: (totalDurationTilCurrentPhase - currentTime)/exercise.phases[currentPhaseIndex].duration)
            let totalDuration: Float = exercise.phases.reduce(0.0, {$0 + $1.duration})
            progressView.setProgress(currentTime/totalDuration, animated: true)
            phaseCountLabel.text = "Phase" + " " + "\(String(currentPhaseIndex+1))/\(String(exercise.phases.count))"
            currentTimeLabel.text = String(format:"%.0f", (currentTime/60.0).rounded(.towardZero))+":"+String(format:"%02.0f", floor(currentTime.truncatingRemainder(dividingBy: 60.0)))
            let minite:Int
            if ceil((totalDuration-currentTime).truncatingRemainder(dividingBy: 60.0)) == 60{
                minite = Int((totalDuration-currentTime) / 60)
                currentRemainingTimeLabel.text = String(minite + 1) + ":00"
            }
            else{
            currentRemainingTimeLabel.text = String(format:"%.0f", ((totalDuration-currentTime)/60.0).rounded(.towardZero))+":"+String(format:"%02.0f", ceil((totalDuration-currentTime).truncatingRemainder(dividingBy: 60.0)))
            }
        }
    }
    var timer: Timer!
    var timerInterval: Float = 0.1
    var isExerciseRunning: Bool = false
    var targetState: Bool = false
    
    var clientModelMatrix: [Model] = []
    var clientModel: Model!
    var _clientModel: Model!
    var __clientModel: Model!
    var ___clientModel: Model!
    var ____clientModel: Model!
    var targetElmentIndex:Int = 0
    var jobs: [Job]!
    var currentJobIndex: Int!
    var relations: [GoalNodeRelation] = []
    
    var _jobs: [_Job]!
    var _currentJobIndex: Int!
    
    var nodes: [Node] = []
    var groups: [Group] = []
    var color: [UInt8] = []
    var applicationKey: ApplicationKey!
    private var newName: String!
    private var newKey: Data! = Data.random128BitKey()
    private var keyIndex: KeyIndex!
    private var newBoundNetworkKeyIndex: KeyIndex?
    private var ttl: UInt8 = 0xFF
    private var periodSteps: UInt8 = 0
    private var periodResolution: StepResolution = .hundredsOfMilliseconds
    private var retransmissionCount: UInt8 = 10
    private var retransmissionIntervalSteps: UInt8 = 0
    weak var delegate: ProvisioningViewDelegate?
    var key: Key? {
        didSet {
            if let key = key {
                newKey = key.key
            }
            isApplicationKey = key is ApplicationKey
        }
    }
    var isApplicationKey: Bool! {
        didSet {
            let network = MeshNetworkManager.instance.meshNetwork!
            
            newName  = key?.name ?? defaultName
            keyIndex = key?.index ?? (isApplicationKey ?
                network.nextAvailableApplicationKeyIndex :
                network.nextAvailableNetworkKeyIndex)
            if isApplicationKey {
                newBoundNetworkKeyIndex = (key as? ApplicationKey)?.boundNetworkKeyIndex ?? 0
            } else {
                newBoundNetworkKeyIndex = nil
            }
        }
    }
    var defaultName: String {
        let network = MeshNetworkManager.instance.meshNetwork!
        return "App Key \((network.nextAvailableApplicationKeyIndex ?? 0xFFF) + 1)"
    }
    
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
        
        MeshNetworkManager.instance.delegate = self
        let network = MeshNetworkManager.instance.meshNetwork!
        nodes = network.nodes
        groups = network.groups
        
        relations = []
        let positions: [GoalPosition] = [
            .upperLeft,
            .lowerLeft,
            .upperRight,
            .lowerRight
        ]
        for (i, node) in nodes.filter({ !$0.isProvisioner }).enumerated() {
            relations.append(GoalNodeRelation(position: positions[i], node: node))
        }
        
        // Create 1 application key
        if network.applicationKeys.count == 0 {
            createAndSaveApplicationKey()
        }
        applicationKey = network.applicationKeys[0]
        // Create groups
        for group in groups {
            print("Ω", group.name)
        }
        
        if let provisionersNode = network.nodes.first(where: { $0.isLocalProvisioner }),
           let primaryElement = provisionersNode.elements.first(where: { $0.location == .first }),
           let _ = primaryElement.models.first(where: { $0.name == "Generic OnOff Client" })
           {
            clientModel = primaryElement.models.first(where: { $0.name == "Generic OnOff Client" })!
        }
        
        if let provisionersNode = network.nodes.first(where: { $0.isLocalProvisioner }),
           let secondElement = provisionersNode.elements.first(where: { $0.location == .second }),
           let _ = secondElement.models.first(where: { $0.name == "Generic OnOff Client" })
           {
            _clientModel = secondElement.models.first(where: { $0.name == "Generic OnOff Client" })!
        }
        
        if let provisionersNode = network.nodes.first(where: { $0.isLocalProvisioner }),
           let thirdElement = provisionersNode.elements.first(where: { $0.location == .third }),
           let _ = thirdElement.models.first(where: { $0.name == "Generic OnOff Client" })
           {
            __clientModel = thirdElement.models.first(where: { $0.name == "Generic OnOff Client" })!
        }

        if let provisionersNode = network.nodes.first(where: { $0.isLocalProvisioner }),
           let fourthElement = provisionersNode.elements.first(where: { $0.location == .fourth }),
           let _ = fourthElement.models.first(where: { $0.name == "Generic OnOff Client" })
           {
            ___clientModel = fourthElement.models.first(where: { $0.name == "Generic OnOff Client" })!
        }

        if let provisionersNode = network.nodes.first(where: { $0.isLocalProvisioner }),
           let fifthElement = provisionersNode.elements.first(where: { $0.location == .fifth }),
           let _ = fifthElement.models.first(where: { $0.name == "Generic OnOff Client" })
           {
            ____clientModel = fifthElement.models.first(where: { $0.name == "Generic OnOff Client" })!
        }

        clientModelMatrix = [_clientModel, __clientModel, ___clientModel, ____clientModel]
        
//      1つずつ用
        defer {
            publishColorMessage(clientModel: clientModelMatrix[3], colorCode: 4)
        }
        defer {
            publishColorMessage(clientModel: clientModelMatrix[2], colorCode: 4)
        }
        defer {
            publishColorMessage(clientModel: clientModelMatrix[1], colorCode: 2)
        }
        defer {
            publishColorMessage(clientModel: clientModelMatrix[0], colorCode: 2)
        }
        
        color = []
        let phase: Phase = exercise.phases[0]
        for goal in phase.goals {
            let position: GoalPosition = goal.position
            let filteredRelations = relations.filter{$0.position == position}
            if filteredRelations.count != 0 {
                let goalColor = goal.color
                var colorCode: UInt8!
                switch goalColor {
                case .pink:
                    colorCode = 2
                    color.append(colorCode)
                case .blue:
                    colorCode = 4
                    color.append(colorCode)
                }
            }
        }
        
//        グループ用
//        setPublication(clientModel: clientModel, destinationAddress: LeftGroupAddress)
//        setPublication(clientModel: _clientModel, destinationAddress: RightGroupAddress)
        
//      1つずつ用
        for i in 0..<4 {
            setPublication(clientModel: clientModelMatrix[i], destinationAddress: MeshAddress(nodes[i+1].elements[0].unicastAddress))
        }
        
            // 5つの非同期処理を実行
//        let dispatchQueue = DispatchQueue.global(qos: .userInteractive)
//
//        print("Ω color publish")
//        for i in 1...4 {
//            dispatchQueue.async { [weak self] in
//                self?.publishColorMessage(clientModel: (self?.clientModelMatrix[i-1])!, colorCode: self!.color[i-1])
//                print("Ω ",i)
//            }
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MeshNetworkManager.instance.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let workingTimer = timer{
            workingTimer.invalidate()
        }
    }
    
    deinit {
            print("Ω ExerciseExecutionViewControllerがdeinitされました")
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
        circularProgressView.heightAnchor.constraint(equalToConstant: view.frame.width*0.4).isActive = true
        circularProgressView.widthAnchor.constraint(equalToConstant: view.frame.width*0.4).isActive = true
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
    
    func createAndSaveNewGroup(name: String, address: MeshAddress) {
        let network = MeshNetworkManager.instance.meshNetwork!
        // Try assigning next available Group Address.
        LEDGroup = try! Group(name: name, address: address)
        try! network.add(group: LEDGroup)
        if MeshNetworkManager.instance.save() {
            presentAlert(title: "Group Succesfully Saved", message: "New group saved.")
        } else {
            presentAlert(title: "Error", message: "Mesh configuration could not be saved.")
        }
    }
    
    func publishColorMessage(clientModel: Model,colorCode: UInt8) {
        _ = MeshNetworkManager.instance.publish(GenericOnOffSet(colorCode, transitionTime: TransitionTime(0.0), delay: 1), fromModel: clientModel)
    }
    
    func setPublication(clientModel: Model, destinationAddress: MeshAddress?) {
        // Set new publication
        print("Ω setPublication",clientModel)
        guard let destination = destinationAddress, let applicationKey = applicationKey else {
            return
        }
        let publish = Publish(to: destination, using: applicationKey,
                              usingFriendshipMaterial: false, ttl: self.ttl,
                              periodSteps: self.periodSteps, periodResolution: self.periodResolution,
                              retransmit: Publish.Retransmit(publishRetransmitCount: self.retransmissionCount,
                                                             intervalSteps: self.retransmissionIntervalSteps))
        let message: ConfigMessage =
            ConfigModelPublicationSet(publish, to: clientModel) ??
            ConfigModelPublicationVirtualAddressSet(publish, to: clientModel)!
        try! MeshNetworkManager.instance.send(message, to: clientModel)
    }
    
    func createAndSaveApplicationKey() {
        let network = MeshNetworkManager.instance.meshNetwork!
        newName = "New Application Key"
        key = try! network.add(applicationKey: newKey, name: newName)
        if MeshNetworkManager.instance.save() {
        } else {
            presentAlert(title: "Error", message: "Mesh configuration could not be saved.")
        }
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
        if currentPahseTime <= 59 {
            progressLabel.text = String(format:"%.0f", ceil(currentPahseTime))
        } else if currentPahseTime.truncatingRemainder(dividingBy: 60.0) > 59 {
            let minute = String(format:"%.0f", currentPahseTime/60.0)
            progressLabel.text = "\(minute):00"
        } else {
            let minute = String(format:"%.0f", (currentPahseTime/60.0).rounded(.towardZero))
            let second = String(format:"%02.0f", ceil(currentPahseTime.truncatingRemainder(dividingBy: 60.0)))
            progressLabel.text = "\(minute):\(second)"
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
        let goalWidth: CGFloat = 0.03 * self.frame.width
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
        self.addSubview(Player3)
        self.addSubview(Player4)
        self.addSubview(Player5)
        self.addSubview(Player6)
        self.addSubview(Player7)
        self.addSubview(Player8)
        drawCenterVerticalLine()
        drawCenterCircle()
    }

    func drawGoal(rect: CGRect) {
        let goalRect = UIBezierPath(rect: rect)
        goalRect.fill()
    }
    
    fileprivate lazy var Player1: UIImageView = {
        let imageview = UIImageView(image: UIImage(named: "t-shirt-black-silhouette")?.withRenderingMode(.alwaysTemplate))
        imageview.tintColor = .systemPink
        imageview.frame = CGRect(x: self.frame.width*0.075, y: self.frame.height*0.275, width: self.frame.width*0.125, height: self.frame.width*0.125)
        imageview.contentMode = UIView.ContentMode.scaleAspectFit
            return imageview
        }()
    
    fileprivate lazy var Player2: UIImageView = {
        let imageview = UIImageView(image: UIImage(named: "t-shirt-black-silhouette")?.withRenderingMode(.alwaysTemplate))
        imageview.tintColor = .systemPink
        imageview.frame = CGRect(x: self.frame.width*0.275, y: self.frame.height*0.275, width: self.frame.width*0.125, height: self.frame.width*0.125)
        imageview.contentMode = UIView.ContentMode.scaleAspectFit
            return imageview
        }()
    
    fileprivate lazy var Player3: UIImageView = {
        let imageview = UIImageView(image: UIImage(named: "t-shirt-black-silhouette")?.withRenderingMode(.alwaysTemplate))
        imageview.tintColor = .systemPink
        imageview.frame = CGRect(x: self.frame.width*0.075, y: self.frame.height*0.6, width: self.frame.width*0.125, height: self.frame.width*0.125)
        imageview.contentMode = UIView.ContentMode.scaleAspectFit
            return imageview
        }()
    
    fileprivate lazy var Player4: UIImageView = {
        let imageview = UIImageView(image: UIImage(named: "t-shirt-black-silhouette")?.withRenderingMode(.alwaysTemplate))
        imageview.tintColor = .systemPink
        imageview.frame = CGRect(x: self.frame.width*0.275, y: self.frame.height*0.6, width: self.frame.width*0.125, height: self.frame.width*0.125)
        imageview.contentMode = UIView.ContentMode.scaleAspectFit
            return imageview
        }()
    
    fileprivate lazy var Player5: UIImageView = {
        let imageview = UIImageView(image: UIImage(named: "t-shirt-black-silhouette")?.withRenderingMode(.alwaysTemplate))
        imageview.tintColor = .systemBlue
        imageview.frame = CGRect(x: self.frame.width*0.6, y: self.frame.height*0.275, width: self.frame.width*0.125, height: self.frame.width*0.125)
        imageview.contentMode = UIView.ContentMode.scaleAspectFit
            return imageview
        }()

    fileprivate lazy var Player6: UIImageView = {
        let imageview = UIImageView(image: UIImage(named: "t-shirt-black-silhouette")?.withRenderingMode(.alwaysTemplate))
        imageview.tintColor = .systemBlue
        imageview.frame = CGRect(x: self.frame.width*0.8, y: self.frame.height*0.275, width: self.frame.width*0.125, height: self.frame.width*0.125)
        imageview.contentMode = UIView.ContentMode.scaleAspectFit
            return imageview
        }()

    fileprivate lazy var Player7: UIImageView = {
        let imageview = UIImageView(image: UIImage(named: "t-shirt-black-silhouette")?.withRenderingMode(.alwaysTemplate))
        imageview.tintColor = .systemBlue
        imageview.frame = CGRect(x: self.frame.width*0.6, y: self.frame.height*0.6, width: self.frame.width*0.125, height: self.frame.width*0.125)
        imageview.contentMode = UIView.ContentMode.scaleAspectFit
            return imageview
        }()

    fileprivate lazy var Player8: UIImageView = {
        let imageview = UIImageView(image: UIImage(named: "t-shirt-black-silhouette")?.withRenderingMode(.alwaysTemplate))
        imageview.tintColor = .systemBlue
        imageview.frame = CGRect(x: self.frame.width*0.8, y: self.frame.height*0.6, width: self.frame.width*0.125, height: self.frame.width*0.125)
        imageview.contentMode = UIView.ContentMode.scaleAspectFit
            return imageview
        }()
    
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

extension ExerciseExecutionViewController: MeshNetworkDelegate{
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            didReceiveMessage message: MeshMessage,
                            sentFrom source: Address, to destination: Address) {
        print("Ω didReceiveMessage", message)
        guard !(message is ConfigNodeReset) else {
            (UIApplication.shared.delegate as! AppDelegate).meshNetworkDidChange()
            done() {
                let rootViewControllers = self.presentingViewController?.children
                self.dismiss(animated: true) {
                    rootViewControllers?.forEach {
                        if let navigationController = $0 as? UINavigationController {
                            navigationController.popToRootViewController(animated: true)
                        }
                    }
                }
            }
            return
        }
        
        // Handle the message based on its type.
//        switch message {
//
//        case let status as ConfigModelPublicationStatus:
//            if status.status == .success {
//                print("Ω status",status)
//                print("Ω elementAddress",status.elementAddress)
//                print("¥ function publish",#function)
//                publishColorMessage()
//            }
//            done() {
//                if status.status == .success {
//                    self.dismiss(animated: true)
//                } else {
//                    self.presentAlert(title: "Error", message: status.message)
//                }
//            }
//
////        case let status as ConfigModelSubscriptionStatus:
//
//        case let status as GenericOnOffStatus:
//            let job: Job = jobs[currentJobIndex]
//            let address: MeshAddress = job.address
//            let targetState: Bool = job.targetState
//            let actualState: UInt8 = status.color
//            if address.address == source {
////                print("≈\(source) received message")
//                if currentJobIndex < jobs.count-1 {
//                    currentJobIndex += 1
//                    print("Ω currentJobIndex",currentJobIndex)
//                    setPublication()
//                }
//            }
//
//        case is ConfigNodeReset:
//            // The node has been reset remotely.
//            (UIApplication.shared.delegate as! AppDelegate).meshNetworkDidChange()
//            presentAlert(title: "Reset", message: "The mesh network was reset remotely.")
//
//        default:
//            break
//        }
        
        switch message {

        case let status as ConfigModelPublicationStatus:
            if status.status == .success {
            }
            done() {
                if status.status == .success {
                    self.dismiss(animated: true)
                } else {
                    self.presentAlert(title: "Error", message: status.message)
                }
            }

        case let status as GenericOnOffStatus:
            print("Ω", status)

        case is ConfigNodeReset:
            // The node has been reset remotely.
            (UIApplication.shared.delegate as! AppDelegate).meshNetworkDidChange()
            presentAlert(title: "Reset", message: "The mesh network was reset remotely.")

        default:
            break
        }
    }
    
    func meshNetworkManager(_ manager: MeshNetworkManager, didSendMessage message: MeshMessage, from localElement: Element, to destination: Address) {
    }
    
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            failedToSendMessage message: MeshMessage,
                            from localElement: Element, to destination: Address,
                            error: Error) {
        done() {
            self.presentAlert(title: "Error", message: error.localizedDescription)
        }
    }
}

extension ExerciseExecutionViewController: ModelControlDelegate {
    
    func publish(_ message: MeshMessage, description: String, fromModel model: Model) {
        start(description) {
            return MeshNetworkManager.instance.publish(message, fromModel: model)
        }
    }
}
