//
//  AppDelegate.swift
//  Nova
//
//  Created by Jayden Liu on 07/18/2022.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NovaManager.shared.launchNova()
        return true
    }
}
