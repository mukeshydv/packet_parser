//
//  MQTTPacket.swift
//  MQTT
//
//  Created by Mukesh on 14/02/19.
//

import Foundation

public struct MQTTPacketFixedHeader {
    let packetType: MQTTControlPacketType
    let flags: UInt8
    
    init(packetType: MQTTControlPacketType, flags: UInt8) {
        self.packetType = packetType
        self.flags = flags
    }
    
    init(networkByte: UInt8) throws {
        guard let packetType = MQTTControlPacketType(rawValue: networkByte >> 4) else {
            throw PacketError.invalidPacket("Invalid packet identifier")
        }
        self.packetType = packetType
        flags = networkByte & 0x0F
    }
    
    func encoded() -> UInt8 {
        var fixedHeaderFirstByte = UInt8(0)
        fixedHeaderFirstByte = (0x0F & flags) | (packetType.rawValue << 4)
        return fixedHeaderFirstByte
    }
}

public typealias MQTTPacketCodable = MQTTPacketEncodable & MQTTPacketDecodable

public protocol MQTTPacketEncodable {
    var fixedHeader: MQTTPacketFixedHeader { get }
    func encodedVariableHeader() throws -> [UInt8]
    func encodedPayload() throws -> [UInt8]
}

extension MQTTPacketEncodable {
    func encoded() throws -> [UInt8] {
        let remainingData = try encodedVariableHeader() + (try encodedPayload())
        let remainingDataLength = VariableByteInteger(UInt32(remainingData.count)).bytes
        return [fixedHeader.encoded()] + remainingDataLength + remainingData
    }
}

public protocol MQTTPacketDecodable {
    init(decoder: [UInt8]) throws
}
