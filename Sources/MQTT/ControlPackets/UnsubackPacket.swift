//
//  UnsubackPacket.swift
//  MQTTServer
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

public struct UnsubackPacket: MQTTPacketCodable {
    public typealias Header = SubackPacket.Header
    
    let header: Header
    let payload: [ReasonCode]
    
    public let fixedHeader: MQTTPacketFixedHeader
    
    public init(header: Header, payload: [ReasonCode]) {
        self.fixedHeader = MQTTPacketFixedHeader(packetType: .UNSUBACK, flags: 0)
        self.header = header
        self.payload = payload
    }
    
    public init(decoder: [UInt8]) throws {
        if decoder.count == 0 {
            throw PacketError.invalidPacket("Packet identifier invalid")
        }
        
        fixedHeader = try MQTTPacketFixedHeader(networkByte: decoder[0])
        
        if fixedHeader.packetType != .UNSUBACK {
            throw PacketError.invalidPacket("Packet identifier invalid")
        }
        
        let variableHeaderLength = try VariableByteInteger(from: decoder, startIndex: 1)
        if variableHeaderLength.value + 1 != decoder.count - variableHeaderLength.bytes.count {
            throw PacketError.invalidPacket("Packet variable header size invalid")
        }
        
        let currentIndex = variableHeaderLength.bytes.count + 1
        let remainingBytes = decoder.dropFirst(currentIndex).array
        
        header = try Header(decoder: remainingBytes)
        
        let payloadBytes = decoder.dropFirst(header.totalLength + currentIndex).array
        
        if payloadBytes.count == 0 {
            throw PacketError.payloadError("No payload")
        }
        
        payload = payloadBytes.compactMap(ReasonCode.init)
    }
    
    public func encodedVariableHeader() throws -> [UInt8] {
        return try header.encode()
    }
    
    public func encodedPayload() throws -> [UInt8] {
        return payload.map { $0.rawValue }
    }
}
