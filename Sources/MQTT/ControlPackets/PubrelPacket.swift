//
//  PubrelPacket.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct PubrelPacket: MQTTPacketCodable {
    typealias Header = PubackPacket.Header
    
    let header: Header
    let fixedHeader: MQTTPacketFixedHeader
    
    init(header: Header) {
        self.fixedHeader = MQTTPacketFixedHeader(packetType: .PUBREL, flags: 2)
        self.header = header
    }
    
    init?(decoder: [UInt8]) throws {
        if decoder.count == 0 {
            return nil
        }
        
        fixedHeader = MQTTPacketFixedHeader(networkByte: decoder[0])
        
        if fixedHeader.packetType != .PUBREL {
            return nil
        }
        
        let variableHeaderLength = try VariableByteInteger(from: decoder, startIndex: 1)
        if variableHeaderLength.value + 1 != decoder.count - variableHeaderLength.bytes.count {
            throw PacketError.invalidPacket("Packet variable header size invalid")
        }
        
        let currentIndex = variableHeaderLength.bytes.count + 1
        let remainingBytes = decoder.dropFirst(currentIndex).array
        
        header = try Header(decoder: remainingBytes, remainingLength: variableHeaderLength.value)
    }
    
    func encodedVariableHeader() throws -> [UInt8] {
        return try header.encode()
    }
    
    func encodedPayload() throws -> [UInt8] {
        return []
    }
}
