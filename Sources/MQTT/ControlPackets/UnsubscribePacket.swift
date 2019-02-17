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
}

extension UnsubscribePacket {
    struct Header {
        let identifier: UInt16
        let properties: Property?
    }
}

extension UnsubscribePacket.Header {
    struct Property {
        let userProperty: [String: String] = [:]
    }
}
