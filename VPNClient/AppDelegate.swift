//
//  AppDelegate.swift
//  VPNClient
//
//  Created by Igor Kasyanenko on 20.10.2019.
//  Copyright © 2019 VPNUK. All rights reserved.
//  Distributed under the GNU GPL v3 For full terms see the file LICENSE
//


import UIKit
import NetworkExtension
import SwiftyBeaver
import TunnelKit
import Firebase

private let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        clearCredentialsIfFirstLaunch()
        
        let logDestination = ConsoleDestination()
        logDestination.minLevel = .debug
        logDestination.format = "$DHH:mm:ss$d $L $N.$F:$l - $M"
        log.addDestination(logDestination)
        
        // Override point for customization after application launch.
        return true
    }
    
    private func clearCredentialsIfFirstLaunch() {
        if UserDefaults.isFirstLaunch {
            let passwordKey = OpenVPNConstants.keychainPasswordKey
            let usernameKey = OpenVPNConstants.keychainUsernameKey
            let keychain = Keychain(group: OpenVPNConstants.appGroup)
            keychain.removePassword(for: usernameKey)
            keychain.removePassword(for: passwordKey)
            UserDefaults.isFirstLaunch = false
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}


