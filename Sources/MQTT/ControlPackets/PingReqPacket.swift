//
//  PingReqPacket.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

public struct PingReqPacket: MQTTPacketCodable {
    public let fixedHeader: MQTTPacketFixedHeader
    
    public init() {
        fixedHeader = MQTTPacketFixedHeader(packetType: .PINGREQ, flags: 0)
    }
    
    public init(decoder: [UInt8]) throws {
        if decoder.count == 0 {
            throw PacketError.invalidPacket("Packet identifier invalid")
        }
        
        fixedHeader = try MQTTPacketFixedHeader(networkByte: decoder[0])
        
        if fixedHeader.packetType != .PINGREQ {
            throw PacketError.invalidPacket("Packet identifier invalid")
        }
        
        let variableHeaderLength = try VariableByteInteger(from: decoder, startIndex: 1)
        if variableHeaderLength.value + 1 != decoder.count - variableHeaderLength.bytes.count {
            throw PacketError.invalidPacket("Packet variable header size invalid")
        }
    }
    
    public func encodedVariableHeader() throws -> [UInt8] {
        return []
    }
    
    public func encodedPayload() throws -> [UInt8] {
        return []
    }
}
