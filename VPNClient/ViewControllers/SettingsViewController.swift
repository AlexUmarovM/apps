//
//  SettingsViewController.swift
//  VPNClient
//
//  Created by Igor Kasyanenko on 20.10.2019.
//  Copyright © 2019 VPNUK. All rights reserved.
//  Distributed under the GNU GPL v3 For full terms see the file LICENSE
//

import UIKit
import TunnelKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var protocolSegmentedControl: UISegmentedControl!
    @IBOutlet weak var portSegmentedControl: UISegmentedControl!
    @IBOutlet weak var reconnectSwitcher: UISwitch!
    
    @IBAction func reconnectSwitcherChanged(_ sender: UISwitch) {
        
    }
    
    @IBAction func saveTouched(_ sender: UIBarButtonItem) {
        let socketType: SocketType = protocolSegmentedControl.selectedSegmentIndex == 0 ? .tcp : .udp
        let port = VPNSettings.socketPorts[socketType]?[portSegmentedControl.selectedSegmentIndex]
        
        UserDefaults.socketTypeSetting = socketType
        UserDefaults.portSetting = "\(port!)"
        UserDefaults.reconnectOnNetworkChangeSetting = reconnectSwitcher.isOn
        
        NotificationCenter.default.post(name: VPNSettings.settingsChangedNotification, object: nil, userInfo: nil)
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func protocolChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            updatePort(type: .tcp)
        case 1:
            updatePort(type: .udp)
        default:
            break
        }
    }
    
    private func updatePort(type: SocketType) {
        protocolSegmentedControl.selectedSegmentIndex = type == .tcp ? 0 : 1
        portSegmentedControl.removeAllSegments()
        let ports = (VPNSettings.socketPorts[type] ?? []).reversed()
        for port in ports {
             portSegmentedControl.insertSegment(withTitle: "\(port)", at: 0, animated: false)
        }
       
        portSegmentedControl.selectedSegmentIndex = 0
    }
    
    @IBAction func portChanged(_ sender: UISegmentedControl) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restoreFromSettings()
        // Do any additional setup after loading the view.
    }
    
    private func restoreFromSettings() {
        let socketType = UserDefaults.socketTypeSetting ?? VPNSettings.defaultSettings.socketType
        reconnectSwitcher.setOn(UserDefaults.reconnectOnNetworkChangeSetting, animated: false)
        updatePort(type: socketType)
        if let portStr = UserDefaults.portSetting, let port = Int(portStr), let index = VPNSettings.socketPorts[socketType]?.firstIndex(of: port) {
            portSegmentedControl.selectedSegmentIndex = index
        }
        
    
    }

}
