//
//  SubackPacket.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct SubackPacket: MQTTPacketCodable {
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
}

extension SubackPacket {
    struct Header {
        let identifier: UInt16
        let properties: PubackPacket.Header.Property?
    }
}
