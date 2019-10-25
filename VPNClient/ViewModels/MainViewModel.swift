//
//  MainViewModel.swift
//  VPNClient
//
//  Created by Igor Kasyanenko on 20.10.2019.
//  Copyright © 2019 VPNUK. All rights reserved.
//

import Foundation
import TunnelKit
import CoreData
import NetworkExtension
import Alamofire

protocol MainView: class {
    var username: String? { get }
    var password: String? { get }
    func statusUpdated(newStatus status: NEVPNStatus)
    func serverListUpdated()
    func showError(description: String)
}

class MainViewModel: NSObject {
    weak var view: MainView?
    private(set) var selectedServer: ServerEntity?
    var serversType: ServerType = .shared {
        didSet {
            fetchServers()
        }
    }
    
    var serverIP: String? {
        return vpnService.configuration?.hostname
    }
    
    var socketType: SocketType? {
        return vpnService.configuration?.socketType
    }
    
    var port: UInt16? {
        return vpnService.configuration?.port
    }
    
    private var vpnService: VPNService
    private let api: RestAPI
    private let coreDataStack: CoreDataStack
    private(set) lazy var serverListController: NSFetchedResultsController<ServerEntity> = {
        let request = NSFetchRequest<ServerEntity>(entityName: "ServerEntity")
        request.sortDescriptors = []
        request.predicate = getFetchServersPredicate()
        let controller = NSFetchedResultsController<ServerEntity>(fetchRequest: request, managedObjectContext: coreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    init(vpnService: VPNService = OpenVPNService.shared, coreDataStack: CoreDataStack = CoreDataStack.shared, api: RestAPI = RestAPI.shared) {
        self.vpnService = vpnService
        self.coreDataStack = coreDataStack
        self.api = api
        super.init()
        self.vpnService.delegate = self
        tryToRestoreLastSelectedServer()
    }
    
    private func getFetchServersPredicate() -> NSPredicate {
        return NSPredicate(format: "type == %@", serversType.rawValue)
    }
    
    func isConnected(toServer server: ServerEntity) -> Bool {
        return vpnService.configuration?.hostname == server.address && (vpnService.status != .disconnected && vpnService.status != .invalid)
    }
    
    func viewDidLoad() {
        fetchServers()
        api.getServerList { (result) in
            switch result {
            case .success(let servers):
                ServerEntity.update(withDtos: servers, in: self.coreDataStack.context) {
                    self.coreDataStack.saveContext()
                    self.fetchServers()
                }
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    func fetchServers() {
        serverListController.fetchRequest.predicate = getFetchServersPredicate()
        try? serverListController.performFetch()
        view?.serverListUpdated()
    }
    
    private func tryToRestoreLastSelectedServer() {
        if let ip = UserDefaults.selectedServerIP, let server = ServerEntity.find(byIP: ip, in: coreDataStack.context) {
            selectedServer = server
        } else {
            print("server not restored")
        }
    }
    
    func select(server: ServerEntity) {
        selectedServer = server
    }
    
    func connectTouched() {
       
        switch vpnService.status {
        case .invalid, .disconnected:
            let port = Int(UserDefaults.portSetting ?? String(VPNSettings.defaultSettings.port)) ?? VPNSettings.defaultSettings.port
            let type = UserDefaults.socketTypeSetting ?? VPNSettings.defaultSettings.socketType
            guard let server = selectedServer else {
                view?.showError(description: "Please select server from the list")
                print("please select server from list")
                return;
            }
            
            if let username = view?.username, let password = view?.password {
                if username == "" {
                    view?.showError(description: "Please input username")
                    return
                }
                if password == "" {
                    view?.showError(description: "Please input password")
                    return
                }
                let credentials = OpenVPN.Credentials(username, password)
                vpnService.configure(hostname: server.address!, port: UInt16(port), socketType: type, credentials: credentials)
                vpnService.connectionClicked()
            }
        case .connected, .connecting:
            vpnService.connectionClicked()
        default:
            break
        }
        
    }
    
    private func save(credentials: OpenVPN.Credentials?) {
        
    }

    
    
}

extension MainViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        view?.serverListUpdated()
    }
}

extension MainViewModel: VPNServiceDelegate {
    func raised(error: VPNError) {
        switch error {
        case .error(let desc):
            DispatchQueue.main.async {
                self.view?.showError(description: desc)
            }
        }
        
    }
    
    func statusUpdated(newStatus status: NEVPNStatus) {
        view?.statusUpdated(newStatus: status)
    }
}