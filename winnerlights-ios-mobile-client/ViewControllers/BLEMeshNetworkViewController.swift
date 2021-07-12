//
//  BLEMeshNetworkViewController.swift
//  winnerlights-ios-mobile-client
//
//  Created by human on 2020/09/23.
//

import UIKit
import nRFMeshProvision

//protocol ModelControlDelegate: class {
//    func publish(_ message: MeshMessage, description: String, fromModel model: Model)
//}
//
//protocol PublicationDelegate {
//    /// This method is called when the publication has changed.
//    func publicationChanged()
//}

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

    let cornerRadius: CGFloat = 100
    let buttonHeight: CGFloat = 200
    let buttonWidth: CGFloat = 200
    let buttonBorderWidth: CGFloat = 5
    let shadowOpacity: Float = 0.5
    let marginWidth: CGFloat = 50
    let shadowOffset: CGSize = CGSize(width: 4, height: 4)
    
    var clientModel: Model!
    var LEDGroup: Group!
    var LEDGroupAddress: MeshAddress? = MeshAddress(0xC007)
    
    var targetElmentIndex:Int = 0
    var jobs: [Job]!
    var currentJobIndex: Int!
    
    var genericOnOffRedClientModel1: Model!
    var genericOnOffGreenClientModel1: Model!
    var genericOnOffBlueClientModel1: Model!
    var genericOnOffRedClientModel1PublicationFinished: Bool = false
    var genericOnOffGreenClientModel1PublicationFinished: Bool = false
    var genericOnOffBlueClientModel1PublicationFinished: Bool = false
    var LeftGroup: Group!
    var RightGroup: Group!
    var LeftGroupAddress: MeshAddress? = MeshAddress(0xC001)
    var RightGroupAddress: MeshAddress? = MeshAddress(0xC002)
    
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
    fileprivate lazy var publishRedButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.layer.borderWidth = buttonBorderWidth
        button.layer.borderColor = UIColor.white.cgColor
        button.tag = 2
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(publishColorMessage), for: .touchUpInside)
        return button
    }()
    fileprivate lazy var publishGreenButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .green
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.layer.borderWidth = buttonBorderWidth
        button.layer.borderColor = UIColor.white.cgColor
        button.tag = 3
        button.addTarget(self, action: #selector(publishColorMessage), for: .touchUpInside)
        return button
    }()
    fileprivate lazy var publishBlueButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .blue
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.borderWidth = buttonBorderWidth
        button.layer.borderColor = UIColor.white.cgColor
        button.tag = 4
        button.addTarget(self, action: #selector(publishColorMessage), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var counterAttackButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 4, height: 4)
        button.setTitle("counterAttack", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(counterAttackGroupAddSubscription), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var diagonalButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 4, height: 4)
        button.setTitle("diagonal", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(diagonalGroupAddSubscription), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var powerPlayButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 4, height: 4)
        button.setTitle("powerPlay", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(powerPlayGroupAddSubscription), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "BLE Mesh Sample"
        self.navigationItem.leftBarButtonItem = refreshButton
        self.navigationItem.rightBarButtonItem = addButton
        
        view.addSubview(nodeTableView)
        view.addSubview(publishRedButton)
        view.addSubview(publishGreenButton)
        view.addSubview(publishBlueButton)
        view.addSubview(counterAttackButton)
        view.addSubview(diagonalButton)
        view.addSubview(powerPlayButton)
        
        setupConstraints()
        MeshNetworkManager.instance.delegate = self
        let network = MeshNetworkManager.instance.meshNetwork!
        nodes = network.nodes
        groups = network.groups
        // Create 1 application key
        if network.applicationKeys.count == 0 {
            createAndSaveApplicationKey()
        }
        applicationKey = network.applicationKeys[0]
        // Create groups
        for group in groups {
            print("Ω", group.name)
        }
        
        if let _ = groups.first(where: { $0.name == "LEDGroup" }) {
            LEDGroup = groups.first(where: { $0.name == "LEDGroup" })!
        } else {
            createAndSaveNewGroup(name: "LEDGroup", address: LEDGroupAddress!)
        }
        
        if let _ = groups.first(where: { $0.name == "LeftGroup" }) {
            LeftGroup = groups.first(where: { $0.name == "LeftGroup" })!
        } else {
            createAndSaveLeftGroup(name: "LeftGroup", address: LeftGroupAddress!)
        }
        
        if let _ = groups.first(where: { $0.name == "RightGroup" }) {
            RightGroup = groups.first(where: { $0.name == "RightGroup" })!
        } else {
            createAndSaveRightGroup(name: "RightGroup", address: RightGroupAddress!)
        }
    
        
        if let provisionersNode = network.nodes.first(where: { $0.isLocalProvisioner }),
           let primaryElement = provisionersNode.elements.first(where: { $0.location == .first }),
           let _ = primaryElement.models.first(where: { $0.name == "Generic OnOff Client" })
           {
            clientModel = primaryElement.models.first(where: { $0.name == "Generic OnOff Client" })!
        }
        
        setPublication(clientModel: clientModel, destinationAddress: LEDGroupAddress)
        
//        for node in nodes.filter({ !$0.isProvisioner }) {
//            if let _ = node.elements[0].models.first(where: { $0.name == "Generic OnOff Server" })
//               {
//                let LEDModel = node.elements[0].models.first(where: { $0.name == "Generic OnOff Server" })!
//                print("Ω addSubscription called")
//                print("Ω model name", LEDModel.name)
//                addSubscription(model: LEDModel)
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MeshNetworkManager.instance.delegate = self
    }
    
    func setupConstraints() {
        nodeTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        nodeTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        nodeTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        nodeTableView.heightAnchor.constraint(equalToConstant: view.frame.height*0.3).isActive = true
        
        publishRedButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200).isActive = true
        publishRedButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.frame.width*0.15).isActive = true
        publishRedButton.trailingAnchor.constraint(equalTo: publishGreenButton.leadingAnchor, constant: -view.frame.width*0.05).isActive = true
        publishRedButton.widthAnchor.constraint(equalToConstant: view.frame.width*0.2).isActive = true
        publishRedButton.heightAnchor.constraint(equalToConstant: view.frame.width*0.2).isActive = true
        publishRedButton.layer.cornerRadius = view.frame.width*0.1
        
        publishGreenButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200).isActive = true
        publishGreenButton.leadingAnchor.constraint(equalTo: publishRedButton.trailingAnchor, constant: view.frame.width*0.05).isActive = true
        publishGreenButton.trailingAnchor.constraint(equalTo: publishBlueButton.leadingAnchor, constant: -view.frame.width*0.05).isActive = true
        publishGreenButton.widthAnchor.constraint(equalToConstant: view.frame.width*0.2).isActive = true
        publishGreenButton.heightAnchor.constraint(equalToConstant: view.frame.width*0.2).isActive = true
        publishGreenButton.layer.cornerRadius = view.frame.width*0.1
        
        publishBlueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200).isActive = true
        publishBlueButton.leadingAnchor.constraint(equalTo: publishGreenButton.trailingAnchor, constant: view.frame.width*0.05).isActive = true
        publishBlueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.frame.width*0.15).isActive = true
        publishBlueButton.widthAnchor.constraint(equalToConstant: view.frame.width*0.2).isActive = true
        publishBlueButton.heightAnchor.constraint(equalToConstant: view.frame.width*0.2).isActive = true
        publishBlueButton.layer.cornerRadius = view.frame.width*0.1
        
        counterAttackButton.widthAnchor.constraint(equalToConstant: view.frame.width*0.2).isActive = true
        counterAttackButton.heightAnchor.constraint(equalToConstant: view.frame.width*0.2).isActive = true
        counterAttackButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.frame.width*0.15).isActive = true
        counterAttackButton.trailingAnchor.constraint(equalTo: diagonalButton.leadingAnchor, constant: -view.frame.width*0.05).isActive = true
        counterAttackButton.bottomAnchor.constraint(equalTo: publishBlueButton.topAnchor, constant: -150).isActive = true
        counterAttackButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        diagonalButton.widthAnchor.constraint(equalToConstant: view.frame.width*0.2).isActive = true
        diagonalButton.heightAnchor.constraint(equalToConstant: view.frame.width*0.2).isActive = true
        diagonalButton.leadingAnchor.constraint(equalTo: counterAttackButton.trailingAnchor, constant: view.frame.width*0.05).isActive = true
        diagonalButton.trailingAnchor.constraint(equalTo: powerPlayButton.leadingAnchor, constant: -view.frame.width*0.05).isActive = true
        diagonalButton.bottomAnchor.constraint(equalTo: publishBlueButton.topAnchor, constant: -150).isActive = true
        diagonalButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        powerPlayButton.widthAnchor.constraint(equalToConstant: view.frame.width*0.2).isActive = true
        powerPlayButton.heightAnchor.constraint(equalToConstant: view.frame.width*0.2).isActive = true
        powerPlayButton.leadingAnchor.constraint(equalTo: diagonalButton.trailingAnchor, constant: view.frame.width*0.05).isActive = true
        powerPlayButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.frame.width*0.15).isActive = true
        powerPlayButton.bottomAnchor.constraint(equalTo: publishBlueButton.topAnchor, constant: -150).isActive = true
        powerPlayButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
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
    
    func createAndSaveApplicationKey() {
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
        LEDGroup = try! Group(name: name, address: address)
        try! network.add(group: LEDGroup)
        if MeshNetworkManager.instance.save() {
            presentAlert(title: "Group Succesfully Saved", message: "New group saved.")
        } else {
            presentAlert(title: "Error", message: "Mesh configuration could not be saved.")
        }
    }
    
    func createAndSaveLeftGroup(name: String, address: MeshAddress) {
        let network = MeshNetworkManager.instance.meshNetwork!
        // Try assigning next available Group Address.
        LeftGroup = try! Group(name: name, address: address)
        try! network.add(group: LeftGroup)
        if MeshNetworkManager.instance.save() {
            presentAlert(title: "Group Succesfully Saved", message: "New group saved.")
        } else {
            presentAlert(title: "Error", message: "Mesh configuration could not be saved.")
        }
    }
    
    func createAndSaveRightGroup(name: String, address: MeshAddress) {
        let network = MeshNetworkManager.instance.meshNetwork!
        // Try assigning next available Group Address.
        RightGroup = try! Group(name: name, address: address)
        try! network.add(group: RightGroup)
        if MeshNetworkManager.instance.save() {
            presentAlert(title: "Group Succesfully Saved", message: "New group saved.")
        } else {
            presentAlert(title: "Error", message: "Mesh configuration could not be saved.")
        }
    }
    
    @objc func publishColorMessage(sender:UIButton) {
        let messageHandler = MeshNetworkManager.instance.publish(GenericOnOffSet(UInt8(sender.tag), transitionTime: TransitionTime(0.0), delay: 1), from: clientModel)
    }
    
    func setPublication(clientModel: Model, destinationAddress: MeshAddress?) {
        // Set new publication
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
    
    func addSubscription(model: Model) {
        let alreadySubscribedGroups = model.subscriptions
        alreadySubscribedGroups.forEach{ group in
            let message: ConfigMessage = ConfigModelSubscriptionDelete(group: group, from: model) ?? ConfigModelSubscriptionVirtualAddressDelete(group: group, from: model)!
            try! MeshNetworkManager.instance.send(message, to: model)
        }
        start("Subscribing...") { [self] in
            let message: ConfigMessage =
                ConfigModelSubscriptionAdd(group: self.LEDGroup, to: model) ??
                ConfigModelSubscriptionVirtualAddressAdd(group: self.LEDGroup, to: model)!
            return try MeshNetworkManager.instance.send(message, to: model)
        }
    }
    
    func addSubscriptionLeft(model: Model) {
        let alreadySubscribedGroups = model.subscriptions
        alreadySubscribedGroups.forEach{ group in
            let message: ConfigMessage = ConfigModelSubscriptionDelete(group: group, from: model) ?? ConfigModelSubscriptionVirtualAddressDelete(group: group, from: model)!
            try! MeshNetworkManager.instance.send(message, to: model)
        }
        start("Subscribing...") { [self] in
            let message: ConfigMessage =
                ConfigModelSubscriptionAdd(group: self.LeftGroup, to: model) ??
                ConfigModelSubscriptionVirtualAddressAdd(group: self.LeftGroup, to: model)!
            return try MeshNetworkManager.instance.send(message, to: model)
        }
    }
    
    func addSubscriptionRight(model: Model) {
        let alreadySubscribedGroups = model.subscriptions
        alreadySubscribedGroups.forEach{ group in
            let message: ConfigMessage = ConfigModelSubscriptionDelete(group: group, from: model) ?? ConfigModelSubscriptionVirtualAddressDelete(group: group, from: model)!
            try! MeshNetworkManager.instance.send(message, to: model)
        }
        start("Subscribing...") { [self] in
            let message: ConfigMessage =
                ConfigModelSubscriptionAdd(group: self.RightGroup, to: model) ??
                ConfigModelSubscriptionVirtualAddressAdd(group: self.RightGroup, to: model)!
            return try MeshNetworkManager.instance.send(message, to: model)
        }
    }
    
    @objc func counterAttackGroupAddSubscription() {
        if let _ = nodes[1].elements[0].models.first(where: { $0.name == "Generic OnOff Server" })
           {
            let LEDModel = nodes[1].elements[0].models.first(where: { $0.name == "Generic OnOff Server" })!
            addSubscription(model: LEDModel)
        }
        if let _ = nodes[2].elements[0].models.first(where: { $0.name == "Generic OnOff Server" })
           {
            let LEDModel = nodes[2].elements[0].models.first(where: { $0.name == "Generic OnOff Server" })!
            addSubscription(model: LEDModel)
        }
        if let _ = nodes[3].elements[0].models.first(where: { $0.name == "Generic OnOff Server" })
           {
            let RightModel = nodes[3].elements[0].models.first(where: { $0.name == "Generic OnOff Server" })!
            addSubscriptionRight(model: RightModel)
        }
        if let _ = nodes[4].elements[0].models.first(where: { $0.name == "Generic OnOff Server" })
           {
            let RightModel = nodes[4].elements[0].models.first(where: { $0.name == "Generic OnOff Server" })!
            addSubscriptionRight(model: RightModel)
        }
    }
    
    @objc func diagonalGroupAddSubscription() {
        if let _ = nodes[1].elements[0].models.first(where: { $0.name == "Generic OnOff Server" })
           {
            let LEDModel = nodes[1].elements[0].models.first(where: { $0.name == "Generic OnOff Server" })!
            addSubscription(model: LEDModel)
        }
        if let _ = nodes[2].elements[0].models.first(where: { $0.name == "Generic OnOff Server" })
           {
            let RightModel = nodes[2].elements[0].models.first(where: { $0.name == "Generic OnOff Server" })!
            addSubscriptionRight(model: RightModel)
        }
        if let _ = nodes[3].elements[0].models.first(where: { $0.name == "Generic OnOff Server" })
           {
            let LEDModel = nodes[3].elements[0].models.first(where: { $0.name == "Generic OnOff Server" })!
            addSubscription(model: LEDModel)
        }
        if let _ = nodes[4].elements[0].models.first(where: { $0.name == "Generic OnOff Server" })
           {
            let RightModel = nodes[4].elements[0].models.first(where: { $0.name == "Generic OnOff Server" })!
            addSubscriptionRight(model: RightModel)
        }
    }
    
    @objc func powerPlayGroupAddSubscription() {
        for node in nodes.filter({ !$0.isProvisioner }) {
            if let _ = node.elements[0].models.first(where: { $0.name == "Generic OnOff Server" })
               {
                let LEDModel = node.elements[0].models.first(where: { $0.name == "Generic OnOff Server" })!
                addSubscription(model: LEDModel)
            }
        }
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
        print("≈didReceiveMessage", "from", source, "to", destination, message)
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
        print("≈", message)
        //        done() {
//            self.presentAlert(title: "Succes", message: "Message was succesfully sent!!")
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

extension BLEMeshNetworkViewController: ModelControlDelegate {
    
    func publish(_ message: MeshMessage, description: String, fromModel model: Model) {
        start(description) {
            return MeshNetworkManager.instance.publish(message, from: model)
        }
    }
}
