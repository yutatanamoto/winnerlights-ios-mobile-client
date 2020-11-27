//
//  ModelViewController.swift
//  winnerlights-ios-mobile-client
//
//  Created by yutatanamoto on 2020/11/26.
//

import UIKit
import nRFMeshProvision

protocol BindAppKeyDelegate {
    /// This method is called when a new Application Key has been bound to the Model.
    func keyBound()
}

class ModelViewController: ProgressViewController {
    
    let cornerRadius: CGFloat = 20
    let shadowOpacity: Float = 0.2
    let marginWidth: CGFloat = 100
    let shadowOffset: CGSize = CGSize(width: 4, height: 4)
    var model: Model!
    var delegate: BindAppKeyDelegate?
    private var keys: [ApplicationKey]!
    
    
    fileprivate lazy var bindAppKeyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .systemBlue
        button.backgroundColor = .white
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.setTitle("Bind App Key", for: .normal)
        button.addTarget(self, action: #selector(bindAppKey), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var chooseGroupButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .systemBlue
        button.backgroundColor = .white
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.setTitle("Select Group", for: .normal)
        button.addTarget(self, action: #selector(chooseGroup), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        MeshNetworkManager.instance.delegate = self
        keys = model.parentElement?.parentNode?.applicationKeysAvailableFor(model)
        
        view.addSubview(bindAppKeyButton)
        view.addSubview(chooseGroupButton)
        
        bindAppKeyButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -marginWidth).isActive = true
        bindAppKeyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -marginWidth).isActive = true
        bindAppKeyButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        bindAppKeyButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        chooseGroupButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -marginWidth).isActive = true
        chooseGroupButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: marginWidth).isActive = true
        chooseGroupButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        chooseGroupButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        model.subscriptions.forEach{ group in
            print("subscribing", group.address)
        }
        print("model.publish", model.publish)
    }

    @objc func bindAppKey() {
        print("bindAppKey called", keys.count)
        if keys.count != 0 {
            let selectedAppKey = keys[0]
            guard let message = ConfigModelAppBind(applicationKey: selectedAppKey, to: self.model) else {
                return
            }
            start("Binding Application Key...") {
                return try MeshNetworkManager.instance.send(message, to: self.model)
            }
        }
    }
    
    @objc func chooseGroup() {
        let vc = SubscribeViewController()
        vc.model = model
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

extension ModelViewController: MeshNetworkDelegate {
    
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
            
        case let status as ConfigModelAppStatus:
            done() {
                if status.status == .success {
                    self.dismiss(animated: true)
                    self.delegate?.keyBound()
                } else {
                    self.presentAlert(title: "Error", message: "\(status.status)")
                }
            }
            
        default:
            // Ignore
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
    
    func meshNetworkManager(_ manager: MeshNetworkManager, didSendMessage message: MeshMessage,
                            from localElement: Element, to destination: Address) {
        done()
    }
}
