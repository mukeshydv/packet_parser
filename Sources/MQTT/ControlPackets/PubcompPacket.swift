//
//  PubcompPacket.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

public struct PubcompPacket: MQTTPacketCodable {
    public typealias Header = PubackPacket.Header
    
    let header: Header
    public let fixedHeader: MQTTPacketFixedHeader
    
    init(header: Header) {
        self.fixedHeader = MQTTPacketFixedHeader(packetType: .PUBCOMP, flags: 0)
        self.header = header
    }
    
    public init(decoder: [UInt8]) throws {
        if decoder.count == 0 {
            throw PacketError.invalidPacket("Packet identifier invalid")
        }
        
        fixedHeader = try MQTTPacketFixedHeader(networkByte: decoder[0])
        
        if fixedHeader.packetType != .PUBCOMP {
            throw PacketError.invalidPacket("Packet identifier invalid")
        }
        
        let variableHeaderLength = try VariableByteInteger(from: decoder, startIndex: 1)
        if variableHeaderLength.value + 1 != decoder.count - variableHeaderLength.bytes.count {
            throw PacketError.invalidPacket("Packet variable header size invalid")
        }
        
        let currentIndex = variableHeaderLength.bytes.count + 1
        let remainingBytes = decoder.dropFirst(currentIndex).array
        
        header = try Header(decoder: remainingBytes, remainingLength: variableHeaderLength.value)
    }
    
    public func encodedVariableHeader() throws -> [UInt8] {
        return try header.encode()
    }
    
    public func encodedPayload() throws -> [UInt8] {
        return []
    }
}
