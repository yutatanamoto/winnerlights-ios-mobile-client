//
//  ExerciseDetailViewController.swift
//  winnerlights-ios-mobile-client
//
//  Created by human on 2020/09/23.
//

import UIKit
import nRFMeshProvision

class ExerciseDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, MeshNetworkDelegate {
    func meshNetworkManager(_ manager: MeshNetworkManager, didReceiveMessage message: MeshMessage, sentFrom source: Address, to destination: Address) {
    }
    
    var LeftGroup: Group!
    var RightGroup: Group!
    var LeftGroupAddress: MeshAddress? = MeshAddress(0xC001)
    var RightGroupAddress: MeshAddress? = MeshAddress(0xC002)
    var clientModelMatrix: [Model] = []
    var clientModel: Model!
    var _clientModel: Model!
    var __clientModel: Model!
    var ___clientModel: Model!
    var relations: [GoalNodeRelation] = []
    var nodes: [Node] = []
    var groups: [Group] = []
    var jobs: [Job]!
    var applicationKey: ApplicationKey!
    private var ttl: UInt8 = 0000
    private var periodSteps: UInt8 = 0
    private var periodResolution: StepResolution = .hundredsOfMilliseconds
    private var retransmissionCount: UInt8 = 10
    private var retransmissionIntervalSteps: UInt8 = 0
    
    let cornerRadius: CGFloat = 20
    let shadowOpacity: Float = 0.2
    let marginWidth: CGFloat = 16
    let shadowOffset: CGSize = CGSize(width: 4, height: 4)
    let topMarginWidth: CGFloat = 10
    let bottomMarginWidth: CGFloat = 10
    let buttonHeight: CGFloat = 60
    let dataSourceSecond:[Int] = ([Int])(0...59)
    let dataSourceMinute:[Int] = ([Int])(0...10)
    var backButtonTappedAt: Float = 0
    var exercise: Exercise!
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
            if currentTime == 0 {
                progressView.setProgress(currentTime/totalDuration, animated: false)
            } else {
                progressView.setProgress(currentTime/totalDuration, animated: true)
            }
            totalDurationTimeLabel.text = String(format:"%.0f", ((totalDuration)/60.0).rounded(.towardZero))+":"+String(format:"%02.0f", ceil((totalDuration).truncatingRemainder(dividingBy: 60.0)))
        }
    }
    var timer: Timer!
    var timerInterval: Float = 0.0
    var isExerciseRunning: Bool = true
    
    fileprivate lazy var exerciseTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = exercise.title
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate lazy var exerciseDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = exercise.description
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
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
        vc.exercise = exercise
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
    
    fileprivate lazy var totalDurationTimeLabel: UILabel = {
        let label = UILabel()
        let totalDuration: Float = exercise.phases.reduce(0.0, {$0 + $1.duration})
        label.text = String(format:"%.0f", (totalDuration/60.0).rounded(.towardZero))+":"+String(format:"%02.0f", floor(totalDuration.truncatingRemainder(dividingBy: 60.0)))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    fileprivate lazy var phaseTimeRollSecond: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.backgroundColor = .clear
        pickerView.tag = 1
        pickerView.isHidden = true
        pickerView.delegate   = self
        pickerView.dataSource = self
        return pickerView
    }()
    
    fileprivate lazy var phaseTimeRollMinute: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.backgroundColor = .clear
        pickerView.tag = 2
        pickerView.isHidden = true
        pickerView.delegate   = self
        pickerView.dataSource = self
        return pickerView
    }()
        
    fileprivate lazy var phaseTimeButtonSecond: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.setTitle("0", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(pickerViewDisplaySecond), for: .touchUpInside)
        return button
    }()
        
    @objc func pickerViewDisplaySecond() {
        phaseTimeButtonSecond.isHidden = true
        phaseTimeRollSecond.isHidden = false
    }
    
    fileprivate lazy var phaseTimeButtonMinute: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.setTitle("1", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(pickerViewDisplayMinute), for: .touchUpInside)
        return button
    }()
    
    @objc func pickerViewDisplayMinute() {
        phaseTimeButtonMinute.isHidden = true
        phaseTimeRollMinute.isHidden = false
    }
        
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?  {
        if pickerView.tag ==  1{
            return String(dataSourceSecond[row])
        }else{
            return String(dataSourceMinute[row])
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
        
    func rowSize(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag ==  1{
            return dataSourceSecond.count
        }else{
            return dataSourceMinute.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1{
            let selectedValue:Float = Float(dataSourceSecond[row])
            let currentPhaseDuration: Float = exercise.phases[0].duration
            let newPhaseDuration:Float =  60.0 * floor(currentPhaseDuration/60.0) + selectedValue
            for i in 0 ..< exercise.phases.count {
                exercise.phases[i].duration = newPhaseDuration
            }
            currentTime = 0
            phaseTimeButtonSecond.setTitle(String(dataSourceSecond[row]), for: .normal)
            phaseTimeRollSecond.isHidden = true
            phaseTimeButtonSecond.isHidden = false
        }else{
            let selectedValue:Float = Float(dataSourceMinute[row])
            let currentPhaseDuration: Float = exercise.phases[0].duration
            let remainder = currentPhaseDuration.truncatingRemainder(dividingBy: 60.0)
            let newPhaseDuration:Float = selectedValue * 60.0 + remainder
            for i in 0 ..< exercise.phases.count {
                exercise.phases[i].duration = newPhaseDuration
            }
            currentTime = 0
            phaseTimeButtonMinute.setTitle(String(dataSourceMinute[row]), for: .normal)
            phaseTimeRollMinute.isHidden = true
            phaseTimeButtonMinute.isHidden = false
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let cellLabel = UILabel()
        cellLabel.frame = CGRect(x: 0, y: 0, width: pickerView.rowSize(forComponent: 0).width, height: pickerView.rowSize(forComponent: 0).height)
        cellLabel.textAlignment = .center
        cellLabel.font = UIFont.boldSystemFont(ofSize: 25)
        cellLabel.backgroundColor = .clear
        cellLabel.textColor = .black
        if pickerView.tag == 1{
            cellLabel.text = String(dataSourceSecond[row])
            return cellLabel
        }else{
            cellLabel.text = String(dataSourceMinute[row])
            return cellLabel
        }
    }
    
    fileprivate lazy var phaseTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "Phase Duration"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    fileprivate lazy var colonLabel: UILabel = {
        let label = UILabel()
        label.text = ":"
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
        previewContainerView.addSubview(totalDurationTimeLabel)
        previewContainerView.addSubview(phaseTimeLabel)
        previewContainerView.addSubview(phaseTimeButtonSecond)
        previewContainerView.addSubview(phaseTimeRollSecond)
        previewContainerView.addSubview(colonLabel)
        previewContainerView.addSubview(phaseTimeButtonMinute)
        previewContainerView.addSubview(phaseTimeRollMinute)
        view.addSubview(previewContainerView)
        view.addSubview(executionButton)
        let phaseDuration: Float = exercise.phases[0].duration
        let minute: Int = Int(floor(phaseDuration/60.0))
        let second: Int = Int(phaseDuration.truncatingRemainder(dividingBy: 60.0))
        let minuteIndex: Int = dataSourceMinute.firstIndex(of: minute) ?? 0
        let secondIndex:Int = dataSourceSecond.firstIndex(of: second) ?? 0
        phaseTimeRollMinute.selectRow(minuteIndex, inComponent: 0, animated: false)
        phaseTimeButtonMinute.setTitle(String(dataSourceMinute[minuteIndex]), for: .normal)
        phaseTimeRollSecond.selectRow(secondIndex, inComponent: 0, animated: false)
        phaseTimeButtonSecond.setTitle(String(dataSourceSecond[secondIndex]), for: .normal)
        setupConstraints()
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(0.75), target:self,selector:#selector(self.updateCurrentTime), userInfo: nil, repeats: true)

//        MeshNetworkManager.instance.delegate = self
//        let network = MeshNetworkManager.instance.meshNetwork!
//        nodes = network.nodes
//        groups = network.groups
//        applicationKey = network.applicationKeys[0]
//
//        for group in groups {
//            print("Ω", group.name)
//        }
//        
//        if let _ = groups.first(where: { $0.name == "LeftGroup" }) {
//            LeftGroup = groups.first(where: { $0.name == "LeftGroup" })!
//        }
//        
//        if let _ = groups.first(where: { $0.name == "RightGroup" }) {
//            RightGroup = groups.first(where: { $0.name == "RightGroup" })!
//        } 
        
//        if let provisionersNode = network.nodes.first(where: { $0.isLocalProvisioner }),
//           let thirdElement = provisionersNode.elements.first(where: { $0.location == .third }),
//           let _ = thirdElement.models.first(where: { $0.name == "Generic OnOff Client" })
//           {
//            clientModel = thirdElement.models.first(where: { $0.name == "Generic OnOff Client" })!
//        }
//
//        setPublication(clientModel: clientModel, destinationAddress: LeftGroupAddress)
//
//        if let provisionersNode = network.nodes.first(where: { $0.isLocalProvisioner }),
//           let secondElement = provisionersNode.elements.first(where: { $0.location == .second }),
//           let _ = secondElement.models.first(where: { $0.name == "Generic OnOff Client" })
//           {
//            _clientModel = secondElement.models.first(where: { $0.name == "Generic OnOff Client" })!
//        }
//
//        setPublication(clientModel: _clientModel, destinationAddress: RightGroupAddress)

//        if let _ = nodes[1].elements[0].models.first(where: { $0.name == "Generic OnOff Server" })
//           {
//            let LeftModel = nodes[1].elements[0].models.first(where: { $0.name == "Generic OnOff Server" })!
//            print("Ω addSubscription called")
//            addSubscriptionLeft(model: LeftModel)
//        }
//        
//        if let _ = nodes[2].elements[0].models.first(where: { $0.name == "Generic OnOff Server" })
//           {
//            let LeftModel = nodes[2].elements[0].models.first(where: { $0.name == "Generic OnOff Server" })!
//            print("Ω addSubscription called")
//            addSubscriptionLeft(model: LeftModel)
//        }
//        
//        if let _ = nodes[3].elements[0].models.first(where: { $0.name == "Generic OnOff Server" })
//           {
//            let RightModel = nodes[3].elements[0].models.first(where: { $0.name == "Generic OnOff Server" })!
//            print("Ω addSubscription called")
//            addSubscriptionRight(model: RightModel)
//        }
//        
//        if let _ = nodes[4].elements[0].models.first(where: { $0.name == "Generic OnOff Server" })
//           {
//            let RightModel = nodes[4].elements[0].models.first(where: { $0.name == "Generic OnOff Server" })!
//            print("Ω addSubscription called")
//            addSubscriptionRight(model: RightModel)
//        }
        
   }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let workingTimer = timer{
            workingTimer.invalidate()
        }
    }
    
    deinit {
            print("Ω ExerciseDetailViewControllerがdeinitされました")
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
        
        phaseCountLabel.topAnchor.constraint(equalTo: previewContainerView.centerYAnchor, constant: marginWidth*0.5).isActive = true
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
        
        totalDurationTimeLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8).isActive = true
        totalDurationTimeLabel.trailingAnchor.constraint(equalTo: previewContainerView.trailingAnchor, constant: -marginWidth).isActive = true
        
        phaseTimeLabel.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: marginWidth*2).isActive = true
        phaseTimeLabel.trailingAnchor.constraint(equalTo: previewContainerView.centerXAnchor,constant: -marginWidth).isActive = true
        phaseTimeLabel.bottomAnchor.constraint(equalTo: previewContainerView.bottomAnchor, constant: -marginWidth*2).isActive = true
        
        phaseTimeButtonMinute.leadingAnchor.constraint(equalTo: previewContainerView.centerXAnchor, constant: view.frame.width*0.05).isActive = true
        phaseTimeButtonMinute.trailingAnchor.constraint(equalTo: colonLabel.leadingAnchor, constant: -view.frame.width*0.02).isActive = true
        phaseTimeButtonMinute.centerYAnchor.constraint(equalTo: phaseTimeLabel.centerYAnchor).isActive = true


        phaseTimeRollMinute.leadingAnchor.constraint(equalTo: previewContainerView.centerXAnchor, constant: view.frame.width*0.05).isActive = true
        phaseTimeRollMinute.trailingAnchor.constraint(equalTo: colonLabel.leadingAnchor, constant: -view.frame.width*0.02).isActive = true
        phaseTimeRollMinute.centerXAnchor.constraint(equalTo: phaseTimeButtonMinute.centerXAnchor).isActive = true
        phaseTimeRollMinute.centerYAnchor.constraint(equalTo: phaseTimeButtonMinute.centerYAnchor).isActive = true
        
        //colonLabel.leadingAnchor.constraint(equalTo: previewContainerView.centerXAnchor, constant: view.frame.width*0.22).isActive = true
        colonLabel.trailingAnchor.constraint(equalTo: previewContainerView.trailingAnchor, constant: -view.frame.width*0.22).isActive = true
        colonLabel.centerYAnchor.constraint(equalTo: phaseTimeLabel.centerYAnchor).isActive = true
        
        phaseTimeButtonSecond.leadingAnchor.constraint(equalTo: colonLabel.trailingAnchor, constant: view.frame.width*0.02).isActive = true
        phaseTimeButtonSecond.trailingAnchor.constraint(equalTo: previewContainerView.trailingAnchor, constant: -view.frame.width*0.05).isActive = true
        phaseTimeButtonSecond.centerYAnchor.constraint(equalTo: phaseTimeLabel.centerYAnchor).isActive = true

        phaseTimeRollSecond.leadingAnchor.constraint(equalTo: colonLabel.trailingAnchor, constant: view.frame.width*0.02).isActive = true
        phaseTimeRollSecond.trailingAnchor.constraint(equalTo: previewContainerView.trailingAnchor, constant: -view.frame.width*0.05).isActive = true
        phaseTimeRollSecond.centerXAnchor.constraint(equalTo: phaseTimeButtonSecond.centerXAnchor).isActive = true
        phaseTimeRollSecond.centerYAnchor.constraint(equalTo: phaseTimeButtonSecond.centerYAnchor).isActive = true
        
        executionButton.topAnchor.constraint(equalTo: previewContainerView.bottomAnchor, constant: marginWidth).isActive = true
        executionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100).isActive = true
        executionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100).isActive = true
        executionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -marginWidth).isActive = true
        executionButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func addSubscriptionLeft(model: Model) {
        let alreadySubscribedGroups = model.subscriptions
        alreadySubscribedGroups.forEach{ group in
            let message: ConfigMessage = ConfigModelSubscriptionDelete(group: group, from: model) ?? ConfigModelSubscriptionVirtualAddressDelete(group: group, from: model)!
            try! MeshNetworkManager.instance.send(message, to: model)
        }
            let message: ConfigMessage =
                ConfigModelSubscriptionAdd(group: self.LeftGroup, to: model) ??
                ConfigModelSubscriptionVirtualAddressAdd(group: self.LeftGroup, to: model)!
            try! MeshNetworkManager.instance.send(message, to: model)
    }
    
    func addSubscriptionRight(model: Model) {
        let alreadySubscribedGroups = model.subscriptions
        alreadySubscribedGroups.forEach{ group in
            let message: ConfigMessage = ConfigModelSubscriptionDelete(group: group, from: model) ?? ConfigModelSubscriptionVirtualAddressDelete(group: group, from: model)!
            try! MeshNetworkManager.instance.send(message, to: model)
        }
            let message: ConfigMessage =
                ConfigModelSubscriptionAdd(group: self.RightGroup, to: model) ??
                ConfigModelSubscriptionVirtualAddressAdd(group: self.RightGroup, to: model)!
            try! MeshNetworkManager.instance.send(message, to: model)
    }
    
    func setPublication(clientModel: Model, destinationAddress: MeshAddress?) {
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
    
    @objc func updateCurrentTime() {
        if isExerciseRunning{
            let totalDuration: Float = exercise.phases.reduce(0.0, {$0 + $1.duration})
            timerInterval = totalDuration / Float(exercise.phases.count * 2)
            if currentTime + timerInterval <= totalDuration {
                currentTime = currentTime + timerInterval
                if currentTime == totalDuration{
                    phaseCountLabel.text = "Exercise Finished"
                }
            }else{
                currentTime = 0.0
            }
        }
    }
}
