//
//  ConfigurationViewController.swift
//  winnerlights-ios-mobile-client
//
//  Created by yutatanamoto on 2020/11/26.
//

import UIKit
import nRFMeshProvision

class ConfigurationViewController: ProgressViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
          ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        let model = models[indexPath.row]
        cell.textLabel?.text = model.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = models[indexPath.row]
        let vc = ModelViewController()
        vc.model = model
        self.navigationController?.pushViewController(vc, animated: true)
    }
    // MARK: - Public properties
    
    var node: Node!
    var models: [Model] = []
    var delegate: AppKeyDelegate?
    private var keys: [ApplicationKey]!
    let cornerRadius: CGFloat = 20
    let shadowOpacity: Float = 0.2
    let marginWidth: CGFloat = 100
    let shadowOffset: CGSize = CGSize(width: 4, height: 4)
    
    fileprivate lazy var refreshButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(refresh))
        return button
    }()
    
    fileprivate lazy var addAppKeyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .systemBlue
        button.backgroundColor = .white
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.setTitle("Add App Key", for: .normal)
        button.addTarget(self, action: #selector(addAppKey), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var modelTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = node.name ?? "Unknown device"
        self.navigationItem.rightBarButtonItem = refreshButton
        models = node.elements[0].models
        
        view.addSubview(modelTableView)
        view.addSubview(addAppKeyButton)
        
        modelTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        modelTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        modelTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        modelTableView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        addAppKeyButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -marginWidth).isActive = true
        addAppKeyButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        addAppKeyButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        addAppKeyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // If the Composition Data were never obtained, get them now.
        if !node.isCompositionDataReceived {
            // This will request Composition Data when the bearer is open.
            getCompositionData()
        } else if node.defaultTTL == nil {
            getTtl()
        }
        
        MeshNetworkManager.instance.delegate = self
    }
    
    @objc func getCompositionData() {
        start("Requesting Composition Data...") {
            let message = ConfigCompositionDataGet()
            return try MeshNetworkManager.instance.send(message, to: self.node)
        }
    }
    
    func getTtl() {
        start("Requesting default TTL...") {
            let message = ConfigDefaultTtlGet()
            return try MeshNetworkManager.instance.send(message, to: self.node)
        }
    }
    
    @objc func refresh() {
        print("refresh called")
        models = node.elements[0].models
        modelTableView.reloadData()
    }
    
    @objc func addAppKey() {
        print("addAppKey called")
        let meshNetwork = MeshNetworkManager.instance.meshNetwork!
        keys = meshNetwork.applicationKeys.notKnownTo(node: node).filter {
            node.knows(networkKey: $0.boundNetworkKey)
        }
        print("keys", keys.count)
        if keys.count != 0 {
            let selectedAppKey = keys[0]
            start("Adding Application Key...") {
                return try MeshNetworkManager.instance.send(ConfigAppKeyAdd(applicationKey: selectedAppKey), to: self.node)
            }
        }
    }
}

extension ConfigurationViewController: MeshNetworkDelegate {
    
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            didReceiveMessage message: MeshMessage,
                            sentFrom source: Address, to destination: Address) {
        
        print("message", message)
        // Has the Node been reset remotely.
        guard !(message is ConfigNodeReset) else {
            (UIApplication.shared.delegate as! AppDelegate).meshNetworkDidChange()
            done() {
                self.navigationController?.popToRootViewController(animated: true)
            }
            return
        }
        // Is the message targeting the current Node?
        guard node.unicastAddress == source else {
            return
        }
        
        // Handle the message based on its type.
        switch message {
        case let status as ConfigAppKeyStatus:
            done()
            
            if status.isSuccess {
                if node.applicationKeys.isEmpty {
                }
            } else {
                presentAlert(title: "Error", message: "\(status.status)")
            }
            
        case let list as ConfigAppKeyList:
            if list.isSuccess {
                let index = node.networkKeys.firstIndex { $0.index == list.networkKeyIndex }
                if let index = index, index + 1 < node.networkKeys.count {
                    let networkKey = node.networkKeys[index + 1]
                } else {
                    done()
                    if node.applicationKeys.isEmpty {
                    }
                }
            } else {
                done() {
                    self.presentAlert(title: "Error", message: "\(list.status)")
                }
            }
        
        case is ConfigCompositionDataStatus:
            self.getTtl()
            
        case is ConfigDefaultTtlStatus:
            done()
            
        case is ConfigNodeResetStatus:
            done() {
                self.navigationController?.popViewController(animated: true)
            }
            
        default:
            break
        }
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

extension ConfigurationViewController: AppKeyDelegate {
    
    func keyAdded() {
        
        if !node.applicationKeys.isEmpty {
        }
    }
    
}
