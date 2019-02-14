//
//  SubscribePacket.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct SubscribePacket: MQTTPacketCodable {
    let header: Header
    let payload: Payload
    
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
            let subscriptionIdentifier: UInt32?
            let userProperty: [String: String]
        }
    }
    
    struct Payload {
        let topics: [String: SubscriptionOption]
        
        struct SubscriptionOption {
            let maximumQoS: UInt8
            let noLocalOption: Bool
            let retainAsPublished: Bool
            let retainHandling: UInt8
        }
    }
}
