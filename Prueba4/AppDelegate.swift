//
//  AppDelegate.swift
//  prueba3
//
//  Created by Sergio Vizcarro on 19/08/2020.
//  Copyright © 2020 Sergio Vizcarro. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("hola")
        
        setupView()
        return true
    }

    // MARK: - private methods
    
    private func setupView(){
    
        window = UIWindow(frame: UIScreen.main.bounds)
        let vc = HomeViewController()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }


}

