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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startLiteServ()
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
        adminStatus = String(format: "Admin failed to start with error: ", error)
        updateStatus()
    }
    
    func didStartListener(liteServ: LiteServ, onPort: UInt) {
        listenerStatus = String(format: "Listener is listening on port %d.", onPort)
        updateStatus()
    }
    
    func didFailStartListener(liteServ: LiteServ, error: String) {
        listenerStatus = String(format: "Listener failed to start with error: ", error)
        updateStatus()
    }
    
    func didStopListener(liteServ: LiteServ) {
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

