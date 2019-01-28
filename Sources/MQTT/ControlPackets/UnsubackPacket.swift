//
//  UnsubackPacket.swift
//  MQTTServer
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct UnsubackPacket {
    let header: Header
    let payload: [ReasonCode]
    
    struct Header {
        let identifier: UInt16
        let properties: Property?
        
        struct Property {
            let reasonString: String?
            let userProperty: [String: String] = [:]
        }
    }
}
