//
//  BLEMeshNetworkViewController.swift
//  winnerlights-ios-mobile-client
//
//  Created by human on 2020/09/23.
//

import UIKit

class BLEMeshNetworkViewController: UIViewController, ProvisioningViewDelegate, MeshNetworkDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    func provisionerDidProvisionNewDevice(_ node: Node) {
        let vc = ConfigurationViewController()
        vc.node = node
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            didReceiveMessage message: MeshMessage,
                            sentFrom source: Address, to destination: Address) {
        switch message {
            
        case is ConfigNodeReset:
            // The node has been reset remotely.
            (UIApplication.shared.delegate as! AppDelegate).meshNetworkDidChange()
            presentAlert(title: "Reset", message: "The mesh network was reset remotely.")
            
        default:
            break
        }
    }
    
    let cornerRadius: CGFloat = 20
    let shadowOpacity: Float = 0.2
    let marginWidth: CGFloat = 100
    let shadowOffset: CGSize = CGSize(width: 4, height: 4)
    var nodes: [Node] = []
    private var newName: String!
    private var newKey: Data! = Data.random128BitKey()
    private var keyIndex: KeyIndex!
    private var newBoundNetworkKeyIndex: KeyIndex?
    weak var delegate: ProvisioningViewDelegate?
    
    fileprivate lazy var refreshButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(refresh))
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
    
    fileprivate lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.setTitle("Add Node", for: .normal)
        button.addTarget(self, action: #selector(showAvairablePeripherals), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var moveToPublicationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.setTitle("Puplication", for: .normal)
        button.addTarget(self, action: #selector(moveToPublication), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var moveToGroupSettingButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.setTitle("Group", for: .normal)
        button.addTarget(self, action: #selector(moveToGroupSetting), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = "BLE Mesh Network"
        
        self.navigationItem.rightBarButtonItem = refreshButton
        
        if let network = MeshNetworkManager.instance.meshNetwork {
            nodes = network.nodes
        }
        
        view.addSubview(nodeTableView)
        view.addSubview(addButton)
        view.addSubview(moveToPublicationButton)
        view.addSubview(moveToGroupSettingButton)
        
        setupConstraints()
        
        saveKey()
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
        addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -marginWidth).isActive = true
        addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -marginWidth).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        moveToPublicationButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -marginWidth).isActive = true
        moveToPublicationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: marginWidth).isActive = true
        moveToPublicationButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        moveToPublicationButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        moveToGroupSettingButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -marginWidth).isActive = true
        moveToGroupSettingButton.leadingAnchor.constraint(equalTo: moveToPublicationButton.trailingAnchor, constant: marginWidth).isActive = true
        moveToGroupSettingButton.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -marginWidth).isActive = true
        moveToGroupSettingButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

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
    
    @objc func showAvairablePeripherals() {
//        delegate = slf
        let vc = AvairablePeripheralViewController()
        vc.delegate = self
        self.navigationController?.present(NavigationController(rootViewController: vc), animated: true)
    }
    
    @objc func moveToPublication() {
        let vc = PublicationViewController()
        self.navigationController?.present(NavigationController(rootViewController: vc), animated: true)
    }
    
    @objc func moveToGroupSetting() {
        let vc = GroupViewController()
        self.navigationController?.present(NavigationController(rootViewController: vc), animated: true)
    }
    
    @objc func refresh() {
        if let network = MeshNetworkManager.instance.meshNetwork {
            network.nodes.forEach{ node in
                print("node name", node.name)
                node.elements[0].models.forEach { model in
                    print("\tmodel name", model.name)
                }
            }
            nodes = network.nodes
            nodeTableView.reloadData()
        }
    }
}

private extension BLEMeshNetworkViewController {
    
    var isNewKey: Bool {
        return key == nil
    }
    
    var isKeyUsed: Bool {
        if key is NetworkKey {
            let network = MeshNetworkManager.instance.meshNetwork!
            return (key as! NetworkKey).isUsed(in: network)
        }
        if key is ApplicationKey {
            let network = MeshNetworkManager.instance.meshNetwork!
            return (key as! ApplicationKey).isUsed(in: network)
        }
        return false
    }
    
    var defaultName: String {
        let network = MeshNetworkManager.instance.meshNetwork!
        if isApplicationKey {
            return "App Key \((network.nextAvailableApplicationKeyIndex ?? 0xFFF) + 1)"
        } else {
            return "Network Key \((network.nextAvailableNetworkKeyIndex ?? 0xFFF) + 1)"
        }
    }
    
    func saveKey() {
        let network = MeshNetworkManager.instance.meshNetwork!
        print("keys @ BLEMeshNetworkViewController: saveKey", network.applicationKeys)
        if network.applicationKeys.count == 0 {
            // Those 2 must be saved before setting the key.
            let index = newBoundNetworkKeyIndex
            newName = "newName"
            
            if key == nil {
                key = try! network.add(applicationKey: newKey, name: newName)
            }
            key!.name = "newAppKey"
            if let applicationKey = key as? ApplicationKey,
               let index = index,
               let networkKey = network.networkKeys[index] {
                try? applicationKey.bind(to: networkKey)
            }
            
            if MeshNetworkManager.instance.save() {
            } else {
                presentAlert(title: "Error", message: "Mesh configuration could not be saved.")
            }
        }
    }
    
}

import CoreBluetooth
import nRFMeshProvision

typealias DiscoveredPeripheral = (
    device: UnprovisionedDevice,
    peripheral: CBPeripheral,
    rssi: Int
)
class AvairablePeripheralViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate {
    
    // MARK: - Properties
    var centralManager: CBCentralManager!
    private var discoveredPeripherals: [DiscoveredPeripheral] = []
    private var alert: UIAlertController?
    private var selectedDevice: UnprovisionedDevice?
    weak var delegate: ProvisioningViewDelegate?
    
    fileprivate lazy var tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        
        print("delegate @ AvairablePeripheralViewController:viewDidLoad", delegate)
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

//        print("pheripheral.name: \(String(describing: peripheral.name))")
//        print("advertisementData:\(advertisementData)")
//        print("RSSI: \(RSSI)")
//        print("peripheral.identifier.uuidString: \(peripheral.identifier.uuidString)\n")
        
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
//                self.performSegue(withIdentifier: "identify", sender: bearer)
                print("navigate to ProvisioningViewController")
                let vc = ProvisioningViewController()
                vc.unprovisionedDevice = self.selectedDevice
                vc.bearer =  bearer as? ProvisioningBearer
                print("delegate @ bearerDidOpen", self.delegate)
                vc.delegate = self.delegate
                self.selectedDevice = nil
                print("self.navigationController", self.navigationController)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            self.alert = nil
        }
    }
    
    func bearer(_ bearer: Bearer, didClose error: Error?) {
        DispatchQueue.main.async {
            self.alert?.message = "Device disconnected"
            self.alert?.dismiss(animated: true)
            self.alert = nil
            self.selectedDevice = nil
            self.startScanning()
        }
    }
    
    
}

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
