//
//  PubackPacket.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct PubackPacket {
    let header: Header
    
    struct Header {
        let identifier: UInt16
        let reasonCode: ReasonCode = .success
        let properties: Property?
        
        struct Property {
            let reasonString: String?
            let userProperty: [String: String] = [:]
        }
    }
}
