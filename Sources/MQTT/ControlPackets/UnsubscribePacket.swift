//
//  UnsubscribePacket.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

public struct UnsubscribePacket: MQTTPacketCodable {
    let header: Header
    let payload: [String]
    
    public let fixedHeader: MQTTPacketFixedHeader
    
    public init(header: Header, payload: [String]) {
        self.fixedHeader = MQTTPacketFixedHeader(packetType: .UNSUBSCRIBE, flags: 2)
        self.header = header
        self.payload = payload
    }
    
    public init(decoder: [UInt8]) throws {
        if decoder.count == 0 {
            throw PacketError.invalidPacket("Packet identifier invalid")
        }
        
        fixedHeader = try MQTTPacketFixedHeader(networkByte: decoder[0])
        
        if fixedHeader.packetType != .UNSUBSCRIBE {
            throw PacketError.invalidPacket("Packet identifier invalid")
        }
        
        let variableHeaderLength = try VariableByteInteger(from: decoder, startIndex: 1)
        if variableHeaderLength.value + 1 != decoder.count - variableHeaderLength.bytes.count {
            throw PacketError.invalidPacket("Packet variable header size invalid")
        }
        
        var currentIndex = variableHeaderLength.bytes.count + 1
        let remainingBytes = decoder.dropFirst(currentIndex).array
        
        header = try Header(decoder: remainingBytes)
        
        let payloadBytes = decoder.dropFirst(header.totalLength + currentIndex).array
        
        if payloadBytes.count == 0 {
            throw PacketError.payloadError("No payload")
        }
        
        currentIndex = 0
        var payload: [String] = []
        while currentIndex < payloadBytes.count {
            let utf8String = try MQTTUTF8String(from: payloadBytes, startIndex: currentIndex)
            payload.append(utf8String.value)
            currentIndex += utf8String.bytes.count
        }
        self.payload = payload
    }
    
    public func encodedVariableHeader() throws -> [UInt8] {
        return try header.encode()
    }
    
    public func encodedPayload() throws -> [UInt8] {
        var bytes: [UInt8] = []
        
        for data in payload {
            let utfEncoded = try MQTTUTF8String(data)
            bytes.append(contentsOf: utfEncoded.bytes)
        }
        
        return bytes
    }
}

extension UnsubscribePacket {
    public struct Header {
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

extension UnsubscribePacket.Header {
    public struct Property {
        let userProperty: [String: String]?
        private(set) var totalLength = 0
        
        public init(userProperty: [String: String]? = nil) {
            self.userProperty = userProperty
        }
        
        public init(decoder: [UInt8]) throws {
            var userProperty: [String: String] = [:]
            
            if decoder.count > 0 {
                
                let variableLength = try VariableByteInteger(from: decoder)
                if variableLength.value > decoder.count - variableLength.bytes.count {
                    throw PacketError.invalidPacket("Packet variable properties size invalid")
                }
                totalLength = variableLength.totlaLength
                
                var currentIndex = variableLength.bytes.count
                
                while currentIndex < totalLength, let property = try StringPairProperty(MQTTPropertyIdentifier.userProperty, decoder, startIndex: currentIndex) {
                    userProperty[property.key] = property.value
                    currentIndex += property.propertyLength + 1
                }
            }
            
            self.userProperty = userProperty.count > 0 ? userProperty : nil
        }
        
        func encode(_ truncatingZero: Bool = true) throws -> [UInt8] {
            var bytes: [UInt8] = []
            
            if let userProperties = userProperty {
                for property in userProperties {
                    bytes.append(MQTTPropertyIdentifier.userProperty.rawValue)
                    
                    let keyValueUtf8 = try MQTTUTF8StringPair(property.key, property.value)
                    bytes.append(contentsOf: keyValueUtf8.bytes)
                }
            }
            
            let propertyLength = VariableByteInteger(UInt32(bytes.count))
            return propertyLength.bytes + bytes
        }
    }
}
