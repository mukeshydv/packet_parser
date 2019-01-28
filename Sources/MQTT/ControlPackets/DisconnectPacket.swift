//
//  DisconnectPacket.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct DisconnectPacket {
    let header: Header
    
    struct Header {
        let reasonCode: ReasonCode = .success
        let properties: Property?
        
        struct Property {
            let sessionExpiryInterval: UInt32?
            let reasonString: String?
            let userProperty: [String: String] = [:]
            let serverReference: String?
        }
    }
}
