//
//  AuthPacket.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct AuthPacket: MQTTPacketCodable {
    let header: Header
    
    let fixedHeader: MQTTPacketFixedHeader
    
    func encodedVariableHeader() throws -> [UInt8] {
        // TODO:
        return []
    }
    
    func encodedPayload() throws -> [UInt8] {
        // TODO:
        return []
    }
    
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
