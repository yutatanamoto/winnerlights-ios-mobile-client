//
//  SubscribeViewController.swift
//  winnerlights-ios-mobile-client
//
//  Created by yutatanamoto on 2020/11/27.
//

import UIKit
import nRFMeshProvision

protocol SubscriptionDelegate {
    /// This method is called when a new subscription was added.
    func subscriptionAdded()
}

class SubscribeViewController: ProgressViewController {
    
    var model: Model!
//    var delegate: SubscriptionDelegate?
    private var groups: [Group]!
    private var selectedIndexPath: IndexPath?
    
    fileprivate lazy var groupTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        MeshNetworkManager.instance.delegate = self
        let network = MeshNetworkManager.instance.meshNetwork!
        groups = network.groups
        view.addSubview(groupTableView)
        groupTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        groupTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        groupTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        groupTableView.heightAnchor.constraint(equalToConstant: 400).isActive = true
    }
}

private extension SubscribeViewController {
    
    func addSubscription() {
        let alreadySubscribedGroups = model.subscriptions
        print("alreadySubscribedGroups -> " , alreadySubscribedGroups)
        alreadySubscribedGroups.forEach{ group in
            let message: ConfigMessage = ConfigModelSubscriptionDelete(group: group, from: self.model) ?? ConfigModelSubscriptionVirtualAddressDelete(group: group, from: self.model)!
            send(message, description: "Unsubscribing...")
        }
        print("guard let", alreadySubscribedGroups)
        guard let selectedIndexPath = selectedIndexPath else {
            return
        }
        let group = groups[selectedIndexPath.row]
        start("Subscribing...") {
            let message: ConfigMessage =
                ConfigModelSubscriptionAdd(group: group, to: self.model) ??
                ConfigModelSubscriptionVirtualAddressAdd(group: group, to: self.model)!
            return try MeshNetworkManager.instance.send(message, to: self.model)
        }
    }
}

extension SubscribeViewController: ModelViewCellDelegate {
    var isRefreshing: Bool {
        return  false
    }
    
    
    func send(_ message: MeshMessage, description: String) {
        start(description) {
            return try MeshNetworkManager.instance.send(message, to: self.model)
        }
    }
    
    func send(_ message: ConfigMessage, description: String) {
        start(description) {
            return try MeshNetworkManager.instance.send(message, to: self.model)
        }
    }
    
}

protocol ModelViewCellDelegate: class {
    /// Encrypts the message with the first Application Key bound to the given
    /// Model and a Network Key bound to it, and sends it to the Node
    /// to which the Model belongs to.
    ///
    /// - parameter message: The message to be sent.
    /// - parameter description: The message to be displayed for the user.
    func send(_ message: MeshMessage, description: String)
    
    /// Sends Configuration Message to the given Node to which the Model belongs to.
    ///
    /// - parameter message: The message to be sent.
    /// - parameter description: The message to be displayed for the user.
    func send(_ message: ConfigMessage, description: String)
    
    /// Whether the view is being refreshed with Pull-to-Refresh or not.
    var isRefreshing: Bool { get }
}


extension SubscribeViewController: MeshNetworkDelegate {
    
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            didReceiveMessage message: MeshMessage,
                            sentFrom source: Address, to destination: Address) {
        // Has the Node been reset remotely.
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
        // Is the message targeting the current Node?
        guard model.parentElement?.parentNode?.unicastAddress == source else {
            return
        }
        
        // Handle the message based on its type.
        switch message {
            
        case let status as ConfigModelSubscriptionStatus:
            done() {
                if status.status == .success {
                    self.dismiss(animated: true)
                    self.groupTableView.reloadData()
                } else {
                    self.presentAlert(title: "Error", message: status.message)
                }
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

extension SubscribeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
          ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        
        let group = groups[indexPath.row]
        cell.textLabel?.text = "\(group.name): \(group.address)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        addSubscription()
    }
}
