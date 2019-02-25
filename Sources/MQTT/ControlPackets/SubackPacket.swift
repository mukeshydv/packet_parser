//
//  SubackPacket.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

public struct SubackPacket: MQTTPacketCodable {
    let header: Header
    let payload: [ReasonCode]
    
    public let fixedHeader: MQTTPacketFixedHeader
    
    public init(header: Header, payload: [ReasonCode]) {
        self.fixedHeader = MQTTPacketFixedHeader(packetType: .SUBACK, flags: 0)
        self.header = header
        self.payload = payload
    }
    
    public init(decoder: [UInt8]) throws {
        if decoder.count == 0 {
            throw PacketError.invalidPacket("Packet identifier invalid")
        }
        
        fixedHeader = try MQTTPacketFixedHeader(networkByte: decoder[0])
        
        if fixedHeader.packetType != .SUBACK {
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
        payload = payloadBytes.compactMap(ReasonCode.init)
    }
    
    public func encodedVariableHeader() throws -> [UInt8] {
        return try header.encode()
    }
    
    public func encodedPayload() throws -> [UInt8] {
        return payload.map { $0.rawValue }
    }
}

extension SubackPacket {
    public struct Header {
        public typealias Property = PubackPacket.Header.Property
        
        let identifier: UInt16
        let properties: Property
        
        fileprivate(set) var totalLength = 0
        
        public init(identifier: UInt16, properties: Property = .init()) {
            self.identifier = identifier
            self.properties = properties
        }
        
        public init(decoder: [UInt8]) throws {
            if decoder.count < 3 {
                throw PacketError.invalidPacket("identifier not present")
            }
            
            identifier = UInt16(decoder[0], decoder[1])
            
            let remainingBytes = decoder.dropFirst(2).array
            properties = try Property(decoder: remainingBytes)
            totalLength = 2 + properties.totalLength
        }
        
        func encode() throws -> [UInt8] {
            var bytes: [UInt8] = []
            
            bytes.append(contentsOf: identifier.bytes)
            bytes.append(contentsOf: try properties.encode(false))
            
            return bytes
        }
    }
}
