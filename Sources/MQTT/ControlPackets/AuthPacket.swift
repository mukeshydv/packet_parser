//
//  AuthPacket.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct AuthPacket {
    let header: Header
    
    struct Header {
        let authenticationReason: UInt8
        let properties: Property
        
        struct Property {
            let authenticationMethod: String
            let authenticationData: Data?
            let reasonString: String?
            let userProperty: [String: String]
        }
    }
}
