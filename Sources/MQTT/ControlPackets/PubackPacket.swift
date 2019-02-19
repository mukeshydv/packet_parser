//
//  PubackPacket.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct PubackPacket: MQTTPacketCodable {
    let header: Header
    
    let fixedHeader: MQTTPacketFixedHeader
    
    init(header: Header) {
        self.fixedHeader = MQTTPacketFixedHeader(packetType: .PUBACK, flags: 0)
        self.header = header
    }
    
    init?(decoder: [UInt8]) throws {
        if decoder.count == 0 {
            return nil
        }
        
        fixedHeader = MQTTPacketFixedHeader(networkByte: decoder[0])
        
        if fixedHeader.packetType != .PUBACK {
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

extension PubackPacket {
    struct Header {
        let identifier: UInt16
        let reasonCode: ReasonCode
        let properties: Property
        
        init(
            identifier: UInt16,
            reasonCode: ReasonCode = .success,
            properties: Property = .init()
            ) {
            self.identifier = identifier
            self.reasonCode = reasonCode
            self.properties = properties
        }
        
        init(decoder: [UInt8], remainingLength: UInt32) throws {
            if decoder.count < 2 {
                throw PacketError.invalidPacket("identifier not present")
            }
            
            identifier = UInt16(decoder[0], decoder[1])
            
            var reasonCode: ReasonCode
            var properties: Property
            
            if remainingLength < 3 {
                reasonCode = .success
                properties = Property()
            } else {
                if decoder.count < 3 {
                    throw PacketError.invalidPacket("reasonCode not present")
                }
                
                if let reasonCode1 = ReasonCode(rawValue: decoder[2]) {
                    reasonCode = reasonCode1
                } else {
                    throw PacketError.invalidPacket("Invalid reason code")
                }
                
                if remainingLength > 3 {
                    let remainingBytes = decoder.dropFirst(3).array
                    properties = try Property(decoder: remainingBytes)
                } else {
                    properties = Property()
                }
            }
            
            self.reasonCode = reasonCode
            self.properties = properties
        }
        
        func encode() throws -> [UInt8] {
            var bytes: [UInt8] = []
            
            let encodedProperties = try properties.encode()
            
            if encodedProperties.count == 0 && reasonCode == .success {
                return identifier.bytes
            }
            
            bytes.append(contentsOf: identifier.bytes)
            bytes.append(reasonCode.rawValue)
            bytes.append(contentsOf: encodedProperties)
            
            return bytes
        }
    }
}

extension PubackPacket.Header {
    struct Property {
        let reasonString: String?
        let userProperty: [String: String]?
        private(set) var totalLength = 0
        
        init(reasonString: String? = nil, userProperty: [String: String]? = nil) {
            self.reasonString = reasonString
            self.userProperty = userProperty
        }
        
        init(decoder: [UInt8]) throws {
            var reasonString: String?
            var userProperty: [String: String] = [:]
            
            if decoder.count > 0 {
                
                let variableLength = try VariableByteInteger(from: decoder)
                if variableLength.value > decoder.count - variableLength.bytes.count {
                    throw PacketError.invalidPacket("Packet variable properties size invalid")
                }
                totalLength = variableLength.totlaLength
                
                var isDecoded: [MQTTPropertyIdentifier: Bool] = [:]
                var currentIndex = variableLength.bytes.count
                
                while currentIndex < decoder.count, currentIndex < totalLength {
                    if let property = try StringProperty(MQTTPropertyIdentifier.reasonString, decoder, startIndex: currentIndex) {
                        if isDecoded[property.identifier] == true {
                            throw PacketError.duplicateQuality("reasonString")
                        }
                        isDecoded[property.identifier] = true
                        
                        reasonString = property.value
                        currentIndex += property.propertyLength + 1
                    }
                    
                    while let property = try StringPairProperty(MQTTPropertyIdentifier.userProperty, decoder, startIndex: currentIndex) {
                        userProperty[property.key] = property.value
                        currentIndex += property.propertyLength + 1
                    }
                }
            }
            
            self.reasonString = reasonString
            self.userProperty = userProperty.count > 0 ? userProperty : nil
        }
        
        func encode(_ truncatingZero: Bool = true) throws -> [UInt8] {
            var bytes: [UInt8] = []
            
            if let property = reasonString {
                bytes.append(MQTTPropertyIdentifier.reasonString.rawValue)
                
                let utf8String = try MQTTUTF8String(property)
                bytes.append(contentsOf: utf8String.bytes)
            }
            
            if let userProperties = userProperty {
                for property in userProperties {
                    bytes.append(MQTTPropertyIdentifier.userProperty.rawValue)
                    
                    let keyValueUtf8 = try MQTTUTF8StringPair(property.key, property.value)
                    bytes.append(contentsOf: keyValueUtf8.bytes)
                }
            }
            
            if bytes.count == 0, truncatingZero { return [] }
            
            let propertyLength = VariableByteInteger(UInt32(bytes.count))
            return propertyLength.bytes + bytes
        }
    }
}
