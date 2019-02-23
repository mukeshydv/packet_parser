//
//  AuthPacket.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct AuthPacket: MQTTPacketCodable {
    let header: Header
    
    let fixedHeader: MQTTPacketFixedHeader
    
    init(header: Header = .init()) {
        fixedHeader = MQTTPacketFixedHeader(packetType: .AUTH, flags: 0)
        self.header = header
    }
    
    init(decoder: [UInt8]) throws {
        if decoder.count == 0 {
            throw PacketError.invalidPacket("Packet identifier invalid")
        }
        
        fixedHeader = try MQTTPacketFixedHeader(networkByte: decoder[0])
        
        if fixedHeader.packetType != .AUTH {
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
    
    func encodedVariableHeader() throws -> [UInt8] {
        return try header.encode()
    }
    
    func encodedPayload() throws -> [UInt8] {
        return []
    }
}

extension AuthPacket {
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

extension AuthPacket.Header {
    struct Property {
        let authenticationMethod: String?
        let authenticationData: Data?
        let reasonString: String?
        let userProperty: [String: String]?
        
        init(authenticationMethod: String? = nil,
             authenticationData: Data? = nil,
             reasonString: String? = nil,
             userProperty: [String: String]? = nil) {
            self.authenticationMethod = authenticationMethod
            self.reasonString = reasonString
            self.userProperty = userProperty
            self.authenticationData = authenticationData
        }
        
        init(decoder: [UInt8]) throws {
            var authenticationMethod: String?
            var reasonString: String?
            var userProperty: [String: String] = [:]
            var authenticationData: Data?
            
            if decoder.count > 0 {
                
                let variableLength = try VariableByteInteger(from: decoder)
                if variableLength.value > decoder.count - variableLength.bytes.count {
                    throw PacketError.invalidPacket("Packet variable properties size invalid")
                }
                let totalLength = variableLength.totlaLength
                
                var isDecoded: [MQTTPropertyIdentifier: Bool] = [:]
                var currentIndex = variableLength.bytes.count
                
                while currentIndex < decoder.count, currentIndex < totalLength {
                    if let property = try StringProperty(MQTTPropertyIdentifier.authenticationMethod, decoder, startIndex: currentIndex) {
                        if isDecoded[property.identifier] == true {
                            throw PacketError.duplicateQuality("authenticationMethod")
                        }
                        isDecoded[property.identifier] = true
                        
                        authenticationMethod = property.value
                        currentIndex += property.propertyLength + 1
                    }
                    
                    if let property = try DataProperty(MQTTPropertyIdentifier.authenticationData, decoder, startIndex: currentIndex) {
                        if isDecoded[property.identifier] == true {
                            throw PacketError.duplicateQuality("authenticationData")
                        }
                        isDecoded[property.identifier] = true
                        
                        authenticationData = property.value
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
                }
            }
            
            self.authenticationMethod = authenticationMethod
            self.reasonString = reasonString
            self.authenticationData = authenticationData
            self.userProperty = userProperty.count > 0 ? userProperty : nil
        }
        
        func encode() throws -> [UInt8] {
            var bytes: [UInt8] = []
            
            if let property = authenticationMethod {
                bytes.append(MQTTPropertyIdentifier.authenticationMethod.rawValue)
                
                let utf8String = try MQTTUTF8String(property)
                bytes.append(contentsOf: utf8String.bytes)
            }
            
            if let property = authenticationData {
                bytes.append(MQTTPropertyIdentifier.authenticationData.rawValue)
                
                let data = try MQTTData(property)
                bytes.append(contentsOf: data.bytes)
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
            
            if bytes.count == 0 { return [] }
            
            let propertyLength = VariableByteInteger(UInt32(bytes.count))
            return propertyLength.bytes + bytes
        }
    }
}
