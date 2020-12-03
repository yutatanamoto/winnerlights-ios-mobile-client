//
//  AddGroupViewController.swift
//  winnerlights-ios-mobile-client
//
//  Created by yutatanamoto on 2020/11/26.
//

import UIKit
import nRFMeshProvision

protocol GroupDelegate {
    func groupChanged(_ group: Group)
}

class AddGroupViewController: UIViewController {
    
    let cornerRadius: CGFloat = 20
    let shadowOpacity: Float = 0.2
    let marginWidth: CGFloat = 100
    let shadowOffset: CGSize = CGSize(width: 4, height: 4)
    
    var group: Group?
    var delegate: GroupDelegate?
    private var name: String?
    private var address: MeshAddress?
    
    fileprivate lazy var saveGroupButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.setTitle("Save Group", for: .normal)
        button.addTarget(self, action: #selector(createAndSaveNewGroup), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(saveGroupButton)
        
        saveGroupButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -marginWidth).isActive = true
        saveGroupButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -marginWidth).isActive = true
        saveGroupButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        saveGroupButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    @objc func createAndSaveNewGroup() {
        if let network = MeshNetworkManager.instance.meshNetwork,
           let localProvisioner = network.localProvisioner {
            // Try assigning next available Group Address.
            if let automaticAddress = network.nextAvailableGroupAddress(for: localProvisioner) {
                name = "New Group"
                address = MeshAddress(automaticAddress)
            } else {
                // All addresses from Provisioner's range are taken.
                // A Virtual Label has to be used instead.
                name = "New Virtual Group"
                address = MeshAddress(UUID())
            }
        } else {
            return
        }
        if let name = name, let address = address {
            do {
                let group = try Group(name: name, address: address)
                let network = MeshNetworkManager.instance.meshNetwork!
                try network.add(group: group)
                delegate?.groupChanged(group)
                if MeshNetworkManager.instance.save() {
                    presentAlert(title: "Group Succesfully Saved", message: "New group saved.")
                } else {
                    presentAlert(title: "Error", message: "Mesh configuration could not be saved.")
                }
            } catch {
                switch error as! MeshNetworkError {
                case .invalidAddress:
                    presentAlert(title: "Error", message: "The address \(address.asString()) is not a valid group address.")
                case .groupAlreadyExists:
                    presentAlert(title: "Error", message: "Group with address \(address.asString()) already exists.")
                default:
                    presentAlert(title: "Error", message: "An error occurred.")
                }
            }
        }
    }
    
    /// Presents a dialog to edit the Group name.
//    func presentNameDialog() {
//        presentTextAlert(title: "Group name", message: "E.g. Lights", text: name,
//                         type: .nameRequired) { name in
//                            self.name = name
//        }
//    }
    
    /// Presents a dialog to edit Group Address.
//    func presentGroupAddressDialog() {
//        let action = UIAlertAction(title: "Virtual Label", style: .default) { action in
//            self.address = MeshAddress(UUID())
//        }
//        presentTextAlert(title: "Group address", message: "Hexadecimal value in range\nC000 - FEFF.",
//                         text: ".hex can not be read.....", placeHolder: "Address", type: .groupAddressRequired,
//                         option: action) { text in
//                            self.address = MeshAddress(hex: text)
//        }
//    }
}
