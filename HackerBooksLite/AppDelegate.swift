//
//  AppDelegate.swift
//  HackerBooksLite
//
//  Created by Alejandro M. Alberto on 16/09/16.
//  Copyright © 2016 KeepCoding. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    var window: UIWindow?
    
    
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        var tags: Results<Tag>?
        var book: Results<Book>?
        
        // Create the window
        window = UIWindow.init(frame: UIScreen.main.bounds)
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            tags = try! Realm().objects(Tag.self).sorted(by: [SortDescriptor(property: "favorites", ascending: false), "name"])
            book = try! Realm().objects(Book.self).sorted(byProperty: "title")
            let vc = BooksTableViewController(tags: tags!, style: .plain)
            let detailVC = BookViewController(book: (book?[0])!)
            if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
                self.window?.rootViewController = vc.wrappedInNavigationController()
            }else if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
                let splitVC = UISplitViewController()
                splitVC.viewControllers = [vc.wrappedInNavigationController(), detailVC.wrappedInNavigationController()]
                self.window?.rootViewController = splitVC
            }
            
            self.window?.makeKeyAndVisible()
            
        }
        else {
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            let presentationVC = PresentationViewController()
            self.window?.rootViewController = presentationVC
            self.window?.makeKeyAndVisible()
            
            // Create the model
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                 do{
                    guard let url = Bundle.main.url(forResource: "books_readable", withExtension: "json") else{
                        fatalError("Unable to read json file!")
                        }
                    let data = try Data(contentsOf: url)
                
                
                
                    let jsonDicts = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? JSONArray
                
                    for dict in jsonDicts!{
                        _ = try decode(book: dict)
                    }
                   
                        
                    DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                        tags = try! Realm().objects(Tag.self).sorted(by: [SortDescriptor(property: "favorites", ascending: false), "name"])
                        book = try! Realm().objects(Book.self).sorted(byProperty: "title")
                        let vc = BooksTableViewController(tags: tags!, style: .plain)
                        
                        let detailVC = BookViewController(book: (book?[0])!)
                        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
                            self.window?.rootViewController = vc.wrappedInNavigationController()
                        }else if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
                            let splitVC = UISplitViewController()
                            splitVC.viewControllers = [vc.wrappedInNavigationController(), detailVC.wrappedInNavigationController()]
                            self.window?.rootViewController = splitVC
                        }
                        self.window?.makeKeyAndVisible()
                    }
                    
                
                
                 }catch {
                    fatalError("Error while loading model")
                }

            }
           
        }
        
        // Display
        return true
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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

