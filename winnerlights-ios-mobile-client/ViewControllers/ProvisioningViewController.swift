//
//  ProvisioningViewController.swift
//  winnerlights-ios-mobile-client
//
//  Created by yutatanamoto on 2020/11/26.
//

import UIKit
import nRFMeshProvision

class ProvisioningViewController: UIViewController, ProvisioningDelegate, BearerDelegate {
    
    let cornerRadius: CGFloat = 20
    let shadowOpacity: Float = 0.2
    let marginWidth: CGFloat = 50
    let shadowOffset: CGSize = CGSize(width: 4, height: 4)
    static let attentionTimer: UInt8 = 5
    weak var delegate: ProvisioningViewDelegate?
    var unprovisionedDevice: UnprovisionedDevice!
    var bearer: ProvisioningBearer!
    private var publicKey: PublicKey?
    private var authenticationMethod: AuthenticationMethod?
    private var provisioningManager: ProvisioningManager!
    private var capabilitiesReceived = false
    private var alert: UIAlertController?
    
    fileprivate lazy var provisionButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Provision", style: .plain, target: self, action: #selector(provision))
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = unprovisionedDevice.name
        self.navigationItem.rightBarButtonItem = provisionButton
        let manager = MeshNetworkManager.instance
        // Obtain the Provisioning Manager instance for the Unprovisioned Device.
        provisioningManager = try! manager.provision(unprovisionedDevice: unprovisionedDevice, over: bearer)
        provisioningManager.delegate = self
        provisioningManager.logger = MeshNetworkManager.instance.logger
        bearer.delegate = self
        
        // Unicast Address initially will be assigned automatically.
//        actionProvision.isEnabled = manager.meshNetwork!.localProvisioner != nil
        
//         We are now connected. Proceed by sending Provisioning Invite request.
        presentStatusDialog(message: "Identifying...", animated: false) {
            do {
                try self.provisioningManager.identify(andAttractFor: ProvisioningViewController.attentionTimer)
            } catch {
                self.abort()
                self.presentAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    @objc func provision() {
        print("privision called -> ...")
        guard bearer.isOpen else {
            openBearer()
            return
        }
        startProvisioning()
    }
    
    func presentStatusDialog(message: String, animated flag: Bool = true, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            if let alert = self.alert {
                alert.message = message
                completion?()
            } else {
                self.alert = UIAlertController(title: "Status", message: message, preferredStyle: .alert)
                self.alert!.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                    action.isEnabled = false
                    self.abort()
                })
                self.present(self.alert!, animated: flag, completion: completion)
            }
        }
    }
    
    func dismissStatusDialog(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            if let alert = self.alert {
                alert.dismiss(animated: true, completion: completion)
            } else {
                completion?()
            }
            self.alert = nil
        }
    }
    
    func authenticationActionRequired(_ action: AuthAction) {
        switch action {
        case let .provideStaticKey(callback: callback):
            self.dismissStatusDialog() {
                let message = "Enter 16-character hexadecimal string."
                self.presentTextAlert(title: "Static OOB Key", message: message, type: .keyRequired) { hex in
                    callback(Data(hex: hex)!)
                }
            }
        case let .provideNumeric(maximumNumberOfDigits: _, outputAction: action, callback: callback):
            self.dismissStatusDialog() {
                var message: String
                switch action {
                case .blink:
                    message = "Enter number of blinks."
                case .beep:
                    message = "Enter number of beeps."
                case .vibrate:
                    message = "Enter number of vibrations."
                case .outputNumeric:
                    message = "Enter the number displayed on the device."
                default:
                    message = "Action \(action) is not supported."
                }
                self.presentTextAlert(title: "Authentication", message: message, type: .unsignedNumberRequired) { text in
                    callback(UInt(text)!)
                }
            }
        case let .provideAlphanumeric(maximumNumberOfCharacters: _, callback: callback):
            self.dismissStatusDialog() {
                let message = "Enter the text displayed on the device."
                self.presentTextAlert(title: "Authentication", message: message, type: .nameRequired) { text in
                    callback(text)
                }
            }
        case let .displayAlphanumeric(text):
            self.presentStatusDialog(message: "Enter the following text on your device:\n\n\(text)")
        case let .displayNumber(value, inputAction: action):
            self.presentStatusDialog(message: "Perform \(action) \(value) times on your device.")
        }
    }
    
    func inputComplete() {
        self.presentStatusDialog(message: "Provisioning...")
    }
    
    func abort() {
        DispatchQueue.main.async {
            self.alert?.title   = "Aborting"
            self.alert?.message = "Cancelling connection..."
            self.bearer.close()
        }
    }
    
    func openBearer() {
        presentStatusDialog(message: "Connecting...") {
            self.bearer.open()
        }
    }
    
    func startProvisioning() {
        print("startProvisioning called -> ...")
        guard let capabilities = provisioningManager.provisioningCapabilities else {
            return
        }
        
        // If the device's Public Key is available OOB, it should be read.
//        let publicKeyNotAvailable = capabilities.publicKeyType.isEmpty
//        print("\tpublicKeyNotAvailable -> ", publicKeyNotAvailable)
//        print("\tpublicKey -> ", publicKey)
        // If publicKey is available and publicKey have value, go into else branch
//        guard publicKeyNotAvailable || publicKey != nil else {
//            print("\tpresentOobPublicKeyDialog will be called -> ...")
//            presentOobPublicKeyDialog(for: unprovisionedDevice) { publicKey in
//                self.publicKey = publicKey
//                self.startProvisioning()
//            }
//            return
//        }
        publicKey = publicKey ?? .noOobPublicKey
        
        // If any of OOB methods is supported, if should be chosen.
//        let staticOobNotSupported = capabilities.staticOobType.isEmpty
//        let outputOobNotSupported = capabilities.outputOobActions.isEmpty
//        let inputOobNotSupported  = capabilities.inputOobActions.isEmpty
//        print("\tstaticOobNotSupported -> ", staticOobNotSupported)
//        print("\toutputOobNotSupported -> ", outputOobNotSupported)
//        print("\tinputOobNotSupported -> ", inputOobNotSupported)
//        print("\tauthenticationMethod -> ", authenticationMethod)
//        // If one or more of staticOob, outputOob and inputOob is supported and authenticationMethod has value, got into else branch
//        guard (staticOobNotSupported && outputOobNotSupported && inputOobNotSupported) || authenticationMethod != nil else {
//            print("\tpresentOobOptionsDialog will be called -> ...")
//            presentOobOptionsDialog(for: provisioningManager, from: provisionButton) { method in
//                self.authenticationMethod = method
//                self.startProvisioning()
//            }
//            return
//        }
        
        // If none of OOB methods are supported, select the only option left.
        if authenticationMethod == nil {
            authenticationMethod = .noOob
        }
        
        if provisioningManager.networkKey == nil {
            let network = MeshNetworkManager.instance.meshNetwork!
            let networkKey = try! network.add(networkKey: OpenSSLHelper().generateRandom(), name: "Primary Network Key")
            provisioningManager.networkKey = networkKey
        }
        
        // Start provisioning.
        presentStatusDialog(message: "Provisioning...") {
            do {
                try self.provisioningManager.provision(usingAlgorithm:       .fipsP256EllipticCurve,
                                                       publicKey:            self.publicKey!,
                                                       authenticationMethod: self.authenticationMethod!)
            } catch {
                self.abort()
                self.presentAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    func provisioningState(of unprovisionedDevice: UnprovisionedDevice, didChangeTo state: ProvisionigState) {
        DispatchQueue.main.async {
            switch state {
                
            case .requestingCapabilities:
                self.presentStatusDialog(message: "Identifying...")
                
            case .capabilitiesReceived(let capabilities):
                
                // If the Unicast Address was set to automatic (nil), it should be
                // set to the correct value by now, as we know the number of elements.
                let addressValid = self.provisioningManager.isUnicastAddressValid == true
                if !addressValid {
                   self.provisioningManager.unicastAddress = nil
                }
//                self.unicastAddressLabel.text = self.provisioningManager.unicastAddress?.asString() ?? "No address available"
//                self.actionProvision.isEnabled = addressValid
                
                let capabilitiesWereAlreadyReceived = self.capabilitiesReceived
                self.capabilitiesReceived = true
                
                let deviceSupported = self.provisioningManager.isDeviceSupported == true
                
                self.dismissStatusDialog() {
                    if deviceSupported && addressValid {
                        // If the device got disconnected after the capabilities were received
                        // the first time, the app had to send invitation again.
                        // This time we can just directly proceed with provisioning.
                        if capabilitiesWereAlreadyReceived {
                            self.startProvisioning()
                        }
                    } else {
                        if !deviceSupported {
                            self.presentAlert(title: "Error", message: "Selected device is not supported.")
//                            self.actionProvision.isEnabled = false
                        } else if !addressValid {
                            self.presentAlert(title: "Error", message: "No available Unicast Address in Provisioner's range.")
                        }
                    }
                }
                
            case .complete:
                self.bearer.close()
                self.presentStatusDialog(message: "Disconnecting...")
                
            case let .fail(error):
                self.dismissStatusDialog() {
                    self.presentAlert(title: "Error", message: error.localizedDescription)
                    self.abort()
                }
                
            default:
                break
            }
        }
    }
    
    func bearerDidOpen(_ bearer: Bearer) {
        presentStatusDialog(message: "Identifying...") {
            do {
                try self.provisioningManager!.identify(andAttractFor: ProvisioningViewController.attentionTimer)
            } catch {
                self.abort()
                self.presentAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    func bearer(_ bearer: Bearer, didClose error: Error?) {
        guard case .complete = provisioningManager.state else {
            dismissStatusDialog() {
                self.presentAlert(title: "Status", message: "Device disconnected.")
            }
            return
        }
        dismissStatusDialog() {
            self.presentAlert(title: "Success", message: "Provisioning complete.") { _ in
                if MeshNetworkManager.instance.save() {
                    self.dismiss(animated: true) {
                        let network = MeshNetworkManager.instance.meshNetwork!
                        if let node = network.node(for: self.unprovisionedDevice) {
                            print("delegate @ didClose", self.delegate)
                            self.delegate?.provisionerDidProvisionNewDevice(node)
                        }
                    }
                } else {
                    self.presentAlert(title: "Error", message: "Mesh configuration could not be saved.")
                }
            }
        }
    }
}

extension ProvisioningViewController: OobSelector {
    
}
