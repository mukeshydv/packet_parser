//
//  UnsubackPacket.swift
//  MQTTServer
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct UnsubackPacket: MQTTPacketCodable {
    let header: SubackPacket.Header
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
