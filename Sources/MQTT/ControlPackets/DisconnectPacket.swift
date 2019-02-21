//
//  DisconnectPacket.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct DisconnectPacket: MQTTPacketCodable {
    let header: Header
    
    let fixedHeader: MQTTPacketFixedHeader
    
    init(header: Header = .init()) {
        fixedHeader = MQTTPacketFixedHeader(packetType: .DISCONNECT, flags: 0)
        self.header = header
    }
    
    init?(decoder: [UInt8]) throws {
        if decoder.count == 0 {
            return nil
        }
        
        fixedHeader = MQTTPacketFixedHeader(networkByte: decoder[0])
        
        if fixedHeader.packetType != .DISCONNECT {
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

extension DisconnectPacket {
    struct Header {
        let reasonCode: ReasonCode
        let properties: Property
        
        init(reasonCode: ReasonCode = .success, properties: Property = .init()) {
            self.reasonCode = reasonCode
            self.properties = properties
        }
        
        init(decoder: [UInt8], remainingLength: UInt32) throws {
            var reasonCode: ReasonCode
            var properties: Property
            
            if remainingLength < 1 {
                reasonCode = .success
                properties = .init()
            } else {
                if let reasonCode1 = ReasonCode(rawValue: decoder[0]) {
                    reasonCode = reasonCode1
                } else {
                    throw PacketError.invalidPacket("Invalid reason code")
                }
                
                if remainingLength > 1 {
                    let remainingBytes = decoder.dropFirst(1).array
                    properties = try .init(decoder: remainingBytes)
                } else {
                    properties = .init()
                }
            }
            
            self.reasonCode = reasonCode
            self.properties = properties
        }
        
        func encode() throws -> [UInt8] {
            var bytes: [UInt8] = []
            
            let encodedProperties = try properties.encode()
            
            if encodedProperties.count == 0 && reasonCode == .success {
                return []
            }
            
            bytes.append(reasonCode.rawValue)
            bytes.append(contentsOf: encodedProperties)
            
            return bytes
        }
    }
}

extension DisconnectPacket.Header {
    struct Property {
        let sessionExpiryInterval: UInt32?
        let reasonString: String?
        let userProperty: [String: String]?
        let serverReference: String?
        
        init(sessionExpiryInterval: UInt32? = nil,
             reasonString: String? = nil,
             userProperty: [String: String]? = nil,
             serverReference: String? = nil) {
            self.sessionExpiryInterval = sessionExpiryInterval
            self.reasonString = reasonString
            self.userProperty = userProperty
            self.serverReference = serverReference
        }
        
        init(decoder: [UInt8]) throws {
            var sessionExpiryInterval: UInt32?
            var reasonString: String?
            var userProperty: [String: String] = [:]
            var serverReference: String?
            
            if decoder.count > 0 {
                
                let variableLength = try VariableByteInteger(from: decoder)
                if variableLength.value > decoder.count - variableLength.bytes.count {
                    throw PacketError.invalidPacket("Packet variable properties size invalid")
                }
                let totalLength = variableLength.totlaLength
                
                var isDecoded: [MQTTPropertyIdentifier: Bool] = [:]
                var currentIndex = variableLength.bytes.count
                
                while currentIndex < decoder.count, currentIndex < totalLength {
                    if let property = try FourByteProperty(MQTTPropertyIdentifier.sessionExpiryInterval, decoder, startIndex: currentIndex) {
                        if isDecoded[property.identifier] == true {
                            throw PacketError.duplicateQuality("sessionExpiryInterval")
                        }
                        isDecoded[property.identifier] = true
                        
                        sessionExpiryInterval = property.value
                        currentIndex += property.propertyLength + 1
                    }
                    
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
                    
                    if let property = try StringProperty(MQTTPropertyIdentifier.serverReference, decoder, startIndex: currentIndex) {
                        if isDecoded[property.identifier] == true {
                            throw PacketError.duplicateQuality("serverReference")
                        }
                        isDecoded[property.identifier] = true
                        
                        serverReference = property.value
                        currentIndex += property.propertyLength + 1
                    }
                }
            }
            
            self.sessionExpiryInterval = sessionExpiryInterval
            self.reasonString = reasonString
            self.serverReference = serverReference
            self.userProperty = userProperty.count > 0 ? userProperty : nil
        }
        
        func encode() throws -> [UInt8] {
            var bytes: [UInt8] = []
            
            if let property = sessionExpiryInterval {
                bytes.append(MQTTPropertyIdentifier.sessionExpiryInterval.rawValue)
                bytes.append(contentsOf: property.bytes)
            }
            
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
            
            if let property = serverReference {
                bytes.append(MQTTPropertyIdentifier.serverReference.rawValue)
                
                let utf8String = try MQTTUTF8String(property)
                bytes.append(contentsOf: utf8String.bytes)
            }
            
            if bytes.count == 0 { return [] }
            
            let propertyLength = VariableByteInteger(UInt32(bytes.count))
            return propertyLength.bytes + bytes
        }
    }
}
