//
//  ConnackPacket.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct ConnackPacket: MQTTPacketCodable {
    let fixedHeader: MQTTPacketFixedHeader
    
    let header: Header // Variable header
    
    init(header: Header) {
        self.fixedHeader = MQTTPacketFixedHeader(packetType: .CONNACK, flags: 0)
        self.header = header
    }
    
    init?(decoder: [UInt8]) throws {
        if decoder.count == 0 {
            return nil
        }
        
        if decoder[0] != 0x20 {
            return nil
        }
        
        self.fixedHeader = MQTTPacketFixedHeader(packetType: .CONNACK, flags: 0)
        
        let variableHeaderLength = try VariableByteInteger(from: decoder, startIndex: 1)
        if variableHeaderLength.value + 1 != decoder.count - variableHeaderLength.bytes.count {
            throw PacketError.invalidPacket("Packet variable header size invalid")
        }
        
        let currentIndex = variableHeaderLength.bytes.count + 1
        let remainingBytes = decoder.dropFirst(currentIndex).array
        
        if let header = try Header(decoder: remainingBytes) {
            self.header = header
        } else {
            return nil
        }
    }
    
    func encodedVariableHeader() throws -> [UInt8] {
        return try header.encode()
    }
    
    func encodedPayload() throws -> [UInt8] {
        return []
    }
}

extension ConnackPacket {
    struct Header {
        let flags: Flags // first byte
        let reasonCode: ReasonCode // Status code
        let properties: Property? // properties
        
        init(sessionPresent: Bool, reasonCode: ReasonCode, properties: Property? = nil) {
            self.flags = Flags(sessionPresent: sessionPresent)
            self.reasonCode = reasonCode
            self.properties = properties
        }
        
        init?(decoder: [UInt8]) throws {
            
            if decoder.count < 2 {
                throw PacketError.invalidPacket("Packet size too small")
            }
            
            if decoder[0] & 0xFE != 0 {
                throw PacketError.invalidPacket("Wrong seassion presence flag")
            }
            
            flags = Flags(sessionPresent: decoder[0] & 0xFF == 0x01)
            if let reasonCode = ReasonCode(rawValue: decoder[1]) {
                self.reasonCode = reasonCode
            } else {
                throw PacketError.invalidPacket("Wrong reason code")
            }
            
            let remainingBytes = decoder.dropFirst(2).array
            properties = try Property(decoder: remainingBytes)
        }
        
        func encode() throws -> [UInt8] {
            var bytes: [UInt8] = []
            
            bytes.append(flags.sessionPresent ? 0x01 : 0x00)
            bytes.append(reasonCode.rawValue)
            
            if let properties = properties {
                bytes.append(contentsOf: try properties.encode())
            }
            
            return bytes
        }
    }
}

extension ConnackPacket.Header {
    
    struct Flags {
        let sessionPresent: Bool // 0th bit, rest bits must be set to 0, (v5)
    }
    
    struct Property {
        let sessionExpiryInterval: UInt32?
        let receiveMaximum: UInt16
        let maximumQoS: UInt8
        let retainAvailable: Bool
        let maximumPacketSize: UInt32?
        let assignedClientIdentifier: String?
        let topicAliasMaximum: UInt16
        let reasonString: String?
        let userProperties: [String: String]
        let wildcardSubscriptionAvailable: Bool
        let subscriptionIdentifiersAvailable: Bool
        let sharedSubscriptionAvailable: Bool
        let serverKeepAlive: UInt16?
        let responseInformation: String?
        let serverReference: String?
        let authenticationMethod: String?
        let authenticationData: Data?
        
        init(
                sessionExpiryInterval: UInt32? = nil,
                receiveMaximum: UInt16 = .max,
                maximumQoS: UInt8 = 2,
                retainAvailable: Bool = true,
                maximumPacketSize: UInt32? = nil,
                assignedClientIdentifier: String? = nil,
                topicAliasMaximum: UInt16 = 0,
                reasonString: String? = nil,
                userProperties: [String: String] = [:],
                wildcardSubscriptionAvailable: Bool = true,
                subscriptionIdentifiersAvailable: Bool = true,
                sharedSubscriptionAvailable: Bool = true,
                serverKeepAlive: UInt16? = nil,
                responseInformation: String? = nil,
                serverReference: String? = nil,
                authenticationMethod: String? = nil,
                authenticationData: Data? = nil
            ) {
            self.sessionExpiryInterval = sessionExpiryInterval
            self.receiveMaximum = receiveMaximum
            self.maximumQoS = maximumQoS
            self.retainAvailable = retainAvailable
            self.maximumPacketSize = maximumPacketSize
            self.assignedClientIdentifier = assignedClientIdentifier
            self.topicAliasMaximum = topicAliasMaximum
            self.reasonString = reasonString
            self.userProperties = userProperties
            self.wildcardSubscriptionAvailable = wildcardSubscriptionAvailable
            self.subscriptionIdentifiersAvailable = subscriptionIdentifiersAvailable
            self.sharedSubscriptionAvailable = sharedSubscriptionAvailable
            self.serverKeepAlive = serverKeepAlive
            self.responseInformation = responseInformation
            self.serverReference = serverReference
            self.authenticationMethod = authenticationMethod
            self.authenticationData = authenticationData
        }
        
        init(decoder: [UInt8]) throws {
            var sessionExpiryInterval: UInt32?
            var receiveMaximum: UInt16 = .max
            var maximumQoS: UInt8 = 2
            var retainAvailable: Bool = true
            var maximumPacketSize: UInt32?
            var assignedClientIdentifier: String?
            var topicAliasMaximum: UInt16 = 0
            var reasonString: String?
            var userProperties: [String: String] = [:]
            var wildcardSubscriptionAvailable: Bool = true
            var subscriptionIdentifiersAvailable: Bool = true
            var sharedSubscriptionAvailable: Bool = true
            var serverKeepAlive: UInt16?
            var responseInformation: String?
            var serverReference: String?
            var authenticationMethod: String?
            var authenticationData: Data?
            
            if decoder.count > 0 {
                
                let variableLength = try VariableByteInteger(from: decoder)
                if variableLength.value != decoder.count - variableLength.bytes.count {
                    throw PacketError.invalidPacket("Packet variable properties size invalid")
                }
                
                var isDecoded: [MQTTPropertyIdentifier: Bool] = [:]
                var currentIndex = variableLength.bytes.count
                
                while currentIndex < decoder.count {
                    if let property = try FourByteProperty(MQTTPropertyIdentifier.sessionExpiryInterval, decoder, startIndex: currentIndex) {
                        if isDecoded[property.identifier] == true {
                            throw PacketError.duplicateQuality("sessionExpiryInterval")
                        }
                        isDecoded[property.identifier] = true
                        
                        sessionExpiryInterval = property.value
                        currentIndex += property.propertyLength + 1
                    }
                    
                    if let property = try TwoByteProperty(MQTTPropertyIdentifier.receiveMaximum, decoder, startIndex: currentIndex) {
                        if isDecoded[property.identifier] == true {
                            throw PacketError.duplicateQuality("receiveMaximum")
                        }
                        isDecoded[property.identifier] = true
                        
                        receiveMaximum = property.value
                        currentIndex += property.propertyLength + 1
                    }
                    
                    if let property = try ByteProperty(MQTTPropertyIdentifier.maximumQoS, decoder, startIndex: currentIndex) {
                        if isDecoded[property.identifier] == true {
                            throw PacketError.duplicateQuality("maximumQoS")
                        }
                        isDecoded[property.identifier] = true
                        
                        maximumQoS = property.value
                        currentIndex += property.propertyLength + 1
                    }
                    
                    if let property = try ByteProperty(MQTTPropertyIdentifier.retainAvailable, decoder, startIndex: currentIndex) {
                        if isDecoded[property.identifier] == true {
                            throw PacketError.duplicateQuality("retainAvailable")
                        }
                        isDecoded[property.identifier] = true
                        
                        retainAvailable = property.value == 1
                        currentIndex += property.propertyLength + 1
                    }
                    
                    if let property = try FourByteProperty(MQTTPropertyIdentifier.maximumPacketSize, decoder, startIndex: currentIndex) {
                        if isDecoded[property.identifier] == true {
                            throw PacketError.duplicateQuality("maximumPacketSize")
                        }
                        isDecoded[property.identifier] = true
                        
                        maximumPacketSize = property.value
                        currentIndex += property.propertyLength + 1
                    }
                    
                    if let property = try StringProperty(MQTTPropertyIdentifier.assignClientIdentifier, decoder, startIndex: currentIndex) {
                        if isDecoded[property.identifier] == true {
                            throw PacketError.duplicateQuality("assignClientIdentifier")
                        }
                        isDecoded[property.identifier] = true
                        
                        assignedClientIdentifier = property.value
                        currentIndex += property.propertyLength + 1
                    }
                    
                    if let property = try TwoByteProperty(MQTTPropertyIdentifier.topicAliasMaximum, decoder, startIndex: currentIndex) {
                        if isDecoded[property.identifier] == true {
                            throw PacketError.duplicateQuality("topicAliasMaximum")
                        }
                        isDecoded[property.identifier] = true
                        
                        topicAliasMaximum = property.value
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
                        userProperties[property.key] = property.value
                        currentIndex += property.propertyLength + 1
                    }
                    
                    if let property = try ByteProperty(MQTTPropertyIdentifier.wildcardSubscriptionAvailable, decoder, startIndex: currentIndex) {
                        if isDecoded[property.identifier] == true {
                            throw PacketError.duplicateQuality("wildcardSubscriptionAvailable")
                        }
                        isDecoded[property.identifier] = true
                        
                        wildcardSubscriptionAvailable = property.value == 1
                        currentIndex += property.propertyLength + 1
                    }
                    
                    if let property = try ByteProperty(MQTTPropertyIdentifier.subscriptionIdentifierAvailable, decoder, startIndex: currentIndex) {
                        if isDecoded[property.identifier] == true {
                            throw PacketError.duplicateQuality("subscriptionIdentifierAvailable")
                        }
                        isDecoded[property.identifier] = true
                        
                        subscriptionIdentifiersAvailable = property.value == 1
                        currentIndex += property.propertyLength + 1
                    }
                    
                    if let property = try ByteProperty(MQTTPropertyIdentifier.sharedSubscriptionAvailable, decoder, startIndex: currentIndex) {
                        if isDecoded[property.identifier] == true {
                            throw PacketError.duplicateQuality("sharedSubscriptionAvailable")
                        }
                        isDecoded[property.identifier] = true
                        
                        sharedSubscriptionAvailable = property.value == 1
                        currentIndex += property.propertyLength + 1
                    }
                    
                    if let property = try TwoByteProperty(MQTTPropertyIdentifier.serverKeepAlive, decoder, startIndex: currentIndex) {
                        if isDecoded[property.identifier] == true {
                            throw PacketError.duplicateQuality("serverKeepAlive")
                        }
                        isDecoded[property.identifier] = true
                        
                        serverKeepAlive = property.value
                        currentIndex += property.propertyLength + 1
                    }
                    
                    if let property = try StringProperty(MQTTPropertyIdentifier.responseInformation, decoder, startIndex: currentIndex) {
                        if isDecoded[property.identifier] == true {
                            throw PacketError.duplicateQuality("responseInformation")
                        }
                        isDecoded[property.identifier] = true
                        
                        responseInformation = property.value
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
                }
            }
            
            self.sessionExpiryInterval = sessionExpiryInterval
            self.receiveMaximum = receiveMaximum
            self.maximumQoS = maximumQoS
            self.retainAvailable = retainAvailable
            self.maximumPacketSize = maximumPacketSize
            self.assignedClientIdentifier = assignedClientIdentifier
            self.topicAliasMaximum = topicAliasMaximum
            self.reasonString = reasonString
            self.userProperties = userProperties
            self.wildcardSubscriptionAvailable = wildcardSubscriptionAvailable
            self.subscriptionIdentifiersAvailable = subscriptionIdentifiersAvailable
            self.sharedSubscriptionAvailable = sharedSubscriptionAvailable
            self.serverKeepAlive = serverKeepAlive
            self.responseInformation = responseInformation
            self.serverReference = serverReference
            self.authenticationMethod = authenticationMethod
            self.authenticationData = authenticationData
        }
        
        func encode() throws -> [UInt8] {
            var bytes: [UInt8] = []
            
            if let property = sessionExpiryInterval {
                bytes.append(MQTTPropertyIdentifier.sessionExpiryInterval.rawValue)
                bytes.append(contentsOf: property.bytes)
            }
            
            bytes.append(MQTTPropertyIdentifier.receiveMaximum.rawValue)
            bytes.append(contentsOf: receiveMaximum.bytes)
            
            bytes.append(MQTTPropertyIdentifier.maximumQoS.rawValue)
            bytes.append(maximumQoS)
            
            bytes.append(MQTTPropertyIdentifier.retainAvailable.rawValue)
            bytes.append(retainAvailable ? 0x01 : 0x00)
            
            if let property = maximumPacketSize {
                bytes.append(MQTTPropertyIdentifier.maximumPacketSize.rawValue)
                bytes.append(contentsOf: property.bytes)
            }
            
            if let property = assignedClientIdentifier {
                bytes.append(MQTTPropertyIdentifier.assignClientIdentifier.rawValue)
                
                let utf8String = try MQTTUTF8String(property)
                bytes.append(contentsOf: utf8String.bytes)
            }
            
            bytes.append(MQTTPropertyIdentifier.topicAliasMaximum.rawValue)
            bytes.append(contentsOf: topicAliasMaximum.bytes)
            
            if let property = reasonString {
                bytes.append(MQTTPropertyIdentifier.reasonString.rawValue)
                
                let utf8String = try MQTTUTF8String(property)
                bytes.append(contentsOf: utf8String.bytes)
            }
            
            for property in userProperties {
                bytes.append(MQTTPropertyIdentifier.userProperty.rawValue)
                
                let keyValueUtf8 = try MQTTUTF8StringPair(property.key, property.value)
                bytes.append(contentsOf: keyValueUtf8.bytes)
            }
            
            bytes.append(MQTTPropertyIdentifier.wildcardSubscriptionAvailable.rawValue)
            bytes.append(wildcardSubscriptionAvailable ? 0x01 : 0x00)
            
            bytes.append(MQTTPropertyIdentifier.subscriptionIdentifierAvailable.rawValue)
            bytes.append(subscriptionIdentifiersAvailable ? 0x01 : 0x00)
            
            bytes.append(MQTTPropertyIdentifier.sharedSubscriptionAvailable.rawValue)
            bytes.append(sharedSubscriptionAvailable ? 0x01 : 0x00)
            
            if let property = serverKeepAlive {
                bytes.append(MQTTPropertyIdentifier.serverKeepAlive.rawValue)
                bytes.append(contentsOf: property.bytes)
            }
            
            if let property = responseInformation {
                bytes.append(MQTTPropertyIdentifier.responseInformation.rawValue)
                
                let utf8String = try MQTTUTF8String(property)
                bytes.append(contentsOf: utf8String.bytes)
            }
            
            if let property = serverReference {
                bytes.append(MQTTPropertyIdentifier.serverReference.rawValue)
                
                let utf8String = try MQTTUTF8String(property)
                bytes.append(contentsOf: utf8String.bytes)
            }
            
            if let authenticationMethod = self.authenticationMethod {
                bytes.append(MQTTPropertyIdentifier.authenticationMethod.rawValue)
                
                let utf8String = try MQTTUTF8String(authenticationMethod)
                bytes.append(contentsOf: utf8String.bytes)
            }
            
            if let authenticationData = self.authenticationData {
                bytes.append(MQTTPropertyIdentifier.authenticationData.rawValue)
                let utf8 = try MQTTData(authenticationData)
                bytes.append(contentsOf: utf8.bytes)
            }
            
            let propertyLength = VariableByteInteger(UInt32(bytes.count))
            return propertyLength.bytes + bytes
        }
    }
}



