//
//  BLEMeshNetworkViewController.swift
//  winnerlights-ios-mobile-client
//
//  Created by human on 2020/09/23.
//

import UIKit
import nRFMeshProvision

protocol ModelControlDelegate: class {
    func publish(_ message: MeshMessage, description: String, fromModel model: Model)
}

protocol PublicationDelegate {
    /// This method is called when the publication has changed.
    func publicationChanged()
}

struct LEDColor {
    var color: UIColor
    var redIsOn: Bool
    var greenIsOn: Bool
    var blueIsOn: Bool
}

class BLEMeshNetworkViewController: ProgressViewController, UINavigationControllerDelegate {
    
    var ledColors: [LEDColor] = [
        LEDColor(color: .systemRed, redIsOn: true, greenIsOn: false, blueIsOn: false),
        LEDColor(color: .systemGreen, redIsOn: false, greenIsOn: true, blueIsOn: false),
        LEDColor(color: .systemBlue, redIsOn: false, greenIsOn: false, blueIsOn: true),
        LEDColor(color: .systemYellow, redIsOn: true, greenIsOn: true, blueIsOn: false),
        LEDColor(color: .systemPurple, redIsOn: true, greenIsOn: false, blueIsOn: true),
        LEDColor(color: UIColor(red: 0, green: 255, blue: 255, alpha: 1), redIsOn: false, greenIsOn: true, blueIsOn: true)
    ]

    let cornerRadius: CGFloat = 20
    let shadowOpacity: Float = 0.2
    let marginWidth: CGFloat = 50
    let shadowOffset: CGSize = CGSize(width: 4, height: 4)
//    var destinationGroupAddress1: MeshAddress? = MeshAddress(0xC000)
//    var destinationGroupAddress2: MeshAddress? = MeshAddress(0xC001)
    
    var genericOnOffRedClientModel1: Model!
    var genericOnOffGreenClientModel1: Model!
    var genericOnOffBlueClientModel1: Model!
    var genericOnOffRedClientModel1PublicationFinished: Bool = false
    var genericOnOffGreenClientModel1PublicationFinished: Bool = false
    var genericOnOffBlueClientModel1PublicationFinished: Bool = false
    var redGroup1Address: MeshAddress? = MeshAddress(0xC000)
    var greenGroup1Address: MeshAddress? = MeshAddress(0xC001)
    var blueGroup1Address: MeshAddress? = MeshAddress(0xC002)
    
    var genericOnOffRedClientModel2: Model!
    var genericOnOffGreenClientModel2: Model!
    var genericOnOffBlueClientModel2: Model!
    var genericOnOffRedClientModel2PublicationFinished: Bool = false
    var genericOnOffGreenClientModel2PublicationFinished: Bool = false
    var genericOnOffBlueClientModel2PublicationFinished: Bool = false
    var redGroup2Address: MeshAddress? = MeshAddress(0xC003)
    var greenGroup2Address: MeshAddress? = MeshAddress(0xC004)
    var blueGroup2Address: MeshAddress? = MeshAddress(0xC005)
    
    var nodes: [Node] = []
    var groups: [Group] = []
    var applicationKey: ApplicationKey!
    private var newName: String!
    private var newKey: Data! = Data.random128BitKey()
    private var keyIndex: KeyIndex!
    private var newBoundNetworkKeyIndex: KeyIndex?
    private var ttl: UInt8 = 0xFF
    private var periodSteps: UInt8 = 0
    private var periodResolution: StepResolution = .hundredsOfMilliseconds
    private var retransmissionCount: UInt8 = 0
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
        if isApplicationKey {
            return "App Key \((network.nextAvailableApplicationKeyIndex ?? 0xFFF) + 1)"
        } else {
            return "Network Key \((network.nextAvailableNetworkKeyIndex ?? 0xFFF) + 1)"
        }
    }
    
    fileprivate lazy var refreshButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(refresh))
        return button
    }()
    fileprivate lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(showAvairablePeripherals))
        return button
    }()
    fileprivate lazy var nodeTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    fileprivate lazy var publishRedButton1: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.tag = 0
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(publishColorMessage1), for: .touchUpInside)
        return button
    }()
    fileprivate lazy var publishGreenButton1: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .green
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.tag = 1
        button.addTarget(self, action: #selector(publishColorMessage1), for: .touchUpInside)
        return button
    }()
    fileprivate lazy var publishBlueButton1: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .blue
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.tag = 2
        button.addTarget(self, action: #selector(publishColorMessage1), for: .touchUpInside)
        return button
    }()
    fileprivate lazy var publishYellowButton1: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemYellow
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.tag = 3
        button.addTarget(self, action: #selector(publishColorMessage1), for: .touchUpInside)
        return button
    }()
    fileprivate lazy var publishPurpleButton1: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemPurple
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.tag = 4
        button.addTarget(self, action: #selector(publishColorMessage1), for: .touchUpInside)
        return button
    }()
    fileprivate lazy var publishBlueGreenButton1: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0, green: 255, blue: 255, alpha: 1)
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.tag = 5
        button.addTarget(self, action: #selector(publishColorMessage1), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var publishRedButton2: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.tag = 0
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(publishColorMessage2), for: .touchUpInside)
        return button
    }()
    fileprivate lazy var publishGreenButton2: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .green
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.tag = 1
        button.addTarget(self, action: #selector(publishColorMessage2), for: .touchUpInside)
        return button
    }()
    fileprivate lazy var publishBlueButton2: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .blue
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.tag = 2
        button.addTarget(self, action: #selector(publishColorMessage2), for: .touchUpInside)
        return button
    }()
    fileprivate lazy var publishYellowButton2: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemYellow
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.tag = 3
        button.addTarget(self, action: #selector(publishColorMessage2), for: .touchUpInside)
        return button
    }()
    fileprivate lazy var publishPurpleButton2: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemPurple
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.tag = 4
        button.addTarget(self, action: #selector(publishColorMessage2), for: .touchUpInside)
        return button
    }()
    fileprivate lazy var publishBlueGreenButton2: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0, green: 255, blue: 255, alpha: 1)
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.tag = 5
        button.addTarget(self, action: #selector(publishColorMessage2), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "BLE Mesh Sample"
        self.navigationItem.leftBarButtonItem = refreshButton
        self.navigationItem.rightBarButtonItem = addButton
        
        view.addSubview(nodeTableView)
        view.addSubview(publishRedButton1)
        view.addSubview(publishGreenButton1)
        view.addSubview(publishBlueButton1)
        view.addSubview(publishYellowButton1)
        view.addSubview(publishPurpleButton1)
        view.addSubview(publishBlueGreenButton1)
        view.addSubview(publishRedButton2)
        view.addSubview(publishGreenButton2)
        view.addSubview(publishBlueButton2)
        view.addSubview(publishYellowButton2)
        view.addSubview(publishPurpleButton2)
        view.addSubview(publishBlueGreenButton2)
        
        setupConstraints()
        MeshNetworkManager.instance.delegate = self
        let network = MeshNetworkManager.instance.meshNetwork!
        nodes = network.nodes
        groups = network.groups
        // Create 1 application key
        if network.applicationKeys.count == 0 {
            CreateAndSaveApplicationKey()
        }
        applicationKey = network.applicationKeys[0]
        // Create groups
        if groups.count == 0 {
            createAndSaveNewGroup(name: "redGroup1", address: redGroup1Address!)
            createAndSaveNewGroup(name: "greenGroup1", address: greenGroup1Address!)
            createAndSaveNewGroup(name: "blueGroup1", address: blueGroup1Address!)
            createAndSaveNewGroup(name: "redGroup2", address: redGroup2Address!)
            createAndSaveNewGroup(name: "greenGroup2", address: greenGroup2Address!)
            createAndSaveNewGroup(name: "blueGroup2", address: blueGroup2Address!)
        }
        
        if let provisionersNode = network.nodes.first(where: { $0.isLocalProvisioner }),
           let redLedElement = provisionersNode.elements.first(where: { $0.location == .third }),
           let _ = redLedElement.models.first(where: { $0.name == "Generic OnOff Client" })
           {
            genericOnOffRedClientModel1 = redLedElement.models.first(where: { $0.name == "Generic OnOff Client" })!
        }
        if let provisionersNode = network.nodes.first(where: { $0.isLocalProvisioner }),
           let greenLedElement = provisionersNode.elements.first(where: { $0.location == .fourth }),
           let _ = greenLedElement.models.first(where: { $0.name == "Generic OnOff Client" })
           {
            genericOnOffGreenClientModel1 = greenLedElement.models.first(where: { $0.name == "Generic OnOff Client" })!
        }
        if let provisionersNode = network.nodes.first(where: { $0.isLocalProvisioner }),
           let blueLedElement = provisionersNode.elements.first(where: { $0.location == .fifth }),
           let _ = blueLedElement.models.first(where: { $0.name == "Generic OnOff Client" })
           {
            genericOnOffBlueClientModel1 = blueLedElement.models.first(where: { $0.name == "Generic OnOff Client" })!
        }
        
        if let provisionersNode = network.nodes.first(where: { $0.isLocalProvisioner }),
           let redLedElement = provisionersNode.elements.first(where: { $0.location == .sixth }),
           let _ = redLedElement.models.first(where: { $0.name == "Generic OnOff Client" })
           {
            genericOnOffRedClientModel2 = redLedElement.models.first(where: { $0.name == "Generic OnOff Client" })!
        }
        if let provisionersNode = network.nodes.first(where: { $0.isLocalProvisioner }),
           let greenLedElement = provisionersNode.elements.first(where: { $0.location == .seventh }),
           let _ = greenLedElement.models.first(where: { $0.name == "Generic OnOff Client" })
           {
            genericOnOffGreenClientModel2 = greenLedElement.models.first(where: { $0.name == "Generic OnOff Client" })!
        }
        if let provisionersNode = network.nodes.first(where: { $0.isLocalProvisioner }),
           let blueLedElement = provisionersNode.elements.first(where: { $0.location == .eighth }),
           let _ = blueLedElement.models.first(where: { $0.name == "Generic OnOff Client" })
           {
            genericOnOffBlueClientModel2 = blueLedElement.models.first(where: { $0.name == "Generic OnOff Client" })!
        }
        
        setPublication(clientModel: genericOnOffRedClientModel1, destinationGroupAddress: redGroup1Address)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MeshNetworkManager.instance.delegate = self
    }
    
    func setupConstraints() {
        nodeTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        nodeTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        nodeTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        nodeTableView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        
        publishRedButton1.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200).isActive = true
        publishRedButton1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        publishRedButton1.trailingAnchor.constraint(equalTo: publishGreenButton1.leadingAnchor, constant: 0).isActive = true
        publishRedButton1.widthAnchor.constraint(equalTo: publishBlueGreenButton2.widthAnchor).isActive = true
        publishRedButton1.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        publishGreenButton1.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200).isActive = true
        publishGreenButton1.leadingAnchor.constraint(equalTo: publishRedButton2.trailingAnchor, constant: 0).isActive = true
        publishGreenButton1.trailingAnchor.constraint(equalTo: publishBlueButton1.leadingAnchor, constant: 0).isActive = true
        publishGreenButton1.widthAnchor.constraint(equalTo: publishBlueGreenButton2.widthAnchor).isActive = true
        publishGreenButton1.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        publishBlueButton1.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200).isActive = true
        publishBlueButton1.leadingAnchor.constraint(equalTo: publishGreenButton2.trailingAnchor, constant: 0).isActive = true
        publishBlueButton1.trailingAnchor.constraint(equalTo: publishYellowButton1.leadingAnchor, constant: 0).isActive = true
        publishBlueButton1.widthAnchor.constraint(equalTo: publishBlueGreenButton2.widthAnchor).isActive = true
        publishBlueButton1.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        publishYellowButton1.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200).isActive = true
        publishYellowButton1.leadingAnchor.constraint(equalTo: publishBlueButton2.trailingAnchor, constant: 0).isActive = true
        publishYellowButton1.trailingAnchor.constraint(equalTo: publishPurpleButton1.leadingAnchor, constant: 0).isActive = true
        publishYellowButton1.widthAnchor.constraint(equalTo: publishBlueGreenButton2.widthAnchor).isActive = true
        publishYellowButton1.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        publishPurpleButton1.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200).isActive = true
        publishPurpleButton1.leadingAnchor.constraint(equalTo: publishYellowButton2.trailingAnchor, constant: 0).isActive = true
        publishPurpleButton1.trailingAnchor.constraint(equalTo: publishBlueGreenButton1.leadingAnchor, constant: 0).isActive = true
        publishPurpleButton1.widthAnchor.constraint(equalTo: publishBlueGreenButton2.widthAnchor).isActive = true
        publishPurpleButton1.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        publishBlueGreenButton1.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200).isActive = true
        publishBlueGreenButton1.leadingAnchor.constraint(equalTo: publishPurpleButton1.trailingAnchor, constant: 0).isActive = true
        publishBlueGreenButton1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        publishBlueGreenButton1.widthAnchor.constraint(equalTo: publishBlueGreenButton2.widthAnchor).isActive = true
        publishBlueGreenButton1.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        publishRedButton2.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        publishRedButton2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        publishRedButton2.trailingAnchor.constraint(equalTo: publishGreenButton1.leadingAnchor, constant: 0).isActive = true
        publishRedButton2.widthAnchor.constraint(equalTo: publishBlueGreenButton2.widthAnchor).isActive = true
        publishRedButton2.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        publishGreenButton2.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        publishGreenButton2.leadingAnchor.constraint(equalTo: publishRedButton1.trailingAnchor, constant: 0).isActive = true
        publishGreenButton2.trailingAnchor.constraint(equalTo: publishBlueButton1.leadingAnchor, constant: 0).isActive = true
        publishGreenButton2.widthAnchor.constraint(equalTo: publishBlueGreenButton2.widthAnchor).isActive = true
        publishGreenButton2.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        publishBlueButton2.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        publishBlueButton2.leadingAnchor.constraint(equalTo: publishGreenButton1.trailingAnchor, constant: 0).isActive = true
        publishBlueButton2.trailingAnchor.constraint(equalTo: publishYellowButton1.leadingAnchor, constant: 0).isActive = true
        publishBlueButton2.widthAnchor.constraint(equalTo: publishBlueGreenButton2.widthAnchor).isActive = true
        publishBlueButton2.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        publishYellowButton2.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        publishYellowButton2.leadingAnchor.constraint(equalTo: publishBlueButton1.trailingAnchor, constant: 0).isActive = true
        publishYellowButton2.trailingAnchor.constraint(equalTo: publishPurpleButton1.leadingAnchor, constant: 0).isActive = true
        publishYellowButton2.widthAnchor.constraint(equalTo: publishBlueGreenButton2.widthAnchor).isActive = true
        publishYellowButton2.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        publishPurpleButton2.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        publishPurpleButton2.leadingAnchor.constraint(equalTo: publishYellowButton1.trailingAnchor, constant: 0).isActive = true
        publishPurpleButton2.trailingAnchor.constraint(equalTo: publishBlueGreenButton1.leadingAnchor, constant: 0).isActive = true
        publishPurpleButton2.widthAnchor.constraint(equalTo: publishBlueGreenButton2.widthAnchor).isActive = true
        publishPurpleButton2.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        publishBlueGreenButton2.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        publishBlueGreenButton2.leadingAnchor.constraint(equalTo: publishPurpleButton2.trailingAnchor, constant: 0).isActive = true
        publishBlueGreenButton2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        publishBlueGreenButton2.widthAnchor.constraint(equalTo: publishBlueGreenButton2.widthAnchor).isActive = true
        publishBlueGreenButton2.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    @objc func showAvairablePeripherals() {
        let vc = AvairablePeripheralViewController()
        vc.delegate = self
        self.navigationController?.present(NavigationController(rootViewController: vc), animated: true)
    }
    
    @objc func refresh() {
        if let network = MeshNetworkManager.instance.meshNetwork {
            nodes = network.nodes
            nodeTableView.reloadData()
        }
    }
    
    func CreateAndSaveApplicationKey() {
        let network = MeshNetworkManager.instance.meshNetwork!
        newName = "New Application Key"
        key = try! network.add(applicationKey: newKey, name: newName)
        if MeshNetworkManager.instance.save() {
        } else {
            presentAlert(title: "Error", message: "Mesh configuration could not be saved.")
        }
    }
    
    func createAndSaveNewGroup(name: String, address: MeshAddress) {
        let network = MeshNetworkManager.instance.meshNetwork!
        // Try assigning next available Group Address.
        let group = try! Group(name: name, address: address)
        try! network.add(group: group)
        if MeshNetworkManager.instance.save() {
            presentAlert(title: "Group Succesfully Saved", message: "New group saved.")
        } else {
            presentAlert(title: "Error", message: "Mesh configuration could not be saved.")
        }
    }
    
    func setPublication(clientModel: Model, destinationGroupAddress: MeshAddress?) {
        // Remove current publication
//        guard let message = ConfigModelPublicationSet(disablePublicationFor: clientModel) else {
//            return
//        }
//        start(description) {
//            return try MeshNetworkManager.instance.send(message, to: clientModel)
//        }
        
        // Set new publication
        guard let destination = destinationGroupAddress, let applicationKey = applicationKey else {
            return
        }
        start("Setting Model Publication...") {
            let publish = Publish(to: destination, using: applicationKey,
                                  usingFriendshipMaterial: false, ttl: self.ttl,
                                  periodSteps: self.periodSteps, periodResolution: self.periodResolution,
                                  retransmit: Publish.Retransmit(publishRetransmitCount: self.retransmissionCount,
                                                                 intervalSteps: self.retransmissionIntervalSteps))
            let message: ConfigMessage =
                ConfigModelPublicationSet(publish, to: clientModel) ??
                ConfigModelPublicationVirtualAddressSet(publish, to: clientModel)!
            return try MeshNetworkManager.instance.send(message, to: clientModel)
        }
    }
    
    @objc func publishColorMessage1(sender:UIButton) {
        let label = "Setting Color..."
        let targetLedColor = ledColors[sender.tag]
        publish(GenericOnOffSet(!targetLedColor.redIsOn, transitionTime: TransitionTime(0.0), delay: 20), description: label, fromModel: genericOnOffRedClientModel1)
        publish(GenericOnOffSet(!targetLedColor.greenIsOn, transitionTime: TransitionTime(0.0), delay: 20), description: label, fromModel: genericOnOffGreenClientModel1)
        publish(GenericOnOffSet(!targetLedColor.blueIsOn, transitionTime: TransitionTime(0.0), delay: 20), description: label, fromModel: genericOnOffBlueClientModel1)
    }
    
    @objc func publishColorMessage2(sender:UIButton) {
        let label = "Setting Color..."
        let targetLedColor = ledColors[sender.tag]
        publish(GenericOnOffSet(!targetLedColor.redIsOn, transitionTime: TransitionTime(0.0), delay: 20), description: label, fromModel: genericOnOffRedClientModel2)
        publish(GenericOnOffSet(!targetLedColor.greenIsOn, transitionTime: TransitionTime(0.0), delay: 20), description: label, fromModel: genericOnOffGreenClientModel2)
        publish(GenericOnOffSet(!targetLedColor.blueIsOn, transitionTime: TransitionTime(0.0), delay: 20), description: label, fromModel: genericOnOffBlueClientModel2)
    }
}

extension BLEMeshNetworkViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nodes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
          ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        let node = nodes[indexPath.row]
        cell.textLabel?.text = node.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ConfigurationViewController()
        vc.node = nodes[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension BLEMeshNetworkViewController: ProvisioningViewDelegate{
    func provisionerDidProvisionNewDevice(_ node: Node) {
        print("provisionerDidProvisionNewDevice called")
        nodeTableView.reloadData()
        let vc = ConfigurationViewController()
        vc.node = node
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension BLEMeshNetworkViewController: MeshNetworkDelegate{
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            didReceiveMessage message: MeshMessage,
                            sentFrom source: Address, to destination: Address) {
        print("message@didReceiveMessage -> ", message)
        
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
        switch message {
            
        case let status as ConfigModelPublicationStatus:
            done() {
                if status.status == .success {
                    if !self.genericOnOffGreenClientModel1PublicationFinished {
                        self.setPublication(clientModel: self.genericOnOffGreenClientModel1, destinationGroupAddress: self.greenGroup1Address)
                        self.genericOnOffGreenClientModel1PublicationFinished = true
                    } else if !self.genericOnOffBlueClientModel1PublicationFinished {
                        self.setPublication(clientModel: self.genericOnOffBlueClientModel1, destinationGroupAddress: self.blueGroup1Address)
                        self.genericOnOffBlueClientModel1PublicationFinished = true
                    } else if !self.genericOnOffRedClientModel2PublicationFinished {
                        self.setPublication(clientModel: self.genericOnOffRedClientModel2, destinationGroupAddress: self.redGroup2Address)
                        self.genericOnOffRedClientModel2PublicationFinished = true
                    } else if !self.genericOnOffGreenClientModel2PublicationFinished {
                        self.setPublication(clientModel: self.genericOnOffGreenClientModel2, destinationGroupAddress: self.greenGroup2Address)
                        self.genericOnOffGreenClientModel2PublicationFinished = true
                    } else if !self.genericOnOffBlueClientModel2PublicationFinished {
                        self.setPublication(clientModel: self.genericOnOffBlueClientModel2, destinationGroupAddress: self.blueGroup2Address)
                        self.genericOnOffBlueClientModel2PublicationFinished = true
                    }
                    self.dismiss(animated: true)
                } else {
                    self.presentAlert(title: "Error", message: status.message)
                }
            }
            
        case let status as GenericOnOffStatus:
            done() {
//                if status
                self.presentAlert(title: "Succes", message: "success foooooo!!")
            }
        
        case is ConfigNodeReset:
            // The node has been reset remotely.
            (UIApplication.shared.delegate as! AppDelegate).meshNetworkDidChange()
            presentAlert(title: "Reset", message: "The mesh network was reset remotely.")
            
        default:
            break
        }
    }
    
    func meshNetworkManager(_ manager: MeshNetworkManager, didSendMessage message: MeshMessage, from localElement: Element, to destination: Address) {
        print("message@didSendMessage    -> ", message)
//        done() {
//            self.presentAlert(title: "Succes", message: "success foooooo!!")
//        }
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
