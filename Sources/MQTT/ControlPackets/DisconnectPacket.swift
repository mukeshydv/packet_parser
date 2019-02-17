//
//  DisconnectPacket.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct DisconnectPacket: MQTTPacketCodable {
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
}

extension DisconnectPacket {
    struct Header {
        let reasonCode: ReasonCode = .success
        let properties: Property?
    }
}

extension DisconnectPacket.Header {
    struct Property {
        let sessionExpiryInterval: UInt32?
        let reasonString: String?
        let userProperty: [String: String] = [:]
        let serverReference: String?
    }
}
