//
//  ConnackPacket.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct ConnackPacket {
    let header: Header // Variable header
    
    init?(decoder: [UInt8]) throws {
        if decoder.count == 0 {
            return nil
        }
        
        if decoder[0] != 0x20 {
            return nil
        }
        
        let variableHeaderLength = try VariableByteInteger(from: decoder, startIndex: 1)
        if variableHeaderLength.value + 1 != decoder.count - variableHeaderLength.bytes.count {
            throw ConnectPacketError.invalidPacket("Packet variable header size invalid")
        }
        
        if let header = try Header(decoder: decoder) {
            self.header = header
        } else {
            return nil
        }
    }
    
    struct Header {
        let flags: Flags // first byte
        let reasonCode: ReasonCode // Status code
        let properties: Property // properties
        
        init?(decoder: [UInt8]) throws {
            
            return nil
        }
        
        struct Flags {
            let sessionPresent: Bool // 0th bit, rest bits must be set to 0, (v5)
        }
        
        struct Property {
            let sessionExpiryInterval: UInt32?
            let receiveMaximum: UInt16 = .max
            let maximumQoS: UInt8 = 2
            let retainAvailable: Bool = true
            let maximumPacketSize: UInt32?
            let assignedClientIdentifier: String?
            let topicAliasMaximum: UInt16 = 0
            let reasonString: String?
            let userProperties: [String: String] = [:]
            let wildcardSubscriptionAvailable: Bool = true
            let subscriptionIdentifiersAvailable: Bool = true
            let sharedSubscriptionAvailble: Bool = true
            let serverKeepAlive: UInt16?
            let responseInformation: String?
            let serverReference: String?
            let authenticationMethod: String?
            let authenticationData: Data?
        }
    }
}




