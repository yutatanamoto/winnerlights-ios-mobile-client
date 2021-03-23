//
//  AppDelegate.swift
//  winnerlights-ios-mobile-client
//
//  Created by human on 2020/09/23.
//

import UIKit
import os.log
import nRFMeshProvision

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var meshNetworkManager: MeshNetworkManager!
    var connection: NetworkConnection!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        
        // Create the main MeshNetworkManager instance and customize
        // configuration values.
        meshNetworkManager = MeshNetworkManager()
        meshNetworkManager.acknowledgmentTimerInterval = 0.600
        meshNetworkManager.transmissionTimerInteral = 0.600
        meshNetworkManager.retransmissionLimit = 1
        meshNetworkManager.acknowledgmentMessageInterval = 0.0
        meshNetworkManager.acknowledgmentMessageTimeout = 0.0
        meshNetworkManager.logger = self
        
        // Try loading the saved configuration.
        var loaded = false
        do {
            loaded = try meshNetworkManager.load()
        } catch {
            print(error)
            // ignore
        }
        
        // If load failed, create a new MeshNetwork.
        if !loaded {
            createNewMeshNetwork()
        } else {
            meshNetworkDidChange()
        }
        
        return true
    }
    
    /// This method creates a new mesh network with a default name and a
    /// single Provisioner. When done, if calls `meshNetworkDidChange()`.
    func createNewMeshNetwork() {
        // TODO: Implement creator
        let provisioner = Provisioner(name: UIDevice.current.name,
                                      allocatedUnicastRange: [AddressRange(0x0001...0x199A)],
                                      allocatedGroupRange:   [AddressRange(0xC000...0xCC9A)],
                                      allocatedSceneRange:   [SceneRange(0x0001...0x3333)])
        _ = meshNetworkManager.createNewMeshNetwork(withName: "nRF Mesh Network", by: provisioner)
        _ = meshNetworkManager.save()
        
        meshNetworkDidChange()
    }
    
    /// Sets up the local Elements and reinitializes the `NetworkConnection`
    /// so that it starts scanning for devices advertising the new Network ID.
    func meshNetworkDidChange() {
        connection?.close()
        
        let meshNetwork = meshNetworkManager.meshNetwork!
        
        // Set up local Elements on the phone.
        let element0 = Element(name: "Primary Element", location: .first, models: [
            // 4 generic models defined by Bluetooth SIG:
//            Model(sigModelId: 0x1000, delegate: GenericOnOffServerDelegate()),
//            Model(sigModelId: 0x1002, delegate: GenericLevelServerDelegate()),
            Model(sigModelId: 0x1001, delegate: GenericOnOffClientDelegate()),
            Model(sigModelId: 0x1002, delegate: GenericOnOffClientDelegate()),
//            Model(sigModelId: 0x1003, delegate: GenericLevelClientDelegate()),
            // A simple vendor model:
            Model(vendorModelId: 0x0001, companyId: 0x0059, delegate: SimpleOnOffClientDelegate())
        ])
        let element1 = Element(name: "Secondary Element", location: .second, models: [
            Model(sigModelId: 0x1000, delegate: GenericOnOffServerDelegate()),
            Model(sigModelId: 0x1002, delegate: GenericLevelServerDelegate()),
            Model(sigModelId: 0x1001, delegate: GenericOnOffClientDelegate()),
            Model(sigModelId: 0x1003, delegate: GenericLevelClientDelegate())
        ])
        let element2 = Element(name: "Red LED Controller", location: .third, models: [
            Model(sigModelId: 0x1000, delegate: GenericOnOffServerDelegate()),
            Model(sigModelId: 0x1002, delegate: GenericLevelServerDelegate()),
            Model(sigModelId: 0x1001, delegate: GenericOnOffClientDelegate()),
            Model(sigModelId: 0x1003, delegate: GenericLevelClientDelegate())
        ])
        let element3 = Element(name: "Green LED Controller", location: .fourth, models: [
            Model(sigModelId: 0x1000, delegate: GenericOnOffServerDelegate()),
            Model(sigModelId: 0x1002, delegate: GenericLevelServerDelegate()),
            Model(sigModelId: 0x1001, delegate: GenericOnOffClientDelegate()),
            Model(sigModelId: 0x1003, delegate: GenericLevelClientDelegate())
        ])
        let element4 = Element(name: "Blue LED Controller", location: .fifth, models: [
            Model(sigModelId: 0x1000, delegate: GenericOnOffServerDelegate()),
            Model(sigModelId: 0x1002, delegate: GenericLevelServerDelegate()),
            Model(sigModelId: 0x1001, delegate: GenericOnOffClientDelegate()),
            Model(sigModelId: 0x1003, delegate: GenericLevelClientDelegate())
        ])
        let element5 = Element(name: "Red LED Controller", location: .sixth, models: [
            Model(sigModelId: 0x1000, delegate: GenericOnOffServerDelegate()),
            Model(sigModelId: 0x1002, delegate: GenericLevelServerDelegate()),
            Model(sigModelId: 0x1001, delegate: GenericOnOffClientDelegate()),
            Model(sigModelId: 0x1003, delegate: GenericLevelClientDelegate())
        ])
        let element6 = Element(name: "Green LED Controller", location: .seventh, models: [
            Model(sigModelId: 0x1000, delegate: GenericOnOffServerDelegate()),
            Model(sigModelId: 0x1002, delegate: GenericLevelServerDelegate()),
            Model(sigModelId: 0x1001, delegate: GenericOnOffClientDelegate()),
            Model(sigModelId: 0x1003, delegate: GenericLevelClientDelegate())
        ])
        let element7 = Element(name: "Blue LED Controller", location: .eighth, models: [
            Model(sigModelId: 0x1000, delegate: GenericOnOffServerDelegate()),
            Model(sigModelId: 0x1002, delegate: GenericLevelServerDelegate()),
            Model(sigModelId: 0x1001, delegate: GenericOnOffClientDelegate()),
            Model(sigModelId: 0x1003, delegate: GenericLevelClientDelegate())
        ])
        meshNetworkManager.localElements = [element0, element1, element2, element3, element4, element5, element6, element7]
        
        connection = NetworkConnection(to: meshNetwork)
        connection!.dataDelegate = meshNetworkManager
        connection!.logger = self
        meshNetworkManager.transmitter = connection
        connection!.open()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension MeshNetworkManager {
    
    static var instance: MeshNetworkManager {
        return (UIApplication.shared.delegate as! AppDelegate).meshNetworkManager
    }
    
    static var bearer: NetworkConnection! {
        return (UIApplication.shared.delegate as! AppDelegate).connection
    }
    
}

// MARK: - Logger

extension AppDelegate: LoggerDelegate {
    
    func log(message: String, ofCategory category: LogCategory, withLevel level: LogLevel) {
        if #available(iOS 10.0, *) {
            os_log("%{public}@", log: category.log, type: level.type, message)
        } else {
            NSLog("%@", message)
        }
    }
    
}

extension LogLevel {
    
    /// Mapping from mesh log levels to system log types.
    var type: OSLogType {
        switch self {
        case .debug:       return .debug
        case .verbose:     return .debug
        case .info:        return .info
        case .application: return .default
        case .warning:     return .error
        case .error:       return .fault
        }
    }
    
}

extension LogCategory {
    
    var log: OSLog {
        return OSLog(subsystem: Bundle.main.bundleIdentifier!, category: rawValue)
    }
    
}
