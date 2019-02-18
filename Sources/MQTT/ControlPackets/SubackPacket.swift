//
//  SubackPacket.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct SubackPacket: MQTTPacketCodable {
    let header: Header
    let payload: [ReasonCode]
    
    let fixedHeader: MQTTPacketFixedHeader
    
    init?(decoder: [UInt8]) throws {
        if decoder.count == 0 {
            return nil
        }
        
        fixedHeader = MQTTPacketFixedHeader(networkByte: decoder[0])
        
        if fixedHeader.packetType != .SUBACK {
            return nil
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
    
    func encodedVariableHeader() throws -> [UInt8] {
        // TODO:
        return []
    }
    
    func encodedPayload() throws -> [UInt8] {
        // TODO:
        return []
    }
}

extension SubackPacket {
    struct Header {
        let identifier: UInt16
        let properties: PubackPacket.Header.Property
        
        fileprivate var totalLength = 0
        
        init(identifier: UInt16, properties: PubackPacket.Header.Property = .init()) {
            self.identifier = identifier
            self.properties = properties
        }
        
        init(decoder: [UInt8]) throws {
            if decoder.count < 3 {
                throw PacketError.invalidPacket("identifier not present")
            }
            
            identifier = UInt16(decoder[0], decoder[1])
            
            let remainingBytes = decoder.dropFirst(2).array
            properties = try PubackPacket.Header.Property(decoder: remainingBytes)
            totalLength = 2 + properties.totalLength
        }
    }
}
