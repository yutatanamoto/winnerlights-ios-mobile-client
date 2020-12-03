//
//  AvairablePeripheralViewController.swift
//  winnerlights-ios-mobile-client
//
//  Created by yutatanamoto on 2020/12/02.
//

import UIKit
import nRFMeshProvision
import CoreBluetooth

typealias DiscoveredPeripheral = (
    device: UnprovisionedDevice,
    peripheral: CBPeripheral,
    rssi: Int
)

class AvairablePeripheralViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate {
    // MARK: - Properties
    var centralManager: CBCentralManager!
    var bearer: ProvisioningBearer!
    private var discoveredPeripherals: [DiscoveredPeripheral] = []
    private var alert: UIAlertController?
    private var selectedDevice: UnprovisionedDevice?
    weak var delegate: ProvisioningViewDelegate?
    private var provisioningManager: ProvisioningManager!
    private var capabilitiesReceived = false
    
    fileprivate lazy var tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = "BLE Mesh Network"
        
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
        
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        
        setupConstraints()
    }
    
    func setupConstraints() {
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        discoveredPeripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let peripheral = discoveredPeripherals[indexPath.row]
        cell.textLabel?.text = peripheral.device.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let bearer = PBGattBearer(target: discoveredPeripherals[indexPath.row].peripheral)
        bearer.logger = MeshNetworkManager.instance.logger
        bearer.delegate = self
        
        stopScanning()
        selectedDevice = discoveredPeripherals[indexPath.row].device
        
        alert = UIAlertController(title: "Status", message: "Connecting...", preferredStyle: .alert)
        alert!.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
            action.isEnabled = false
            self.alert!.title   = "Aborting"
            self.alert!.message = "Cancelling connection..."
            bearer.close()
        })
        present(alert!, animated: true) {
            bearer.open()
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("CBManager is powered on")
            startScanning()
        case .poweredOff:
            print("CBManager is not powered on")
            return
        case .resetting:
            print("CBManager is resetting")
        case .unauthorized:
            print("Unexpected authorization")
            return
        case .unknown:
            print("CBManager state is unknown")
            return
        case .unsupported:
            print("Bluetooth is not supported on this device")
            return
        @unknown default:
            print("A previously unknown central manager state occurred")
            return
        }
    }
    
    func startScanning(){
        print("begin to scan ...")
        centralManager.scanForPeripherals(withServices: nil)
    }
    
    func stopScanning() {
        self.centralManager.stopScan()
    }

    // Peripheral探索結果を処理
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        // check whether discovered peripheral is contained by discoveredPeripherals
        if let index = discoveredPeripherals.firstIndex(where: { $0.peripheral == peripheral }) {
            print("no new peripheral discovered", index)
        } else {
            if let unprovisionedDevice = UnprovisionedDevice(advertisementData: advertisementData) {
                discoveredPeripherals.append((unprovisionedDevice, peripheral, RSSI.intValue))
                tableView.insertRows(at: [IndexPath(row: discoveredPeripherals.count - 1, section: 0)], with: .fade)
            }
        }
    }
    
    func startProvisioning() {
        print("startProvisioning called -> ...")
        
        print("bearer.isOpen -> ", bearer.isOpen)
        if !bearer.isOpen {
            presentStatusDialog(message: "Connecting...") {
                self.bearer.open()
            }
        }
        
        guard let capabilities = provisioningManager.provisioningCapabilities else {
            print("provisioningManager -> ", provisioningManager)
            print("capabilities -> ", provisioningManager.provisioningCapabilities)
            return
        }
        let publicKey: PublicKey = .noOobPublicKey
        
        // If none of OOB methods are supported, select the only option left.
        let authenticationMethod: AuthenticationMethod = .noOob
        
        if provisioningManager.networkKey == nil {
            let network = MeshNetworkManager.instance.meshNetwork!
            let networkKey = try! network.add(networkKey: OpenSSLHelper().generateRandom(), name: "Primary Network Key")
            provisioningManager.networkKey = networkKey
        }
        
        // Start provisioning.
        presentStatusDialog(message: "Provisioning...") {
            do {
                try self.provisioningManager.provision(usingAlgorithm:       .fipsP256EllipticCurve,
                                                       publicKey:            publicKey,
                                                       authenticationMethod: authenticationMethod)
            } catch {
                self.abort()
                self.presentAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
}

extension AvairablePeripheralViewController: ProvisioningDelegate {
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
    
    func provisioningState(of unprovisionedDevice: UnprovisionedDevice, didChangeTo state: ProvisionigState) {
        DispatchQueue.main.async {
            switch state {
                
            case .requestingCapabilities:
                self.presentStatusDialog(message: "Identifying...")
                
            case .capabilitiesReceived(let capabilities):
                print("capabilitiesReceived -> ...")
                
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
                    self.startProvisioning()
//                    if deviceSupported && addressValid {
//                        // If the device got disconnected after the capabilities were received
//                        // the first time, the app had to send invitation again.
//                        // This time we can just directly proceed with provisioning.
//                        if capabilitiesWereAlreadyReceived {
//                            self.startProvisioning()
//                        }
//                    } else {
//                        if !deviceSupported {
//                            self.presentAlert(title: "Error", message: "Selected device is not supported.")
////                            self.actionProvision.isEnabled = false
//                        } else if !addressValid {
//                            self.presentAlert(title: "Error", message: "No available Unicast Address in Provisioner's range.")
//                        }
//                    }
                }
                
            case .complete:
                print("provisioning status -> complete")
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
    
    func abort() {
        DispatchQueue.main.async {
            self.alert?.title   = "Aborting"
            self.alert?.message = "Cancelling connection..."
            self.bearer.close()
        }
    }
}

extension AvairablePeripheralViewController: GattBearerDelegate {
    
    func bearerDidConnect(_ bearer: Bearer) {
        DispatchQueue.main.async {
            self.alert?.message = "Discovering services..."
        }
    }
    
    func bearerDidDiscoverServices(_ bearer: Bearer) {
        DispatchQueue.main.async {
            self.alert?.message = "Initializing..."
        }
    }
        
    func bearerDidOpen(_ bearer: Bearer) {
        DispatchQueue.main.async {
            self.alert?.dismiss(animated: false) {
                self.bearer = bearer as? ProvisioningBearer
                
                let manager = MeshNetworkManager.instance
                // Obtain the Provisioning Manager instance for the Unprovisioned Device.
                self.provisioningManager = try! manager.provision(unprovisionedDevice: self.selectedDevice!, over: self.bearer!)
                self.provisioningManager.delegate = self
                self.provisioningManager.logger = MeshNetworkManager.instance.logger
                self.bearer.delegate = self
                
                print("provisioningManager.identify will be called -> ...")
                DispatchQueue.main.async {
                    try! self.provisioningManager.identify(andAttractFor: ProvisioningViewController.attentionTimer)
                }
                self.startProvisioning()
            }
            self.alert = nil
        }
    }
    
    func bearer(_ bearer: Bearer, didClose error: Error?) {
        DispatchQueue.main.async {
            let network = MeshNetworkManager.instance.meshNetwork!
            if let node = network.node(for: self.selectedDevice!) {
                self.delegate?.provisionerDidProvisionNewDevice(node)
            }
            self.alert?.message = "Device disconnected"
            self.alert?.dismiss(animated: true)
            self.alert = nil
            self.selectedDevice = nil
            self.startScanning()
        }
    }
}

//extension AvairablePeripheralViewController: ProvisioningViewDelegate{
//    func provisionerDidProvisionNewDevice(_ node: Node) {
//        print("provisionerDidProvisionNewDevice called")
//        let vc = ConfigurationViewController()
//        vc.node = node
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//
//}

protocol EditKeyDelegate {
    /// Notifies the delegate that the Key was added to the mesh network.
    ///
    /// - parameter key: The new Key.
    func keyWasAdded(_ key: Key)
    /// Notifies the delegate that the given Key was modified.
    ///
    /// - parameter key: The Key that has been modified.
    func keyWasModified(_ key: Key)
}

extension BLEMeshNetworkViewController: ModelControlDelegate {
    
    func publish(_ message: MeshMessage, description: String, fromModel model: Model) {
        start(description) {
            return MeshNetworkManager.instance.publish(message, fromModel: model)
        }
    }
}


