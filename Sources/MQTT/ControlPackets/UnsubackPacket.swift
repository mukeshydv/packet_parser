//
//  UnsubackPacket.swift
//  MQTTServer
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct UnsubackPacket: MQTTPacketCodable {
    let header: Header
    let payload: [ReasonCode]
    
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
            let reasonString: String?
            let userProperty: [String: String] = [:]
        }
    }
}
