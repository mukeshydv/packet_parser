//
//  PingRespPacket.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct PingRespPacket: MQTTPacketCodable {
    let fixedHeader: MQTTPacketFixedHeader
    
    init() {
        fixedHeader = MQTTPacketFixedHeader(packetType: .PINGRESP, flags: 0)
    }
    
    init(decoder: [UInt8]) throws {
        if decoder.count == 0 {
            throw PacketError.invalidPacket("Packet identifier invalid")
        }
        
        fixedHeader = try MQTTPacketFixedHeader(networkByte: decoder[0])
        
        if fixedHeader.packetType != .PINGRESP {
            throw PacketError.invalidPacket("Packet identifier invalid")
        }
        
        let variableHeaderLength = try VariableByteInteger(from: decoder, startIndex: 1)
        if variableHeaderLength.value + 1 != decoder.count - variableHeaderLength.bytes.count {
            throw PacketError.invalidPacket("Packet variable header size invalid")
        }
    }
    
    func encodedVariableHeader() throws -> [UInt8] {
        return []
    }
    
    func encodedPayload() throws -> [UInt8] {
        return []
    }
}
