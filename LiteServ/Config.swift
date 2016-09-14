//
//  Config.swift
//  LiteServ-iOS
//
//  Created by Pasin Suriyentrakorn on 8/5/16.
//  Copyright © 2016 Couchbase. All rights reserved.
//

import Foundation

class Config: NSCopying {
    var adminPort: UInt = 59850 // Admin port to listen on
    var port: UInt = 49850      // Listener port to listen on
    var readonly = false        // Enables read-only mode
    var revsLimit: UInt = 0     // Sets default max rev-tree depth for database
    var storage = "SQLite"      // Set default storage engine: 'SQLite' or 'ForestDB'
    var dbpasswords: String?    // Register passwords to open a database <db1>=<passwd1>,<db2>=<passwd2>,...
    
    init() {
        var env = ProcessInfo.processInfo.environment
        
        if let v = env["adminPort"], let adminPort = UInt(v)  {
            self.adminPort = adminPort
        }
            
        if let v = env["port"], let port = UInt(v)  {
            self.port = port
        }
        
        if let v  = env["readonly"] {
            self.readonly = (v == "true")
        }
        
        if let v = env["revsLimit"], let revsLimit = UInt(v)  {
            self.revsLimit = revsLimit
        }
        
        if let v = env["storage"] {
            self.storage = v
        }
        
        if let v = env["dbpasswords"] {
            self.dbpasswords = v
        }
    }
    
    func setValues(json: Dictionary<String, AnyObject>) {
        if let v = json["adminPort"] as? UInt  {
            self.adminPort = v
        }
        
        if let v = json["port"] as? UInt  {
            self.port = v
        }
        
        if let v  = json["readonly"] as? Bool {
            self.readonly = v
        }
        
        if let v = json["revsLimit"] as? UInt  {
            self.revsLimit = v
        }
        
        if let v = json["storage"] as? String {
            self.storage = v
        }
        
        if let v = json["dbpasswords"] as? String {
            self.dbpasswords = v
        }
    }
    
    func asJson() -> Dictionary<String, Any> {
        var json: Dictionary<String, Any> = [
            "adminPort": adminPort,
            "port": port,
            "readonly": readonly,
            "storage": storage,
        ];
        
        if self.revsLimit > 0 {
            json["revsLimit"] = revsLimit
        }
        
        if let dbpasswords = self.dbpasswords {
            json["dbpasswords"] = dbpasswords
        }
        
        return json
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copied = Config()
        copied.adminPort = adminPort
        copied.port = port
        copied.readonly = readonly
        copied.revsLimit = revsLimit
        copied.storage = storage
        copied.dbpasswords = dbpasswords
        return copied
    }
}
