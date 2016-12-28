//
//  LiteServ.swift
//  LiteServ-iOS
//
//  Created by Pasin Suriyentrakorn on 8/5/16.
//  Copyright © 2016 Couchbase. All rights reserved.
//

import Foundation
import Security

enum LiteServError: Error {
    case AdminError(description: String)
    case ListenerError(description: String)
}

protocol LiteServDelegate {
    func didStartAdmin(liteServ: LiteServ, onPort: UInt)
    func didFailStartAdmin(liteServ: LiteServ, error: String)
    func didStartListener(liteServ: LiteServ, onPort: UInt)
    func didFailStartListener(liteServ: LiteServ, error: String)
    func didStopListener(liteServ: LiteServ)
}

class LiteServ: NSObject, CBLListenerDelegate {
    var delegate: LiteServDelegate?
    var defaultConfig: Config
    
    private var manager: CBLManager?
    private var listener: CBLListener?
    private var server: GCDWebServer?
    private var currentConfig: Config?
    
    init(config: Config) {
        self.defaultConfig = config.copy() as! Config
    }
    
    func start() {
        startAdmin(port: defaultConfig.adminPort)
        try! startListener(config: defaultConfig)
    }
    
    func startAdmin(port: UInt) {
        server = GCDWebServer()
        
        server!.addHandler(
            forMethod: "PUT", path: "/start", request: GCDWebServerDataRequest.self,
            processBlock: { request in
                let r = request as! GCDWebServerDataRequest
                
                let config = self.defaultConfig.copy() as! Config
                if let c = r.jsonObject as? Dictionary<String, AnyObject> {
                    config.setValues(json: c)
                }
                
                do {
                    try self.startListener(config: config)
                } catch let error as NSError {
                    return GCDWebServerDataResponse(
                        jsonObject: ["status": "Error", "message": error.description])
                }
                
                var result: Dictionary<String, Any> = ["status": "OK"]
                if let curConfig = self.currentConfig {
                    var c = curConfig.asJson()
                    c["port"] = UInt(self.listener!.port)
                    c.removeValue(forKey: "adminPort")
                    result["listener"] = c
                }
                return GCDWebServerDataResponse(jsonObject: result)
        })
        
        server!.addHandler(
            forMethod: "PUT", path: "/stop", request: GCDWebServerDataRequest.self,
            processBlock: { request in
                self.stopListener()
                return GCDWebServerDataResponse(jsonObject: ["status": "OK"])
        })
        
        server!.addHandler(
            forMethod: "GET", path: "/", request: GCDWebServerDataRequest.self,
            processBlock: { request in
                var result: Dictionary<String, Any> = [:]
                result["adminPort"] = self.server!.port
                if let curConfig = self.currentConfig, let listener = self.listener {
                    var c = curConfig.asJson()
                    c["port"] = UInt(listener.port)
                    c.removeValue(forKey: "adminPort")
                    result["listener"] = c
                }
                return GCDWebServerDataResponse(jsonObject: result)
        })
        
        do {
            try server!.start(options: [GCDWebServerOption_Port: port])
            delegate?.didStartAdmin(liteServ: self, onPort: server!.port)
        } catch let error as NSError {
            delegate?.didFailStartAdmin(liteServ: self, error: error.description)
        }
    }
    
    func startListener(config: Config) throws {
        stopListener()
        
        // Create Manager:
        let options = UnsafeMutablePointer<CBLManagerOptions>.allocate(capacity: 1)
        options.initialize(to: CBLManagerOptions(
            readOnly: config.readonly, fileProtection: NSData.WritingOptions.noFileProtection))
        manager = try CBLManager(directory: CBLManager.defaultDirectory(), options: options)
        options.deallocate(capacity: 1);
        
        // Storage type:
        manager!.storageType = config.storage
        
        // Revisions limit:
        if config.revsLimit > 0 {
            manager!.defaultMaxRevTreeDepth = config.revsLimit;
        }
        
        // Encryption keys:
        if let dbpasswords = config.dbpasswords {
            for pair in dbpasswords.components(separatedBy: ",") {
                let dbpassword = pair.components(separatedBy: "=")
                if (dbpassword.count == 2) {
                    let db = dbpassword[0].trimmingCharacters(in: NSCharacterSet.whitespaces)
                    let password = dbpassword[0].trimmingCharacters(in: NSCharacterSet.whitespaces)
                    manager!.registerEncryptionKey(password, forDatabaseNamed: db)
                }
            }
        }
        
        // Create listener:
        listener = CBLListener(manager: manager!, port: UInt16(config.port))
        listener!.delegate = self
        
        do {
            // Set SSL Identity if serving over SSL:
            if (config.ssl) {
                try listener!.setAnonymousSSLIdentityWithLabel("LiteServ")
            }
            // Start listener:
            try listener!.start()
            currentConfig = (config.copy() as! Config)
        } catch let error as NSError {
            listener = nil
            delegate?.didFailStartListener(liteServ: self, error: error.description)
            throw error
        }
        
        delegate?.didStartListener(liteServ: self, onPort: UInt(listener!.port))
    }
    
    func stopListener() {
        if listener == nil {
            return
        }
        
        listener?.stop()
        listener = nil
        
        manager?.close()
        manager = nil
        
        currentConfig = nil
        
        delegate?.didStopListener(liteServ: self)
    }
    
    // MARK: - CBLListenerDelegate
    
    func authenticateConnection(fromAddress address: Data, with trust: SecTrust?) -> String? {
        return "";
    }
}
