//
//  ViewController.swift
//  LiteServ-iOS
//
//  Created by Pasin Suriyentrakorn on 8/5/16.
//  Copyright © 2016 Couchbase. All rights reserved.
//

import UIKit

class ViewController: UIViewController, LiteServDelegate {
    @IBOutlet weak var textView: UITextView!
    
    var liteServ: LiteServ?
    var adminStatus: String?
    
    var listenerStatus: String?
    var listenerStarted = false
    
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startLiteServ()
        NotificationCenter.default.addObserver(
            forName: Notification.Name.UIApplicationDidBecomeActive,
            object: nil, queue: nil, using: { (note) in
                if let liteServ = self.liteServ, self.listenerStarted {
                    liteServ.restart();
                }
        })
        
        NotificationCenter.default.addObserver(
            forName: Notification.Name.UIApplicationDidEnterBackground,
            object: nil, queue: nil) { (note) in
                self.backgroundTask = UIApplication.shared.beginBackgroundTask(
                    expirationHandler: {
                        self.backgroundTask = UIBackgroundTaskInvalid;
                })
        }
        
        NotificationCenter.default.addObserver(
            forName: Notification.Name.UIApplicationWillEnterForeground,
            object: nil, queue: nil) { (note) in
                if self.backgroundTask != UIBackgroundTaskInvalid {
                    UIApplication.shared.endBackgroundTask(self.backgroundTask)
                    self.backgroundTask = UIBackgroundTaskInvalid
                }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func startLiteServ() {
        CBLRegisterJSViewCompiler()
        liteServ = LiteServ(config: Config())
        liteServ!.delegate = self
        liteServ!.start()
    }
    
    func didStartAdmin(liteServ: LiteServ, onPort: UInt) {
        adminStatus = String(format: "Admin is listening on port %d.", onPort)
        updateStatus()
    }
    
    func didFailStartAdmin(liteServ: LiteServ, error: String) {
        listenerStarted = false;
        adminStatus = String(format: "Admin failed to start with error: ", error)
        updateStatus()
    }
    
    func didStartListener(liteServ: LiteServ, onPort: UInt) {
        listenerStarted = true
        listenerStatus = String(format: "Listener is listening on port %d.", onPort)
        updateStatus()
    }
    
    func didFailStartListener(liteServ: LiteServ, error: String) {
        listenerStarted = false;
        listenerStatus = String(format: "Listener failed to start with error: ", error)
        updateStatus()
        self.liteServ = nil;
    }
    
    func didStopListener(liteServ: LiteServ) {
        listenerStarted = false;
        listenerStatus = "Listener is stopped."
        updateStatus()
    }
    
    private func updateStatus() {
        let admin = (adminStatus != nil) ? adminStatus! : ""
        let space = admin.characters.count > 0 ? " " : ""
        let listener = (listenerStatus != nil) ? listenerStatus! : ""
        let status = String(format: "%@%@%@", admin, space, listener);
        DispatchQueue.main.async {
            self.textView.text = status
        }
    }
}

