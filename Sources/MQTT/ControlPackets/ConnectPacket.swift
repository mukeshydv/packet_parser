//
//  ConnectPacket.swift
//  MQTT
//
//  Created by Mukesh on 25/01/19.
//

import Foundation

enum ConnectPacketError: Error {
    case invalidPacket(String)
    case quality(String)
    case duplicateQuality(String)
}

public struct ConnectPacketQualities {
    let sessionExpiryInterval: UInt32
    let receiveMaximum: UInt16
    let maximumPacketSize: UInt32
    let topicAliasMaximum: UInt16
    let requestResponseInformation: UInt8
    let requestProblemInformation: UInt8
    let userProperty: [(key: String, value: String)]
    let authenticationMethod: String?
    let authenticationData: Data?
    
    public init(
        sessionExpiryInterval: UInt32 = 0,
        receiveMaximum: UInt16 = .max,
        maximumPacketSize: UInt32 = .max,
        topicAliasMaximum: UInt16 = 0,
        requestResponseInformation: UInt8 = 0,
        requestProblemInformation: UInt8 = 1,
        userProperty: [(String, String)] = [],
        authenticationMethod: String? = nil,
        authenticationData: Data? = nil
        ) {
        self.sessionExpiryInterval = sessionExpiryInterval
        self.receiveMaximum = receiveMaximum
        self.maximumPacketSize = maximumPacketSize
        self.topicAliasMaximum = topicAliasMaximum
        self.requestResponseInformation = requestResponseInformation
        self.requestProblemInformation = requestProblemInformation
        self.userProperty = userProperty
        self.authenticationMethod = authenticationMethod
        self.authenticationData = authenticationData
    }
    
    init(decoder: [UInt8]) throws {
        var sessionExpiryInterval: UInt32 = 0
        var receiveMaximum: UInt16 = .max
        var maximumPacketSize: UInt32 = .max
        var topicAliasMaximum: UInt16 = 0
        var requestResponseInformation: UInt8 = 0
        var requestProblemInformation: UInt8 = 1
        var userProperty: [(String, String)] = []
        var authenticationMethod: String? = nil
        var authenticationData: Data? = nil
        
        var isDecoded: [PropertyIdentifier: Bool] = [:]
        
        var currentIndex = 0
        
        while currentIndex < decoder.count {
            if decoder[currentIndex] == PropertyIdentifier.sessionExpiryInterval.rawValue {
                if isDecoded[.sessionExpiryInterval] == true {
                    throw ConnectPacketError.duplicateQuality("sessionExpiryInterval")
                }
                isDecoded[.sessionExpiryInterval] = true
                
                guard currentIndex + 4 < decoder.count else {
                    // Error decoding
                    throw ConnectPacketError.quality("sessionExpiryInterval value not available")
                }
                
                sessionExpiryInterval = UInt32(
                    decoder[currentIndex+1],
                    decoder[currentIndex+2],
                    decoder[currentIndex+3],
                    decoder[currentIndex+4]
                )
                
                currentIndex += 5
            }
            
            if currentIndex < decoder.count && decoder[currentIndex] == PropertyIdentifier.receiveMaximum.rawValue {
                if isDecoded[.receiveMaximum] == true {
                    throw ConnectPacketError.duplicateQuality("receiveMaximum")
                }
                isDecoded[.receiveMaximum] = true
                
                guard currentIndex + 2 < decoder.count else {
                    // Error decoding
                    throw ConnectPacketError.quality("receiveMaximum value not available")
                }
                
                receiveMaximum = UInt16(decoder[currentIndex+1], decoder[currentIndex+2])
                currentIndex += 3
            }
            
            if currentIndex < decoder.count && decoder[currentIndex] == PropertyIdentifier.maximumPacketSize.rawValue {
                if isDecoded[.maximumPacketSize] == true {
                    throw ConnectPacketError.duplicateQuality("maximumPacketSize")
                }
                isDecoded[.maximumPacketSize] = true
                
                guard currentIndex + 4 < decoder.count else {
                    // Error decoding
                    throw ConnectPacketError.quality("maximumPacketSize value not available")
                }
                
                maximumPacketSize = UInt32(
                    decoder[currentIndex+1],
                    decoder[currentIndex+2],
                    decoder[currentIndex+3],
                    decoder[currentIndex+4]
                )
                
                currentIndex += 5
            }
            
            if currentIndex < decoder.count && decoder[currentIndex] == PropertyIdentifier.topicAliasMaximum.rawValue {
                if isDecoded[.topicAliasMaximum] == true {
                    throw ConnectPacketError.duplicateQuality("topicAliasMaximum")
                }
                isDecoded[.topicAliasMaximum] = true
                
                guard currentIndex + 2 < decoder.count else {
                    // Error decoding
                    throw ConnectPacketError.quality("topicAliasMaximum value not available")
                }
                
                topicAliasMaximum = UInt16(decoder[currentIndex+1], decoder[currentIndex+2])
                currentIndex += 3
            }
            
            if currentIndex < decoder.count && decoder[currentIndex] == PropertyIdentifier.requestResponseInformation.rawValue {
                if isDecoded[.requestResponseInformation] == true {
                    throw ConnectPacketError.duplicateQuality("requestResponseInformation")
                }
                isDecoded[.requestResponseInformation] = true
                
                guard currentIndex + 1 < decoder.count else {
                    // Error decoding
                    throw ConnectPacketError.quality("requestResponseInformation value not available")
                }
                
                requestResponseInformation = decoder[currentIndex+1]
                currentIndex += 2
            }
            
            if currentIndex < decoder.count && decoder[currentIndex] == PropertyIdentifier.requestProblemInformation.rawValue {
                if isDecoded[.requestProblemInformation] == true {
                    throw ConnectPacketError.duplicateQuality("requestProblemInformation")
                }
                isDecoded[.requestProblemInformation] = true
                
                guard currentIndex + 1 < decoder.count else {
                    // Error decoding
                    throw ConnectPacketError.quality("requestProblemInformation value not available")
                }
                
                requestProblemInformation = decoder[currentIndex+1]
                currentIndex += 2
            }
            
            while currentIndex < decoder.count && decoder[currentIndex] == PropertyIdentifier.userProperty.rawValue {
                let startIndex = UInt32(currentIndex + 1)
                let utf8Pair = try MQTTUTF8StringPair(from: decoder, startIndex: startIndex)
                userProperty.append((key: utf8Pair.key, value: utf8Pair.value))
                
                currentIndex += Int(utf8Pair.keyLength) + Int(utf8Pair.valueLength) + 5
            }
            
            if currentIndex < decoder.count && decoder[currentIndex] == PropertyIdentifier.authenticationMethod.rawValue {
                if isDecoded[.authenticationMethod] == true {
                    throw ConnectPacketError.duplicateQuality("authenticationMethod")
                }
                isDecoded[.authenticationMethod] = true
                
                let startIndex = UInt32(currentIndex + 1)
                let utf8String = try MQTTUTF8String(from: decoder, startIndex: startIndex)
                authenticationMethod = utf8String.value
                
                currentIndex += Int(utf8String.length) + 3
            }
            
            if currentIndex < decoder.count && decoder[currentIndex] == PropertyIdentifier.authenticationData.rawValue {
                if isDecoded[.authenticationData] == true {
                    throw ConnectPacketError.duplicateQuality("authenticationData")
                }
                isDecoded[.authenticationData] = true
                
                let startIndex = UInt32(currentIndex + 1)
                let data = try MQTTData(from: decoder, startIndex: startIndex)
                authenticationData = data.value
                
                currentIndex += Int(data.length) + 3
            }
        }
        
        
        
        self.init(
            sessionExpiryInterval: sessionExpiryInterval,
            receiveMaximum: receiveMaximum,
            maximumPacketSize: maximumPacketSize,
            topicAliasMaximum: topicAliasMaximum,
            requestResponseInformation: requestResponseInformation,
            requestProblemInformation: requestProblemInformation,
            userProperty: userProperty,
            authenticationMethod: authenticationMethod,
            authenticationData: authenticationData
        )
    }
    
    func encode() throws -> [UInt8] {
        var bytes: [UInt8] = []
        
        bytes.append(PropertyIdentifier.sessionExpiryInterval.rawValue)
        bytes.append(contentsOf: sessionExpiryInterval.bytes)
        
        bytes.append(PropertyIdentifier.receiveMaximum.rawValue)
        bytes.append(contentsOf: receiveMaximum.bytes)
        
        bytes.append(PropertyIdentifier.maximumPacketSize.rawValue)
        bytes.append(contentsOf: maximumPacketSize.bytes)
        
        bytes.append(PropertyIdentifier.topicAliasMaximum.rawValue)
        bytes.append(contentsOf: topicAliasMaximum.bytes)
        
        bytes.append(PropertyIdentifier.requestResponseInformation.rawValue)
        bytes.append(requestResponseInformation)
        
        bytes.append(PropertyIdentifier.requestProblemInformation.rawValue)
        bytes.append(requestProblemInformation)
        
        for property in userProperty {
            bytes.append(PropertyIdentifier.userProperty.rawValue)
            
            let keyValueUtf8 = try MQTTUTF8StringPair(property.key, property.value)
            bytes.append(contentsOf: keyValueUtf8.bytes)
        }
        
        if let authenticationMethod = self.authenticationMethod {
            bytes.append(PropertyIdentifier.authenticationMethod.rawValue)
            
            let utf8String = try MQTTUTF8String(authenticationMethod)
            bytes.append(contentsOf: utf8String.bytes)
        }
        
        if let authenticationData = self.authenticationData {
            bytes.append(PropertyIdentifier.authenticationData.rawValue)
            bytes.append(contentsOf: authenticationData.bytes)
        }
        
        return bytes
    }
}

public struct ConnectPacket {
    let protocolName: String
    let username: Bool
    let password: Bool
    let willRetain: Bool
    let willQos: UInt8
    let willMessage: Bool
    let cleanStart: Bool
    let keepAlive: UInt16
    let properties: ConnectPacketQualities
    
    public init(protocolName: String = "MQTT",
                username: Bool = false,
                password: Bool = false,
                willRetain: Bool = false,
                willQos: UInt8,
                willMessage: Bool = false,
                cleanStart: Bool = false,
                keepAlive: UInt16 = 0,
                properties: ConnectPacketQualities = ConnectPacketQualities()
        ) {
        self.protocolName = protocolName
        self.username = username
        self.password = password
        self.willRetain = willRetain
        self.willQos = willQos
        self.willMessage = willMessage
        self.cleanStart = cleanStart
        self.keepAlive = keepAlive
        self.properties = properties
    }
    
    init(decoder: [UInt8]) throws {
        if decoder.count == 0 {
            throw ConnectPacketError.invalidPacket("Zero size packet")
        }
        
        if decoder[0] != 0x10 {
            throw ConnectPacketError.invalidPacket("Packet fixed header")
        }
        
        let variableHeaderLength = try VariableByteInteger(from: decoder, startIndex: 1)
        if variableHeaderLength.value + 1 != decoder.count - variableHeaderLength.bytes.count {
            throw ConnectPacketError.invalidPacket("Packet variable header size invalid")
        }
        
        var currentIndex = variableHeaderLength.bytes.count + 1
        let protocolName = try MQTTUTF8String(from: decoder, startIndex: UInt32(currentIndex))
        self.protocolName = protocolName.value
        
        currentIndex += Int(protocolName.length) + 2
        
        guard currentIndex < decoder.count else {
            throw ConnectPacketError.invalidPacket("Protocol version not found")
        }
        
        if decoder[currentIndex] != 0x05 {
            throw ConnectPacketError.invalidPacket("invalid protocol version, only version 5 is supported")
        }
        
        currentIndex += 1
        
        guard currentIndex < decoder.count else {
            throw ConnectPacketError.invalidPacket("packet flags not found")
        }
        
        let flags = decoder[currentIndex]
        
        cleanStart = flags & 0x02 == 0x02
        willMessage = flags & 0x04 == 0x04
        willQos = (flags & 0x18) >> 3
        willRetain = flags & 0x20 == 0x20
        username = flags & 0x80 == 0x80
        password = flags & 0x40 == 0x40

        
        guard currentIndex + 2 < decoder.count else {
            throw ConnectPacketError.invalidPacket("keep alive not found")
        }
        
        keepAlive = UInt16(decoder[currentIndex+1], decoder[currentIndex+2])
        
        currentIndex += 3
        
        guard currentIndex < decoder.count else {
            throw ConnectPacketError.invalidPacket("properties not found")
        }
        
        var propertiesByte = decoder.dropFirst(currentIndex).map { $0 }
        
        let variablePropertiesLength = try VariableByteInteger(from: propertiesByte, startIndex: 0)
        if variablePropertiesLength.value != propertiesByte.count - variableHeaderLength.bytes.count {
            throw ConnectPacketError.invalidPacket("Properties Length invalid")
        }
        
        propertiesByte = propertiesByte.dropFirst(variableHeaderLength.bytes.count).map { $0 }
        properties = try ConnectPacketQualities(decoder: propertiesByte)
    }
    
    func encode() throws -> [UInt8] {
        let variableHeaders = try encodeVariableHeader()
        let remainingLength = VariableByteInteger(UInt32(variableHeaders.count))
        return [0x10] // Fixed Header
            + remainingLength.bytes // Remaining length
            + variableHeaders // Headers
    }
    
    private func encodeVariableHeader() throws -> [UInt8] {
        let encodedProperties = try properties.encode()
        let propertyLength = VariableByteInteger(UInt32(encodedProperties.count))
        
        let protocolName = try MQTTUTF8String(self.protocolName)
        
        var bytes: [UInt8] = protocolName.bytes // Protocol name
        bytes.append(0x05) // Protocol version (current 5)
        bytes.append(encodeFlags)
        bytes.append(contentsOf: keepAlive.bytes)
        bytes.append(contentsOf: propertyLength.bytes)
        bytes.append(contentsOf: encodedProperties)
        
        return bytes
    }
    
    private var encodeFlags: UInt8 {
        let cleanStartBit: UInt8 = cleanStart ? 0x02 : 0x00
        let willFlag: UInt8 = willMessage ? 0x04 : 0x00
        let willQosBit: UInt8 = willQos << 3
        let willRetainBit: UInt8 = willRetain ? 0x20 : 0x00
        let usernameBit: UInt8 = username ? 0x80 : 0x00
        let passwordBit: UInt8 = password ? 0x40 : 0x00
        
        return cleanStartBit | willFlag | willQosBit | willRetainBit | usernameBit | passwordBit
    }
}
