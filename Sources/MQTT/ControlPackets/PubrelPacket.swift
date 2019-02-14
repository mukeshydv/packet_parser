//
//  PubrelPacket.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct PubrelPacket: MQTTPacketCodable {
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
        let identifier: UInt16
        let reasonCode: ReasonCode = .success
        let properties: Property?
        
        struct Property {
            let reasonString: String?
            let userProperty: [String: String] = [:]
        }
    }
}
