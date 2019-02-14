//
//  UnsubscribePacket.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct UnsubscribePacket: MQTTPacketCodable {
    let header: Header
    let payload: [String]
    
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
        let properties: Property?
        
        struct Property {
            let userProperty: [String: String] = [:]
        }
    }
}
