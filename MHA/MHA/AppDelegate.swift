//
//  AppDelegate.swift
//  MHA
//
//  Created by Zhenyuan Bo on 2020-11-02.
//

import UIKit
import Firebase
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //locaiton of Realm file
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        FirebaseApp.configure()
        Firestore.firestore()
        
        let fm = FileManager.default
        let log = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("MHA_Log.txt")
        
        print("Log File: \(log)")
        
        do{
            let _ = try Realm()
        }catch{
            print("Error initializing new realm, \(error)")
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
}

