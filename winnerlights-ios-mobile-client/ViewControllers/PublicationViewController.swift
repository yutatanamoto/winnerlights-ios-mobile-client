//
//  PublicationViewController.swift
//  winnerlights-ios-mobile-client
//
//  Created by yutatanamoto on 2020/11/26.
//

import UIKit
import nRFMeshProvision

class PublicationViewController: ProgressViewController {
    
    var model: Model!
    var delegate: PublicationDelegate?
    
//    private var destination: MeshAddress? = MeshAddress(Address.allNodes)
    private var destination: MeshAddress? = MeshAddress(0xC000)
    private var applicationKey: ApplicationKey?
    private var ttl: UInt8 = 0xFF
    private var periodSteps: UInt8 = 0
    private var periodResolution: StepResolution = .hundredsOfMilliseconds
    private var retransmissionCount: UInt8 = 0
    private var retransmissionIntervalSteps: UInt8 = 0
    
    let cornerRadius: CGFloat = 20
    let shadowOpacity: Float = 0.2
    let marginWidth: CGFloat = 20
    let shadowOffset: CGSize = CGSize(width: 4, height: 4)
    
    fileprivate lazy var publishOnButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.setTitle("On", for: .normal)
        button.addTarget(self, action: #selector(publishGenericOnMessage), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var publishOffButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.setTitle("Off", for: .normal)
        button.addTarget(self, action: #selector(publishGenericOffMessage), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

        MeshNetworkManager.instance.delegate = self
        
        if let network = MeshNetworkManager.instance.meshNetwork {
            let provisionersNode  = network.nodes.filter({ $0.name == "棚本悠太のiPad" })[0]
            model = provisionersNode.elements[0].models.filter({ $0.name == "Generic OnOff Client" })[0]
        }
        
        if let publish = model.publish {
            destination = publish.publicationAddress
            applicationKey = model.boundApplicationKeys.first { $0.index == publish.index }
            ttl = publish.ttl
        } else {
            applicationKey = model.boundApplicationKeys.first
        }
        
        view.addSubview(publishOnButton)
        view.addSubview(publishOffButton)
        
        publishOnButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -marginWidth).isActive = true
        publishOnButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: marginWidth).isActive = true
        publishOnButton.trailingAnchor.constraint(equalTo: publishOffButton.leadingAnchor, constant: -marginWidth).isActive = true
        publishOnButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        publishOnButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        publishOffButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -marginWidth).isActive = true
        publishOffButton.leadingAnchor.constraint(equalTo: publishOnButton.trailingAnchor, constant: marginWidth).isActive = true
        publishOffButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        publishOffButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    @objc func publishGenericOnMessage(turnOn: Bool=false) {
        let label = "Turning ON..."
        publish(GenericOnOffSet(false, transitionTime: TransitionTime(1.0), delay: 20), description: label, fromModel: model)
    }
    
    @objc func publishGenericOffMessage(turnOn: Bool=true) {
        let label = "Turning OFF..."
        publish(GenericOnOffSet(true, transitionTime: TransitionTime(1.0), delay: 20), description: label, fromModel: model)
    }
}

extension PublicationViewController: ModelViewCellDelegate {
    
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
    
    var isRefreshing: Bool {
        return false
    }
}

extension PublicationViewController: MeshNetworkDelegate {
    
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
            
        case let status as ConfigModelPublicationStatus:
            done() {
                if status.status == .success {
                    self.dismiss(animated: true)
                    self.delegate?.publicationChanged()
                } else {
                    self.presentAlert(title: "Error", message: status.message)
                }
            }
            
        default:
            break
        }
    }
    
    func meshNetworkManager(_ manager: MeshNetworkManager, didSendMessage message: MeshMessage, from localElement: Element, to destination: Address) {
        done()
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

extension PublicationViewController: ModelControlDelegate {
    
    func publish(_ message: MeshMessage, description: String, fromModel model: Model) {
        start(description) {
            return MeshNetworkManager.instance.publish(message, fromModel: model)
        }
    }
}
