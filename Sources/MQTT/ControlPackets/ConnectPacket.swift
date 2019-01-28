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
    case payloadError(String)
}

public struct ConnectPacketQualities {
    let sessionExpiryInterval: UInt32
    let receiveMaximum: UInt16
    let maximumPacketSize: UInt32
    let topicAliasMaximum: UInt16
    let requestResponseInformation: UInt8
    let requestProblemInformation: UInt8
    let userProperty: [String: String]
    let authenticationMethod: String?
    let authenticationData: Data?
    
    public init(
        sessionExpiryInterval: UInt32 = 0,
        receiveMaximum: UInt16 = .max,
        maximumPacketSize: UInt32 = .max,
        topicAliasMaximum: UInt16 = 0,
        requestResponseInformation: UInt8 = 0,
        requestProblemInformation: UInt8 = 1,
        userProperty: [String: String] = [:],
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
        var userProperty: [String: String] = [:]
        var authenticationMethod: String? = nil
        var authenticationData: Data? = nil
        
        var isDecoded: [MQTTPropertyIdentifier: Bool] = [:]
        
        var currentIndex = 0
        
        while currentIndex < decoder.count {
            if let property = try FourByteProperty(MQTTPropertyIdentifier.sessionExpiryInterval, decoder, startIndex: currentIndex) {
                if isDecoded[property.identifier] == true {
                    throw ConnectPacketError.duplicateQuality("sessionExpiryInterval")
                }
                isDecoded[property.identifier] = true
                
                sessionExpiryInterval = property.value
                currentIndex += property.propertyLength + 1
            }
            
            if let property = try TwoByteProperty(MQTTPropertyIdentifier.receiveMaximum, decoder, startIndex: currentIndex) {
                if isDecoded[property.identifier] == true {
                    throw ConnectPacketError.duplicateQuality("receiveMaximum")
                }
                isDecoded[property.identifier] = true
                
                receiveMaximum = property.value
                currentIndex += property.propertyLength + 1
            }
            
            if let property = try FourByteProperty(MQTTPropertyIdentifier.maximumPacketSize, decoder, startIndex: currentIndex) {
                if isDecoded[property.identifier] == true {
                    throw ConnectPacketError.duplicateQuality("maximumPacketSize")
                }
                isDecoded[property.identifier] = true
                
                maximumPacketSize = property.value
                currentIndex += property.propertyLength + 1
            }
            
            if let property = try TwoByteProperty(MQTTPropertyIdentifier.topicAliasMaximum, decoder, startIndex: currentIndex) {
                if isDecoded[property.identifier] == true {
                    throw ConnectPacketError.duplicateQuality("topicAliasMaximum")
                }
                isDecoded[property.identifier] = true
                
                topicAliasMaximum = property.value
                currentIndex += property.propertyLength + 1
            }
            
            if let property = try ByteProperty(MQTTPropertyIdentifier.requestResponseInformation, decoder, startIndex: currentIndex) {
                if isDecoded[property.identifier] == true {
                    throw ConnectPacketError.duplicateQuality("requestResponseInformation")
                }
                isDecoded[property.identifier] = true
                
                requestResponseInformation = property.value
                currentIndex += property.propertyLength + 1
            }
            
            if let property = try ByteProperty(MQTTPropertyIdentifier.requestProblemInformation, decoder, startIndex: currentIndex) {
                if isDecoded[property.identifier] == true {
                    throw ConnectPacketError.duplicateQuality("requestProblemInformation")
                }
                isDecoded[property.identifier] = true
                
                requestProblemInformation = property.value
                currentIndex += property.propertyLength + 1
            }
            
            while let property = try StringPairProperty(MQTTPropertyIdentifier.userProperty, decoder, startIndex: currentIndex) {
                userProperty[property.key] = property.value
                currentIndex += property.propertyLength + 1
            }
            
            if let property = try StringProperty(MQTTPropertyIdentifier.authenticationMethod, decoder, startIndex: currentIndex) {
                if isDecoded[.authenticationMethod] == true {
                    throw ConnectPacketError.duplicateQuality("authenticationMethod")
                }
                isDecoded[.authenticationMethod] = true
                
                authenticationMethod = property.value
                currentIndex += property.propertyLength + 1
            }
            
            if let property = try DataProperty(MQTTPropertyIdentifier.authenticationData, decoder, startIndex: currentIndex) {
                if isDecoded[.authenticationData] == true {
                    throw ConnectPacketError.duplicateQuality("authenticationData")
                }
                isDecoded[.authenticationData] = true
                
                authenticationData = property.value
                currentIndex += property.propertyLength + 1
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
        
        bytes.append(MQTTPropertyIdentifier.sessionExpiryInterval.rawValue)
        bytes.append(contentsOf: sessionExpiryInterval.bytes)
        
        bytes.append(MQTTPropertyIdentifier.receiveMaximum.rawValue)
        bytes.append(contentsOf: receiveMaximum.bytes)
        
        bytes.append(MQTTPropertyIdentifier.maximumPacketSize.rawValue)
        bytes.append(contentsOf: maximumPacketSize.bytes)
        
        bytes.append(MQTTPropertyIdentifier.topicAliasMaximum.rawValue)
        bytes.append(contentsOf: topicAliasMaximum.bytes)
        
        bytes.append(MQTTPropertyIdentifier.requestResponseInformation.rawValue)
        bytes.append(requestResponseInformation)
        
        bytes.append(MQTTPropertyIdentifier.requestProblemInformation.rawValue)
        bytes.append(requestProblemInformation)
        
        for property in userProperty {
            bytes.append(MQTTPropertyIdentifier.userProperty.rawValue)
            
            let keyValueUtf8 = try MQTTUTF8StringPair(property.key, property.value)
            bytes.append(contentsOf: keyValueUtf8.bytes)
        }
        
        if let authenticationMethod = self.authenticationMethod {
            bytes.append(MQTTPropertyIdentifier.authenticationMethod.rawValue)
            
            let utf8String = try MQTTUTF8String(authenticationMethod)
            bytes.append(contentsOf: utf8String.bytes)
        }
        
        if let authenticationData = self.authenticationData {
            bytes.append(MQTTPropertyIdentifier.authenticationData.rawValue)
            bytes.append(contentsOf: authenticationData.bytes)
        }
        
        return bytes
    }
}

public struct ConnectPacketFlag {
    let username: Bool
    let password: Bool
    let willRetain: Bool
    let willQos: UInt8
    let willFlag: Bool
    let cleanStart: Bool
    
    public init(
        username: Bool = false,
        password: Bool = false,
        willRetain: Bool = false,
        willQos: UInt8 = 0,
        willFlag: Bool = false,
        cleanStart: Bool = false
        ) {
        self.username = username
        self.password = password
        self.willRetain = willRetain
        self.willQos = willQos
        self.willFlag = willFlag
        self.cleanStart = cleanStart
    }
    
    init(decoder: UInt8) {
        cleanStart = decoder & 0x02 == 0x02
        willFlag = decoder & 0x04 == 0x04
        willQos = (decoder & 0x18) >> 3
        willRetain = decoder & 0x20 == 0x20
        username = decoder & 0x80 == 0x80
        password = decoder & 0x40 == 0x40
    }
    
    func encode() -> UInt8 {
        let cleanStartBit: UInt8 = cleanStart ? 0x02 : 0x00
        let willFlagBit: UInt8 = willFlag ? 0x04 : 0x00
        let willQosBit: UInt8 = willQos << 3
        let willRetainBit: UInt8 = willRetain ? 0x20 : 0x00
        let usernameBit: UInt8 = username ? 0x80 : 0x00
        let passwordBit: UInt8 = password ? 0x40 : 0x00
        
        return cleanStartBit | willFlagBit | willQosBit | willRetainBit | usernameBit | passwordBit
    }
}

public struct ConnectPacket {
    let protocolName: String
    let flags: ConnectPacketFlag
    let keepAlive: UInt16
    let properties: ConnectPacketQualities
    let payload: ConnectPayload
    
    public init(protocolName: String = "MQTT",
                flags: ConnectPacketFlag = ConnectPacketFlag(),
                keepAlive: UInt16 = 0,
                properties: ConnectPacketQualities = ConnectPacketQualities(),
                payload: ConnectPayload
        ) {
        self.protocolName = protocolName
        self.flags = flags
        self.keepAlive = keepAlive
        self.properties = properties
        self.payload = payload
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
        self.flags = ConnectPacketFlag(decoder: flags)
        
        guard currentIndex + 2 < decoder.count else {
            throw ConnectPacketError.invalidPacket("keep alive not found")
        }
        
        keepAlive = UInt16(decoder[currentIndex+1], decoder[currentIndex+2])
        
        currentIndex += 3
        
        guard currentIndex < decoder.count else {
            throw ConnectPacketError.invalidPacket("properties not found")
        }
        
        let variablePropertiesLength = try VariableByteInteger(from: decoder, startIndex: currentIndex)

        currentIndex += variablePropertiesLength.bytes.count
        
        let propertyEndIndex = currentIndex + Int(variablePropertiesLength.value)
        guard propertyEndIndex <= decoder.count else {
            throw ConnectPacketError.invalidPacket("Properties Length invalid")
        }
        
        let propertiesByte = decoder[currentIndex..<propertyEndIndex].map { $0 }
        properties = try ConnectPacketQualities(decoder: propertiesByte)
        
        currentIndex = propertyEndIndex
        
        guard propertyEndIndex < decoder.count else {
            throw ConnectPacketError.invalidPacket("payload not found")
        }
        
        let payloadBytes = decoder.dropFirst(currentIndex).map { $0 }
        payload = try ConnectPayload(decoder: payloadBytes, headerFlags: self.flags)
    }
    
    func encode() throws -> [UInt8] {
        let variableHeaders = try encodeVariableHeader()
        let encodedPayload = try payload.encode()
        
        let remainingLength = VariableByteInteger(UInt32(variableHeaders.count + encodedPayload.count))
        
        return [0x10] // Fixed Header
            + remainingLength.bytes // Remaining length
            + variableHeaders // Headers
            + encodedPayload // Payload
    }
    
    private func encodeVariableHeader() throws -> [UInt8] {
        let encodedProperties = try properties.encode()
        let propertyLength = VariableByteInteger(UInt32(encodedProperties.count))
        
        let protocolName = try MQTTUTF8String(self.protocolName)
        
        var bytes: [UInt8] = protocolName.bytes // Protocol name
        bytes.append(0x05) // Protocol version (current 5)
        bytes.append(flags.encode())
        bytes.append(contentsOf: keepAlive.bytes)
        bytes.append(contentsOf: propertyLength.bytes)
        bytes.append(contentsOf: encodedProperties)
        
        return bytes
    }
}

public struct ConnectPayload {
    let clientId: String
    let willProperties: WillProperties?
    let willTopic: String?
    let willPayload: Data?
    let username: String?
    let password: Data?
    
    init(
        clientId: String,
        willProperties: WillProperties? = nil,
        willTopic: String? = nil,
        willPayload: Data? = nil,
        username: String? = nil,
        password: Data? = nil
        ) {
        self.clientId = clientId
        self.willProperties = willProperties
        self.willTopic = willTopic
        self.willPayload = willPayload
        self.username = username
        self.password = password
    }
    
    init(decoder: [UInt8], headerFlags: ConnectPacketFlag) throws {
        var currentIndex = 0
        
        let clientIdUtf = try MQTTUTF8String(from: decoder)
        clientId = clientIdUtf.value
        
        var willProperties: WillProperties? = nil
        var willTopic: String? = nil
        var willPayload: Data? = nil
        var username: String? = nil
        var password: Data? = nil
        
        currentIndex += Int(clientIdUtf.length) + 2
        
        if headerFlags.willFlag {
            guard currentIndex < decoder.count else {
                throw ConnectPacketError.payloadError("no will properties")
            }
            
            let willBytes = decoder.dropFirst(currentIndex).map { $0 }
            willProperties = try WillProperties(decoder: willBytes)
            
            currentIndex += Int(willProperties!.length)
            
            if currentIndex < decoder.count {
                let willTopicUtf = try MQTTUTF8String(from: decoder, startIndex: UInt32(currentIndex))
                willTopic = willTopicUtf.value
                
                currentIndex += Int(willTopicUtf.length) + 2
            }
            
            if currentIndex < decoder.count {
                let willPayloadUtf = try MQTTData(from: decoder, startIndex: UInt32(currentIndex))
                willPayload = willPayloadUtf.value
                
                currentIndex += Int(willPayloadUtf.length) + 2
            }
        }
        
        if headerFlags.username {
            guard currentIndex < decoder.count else {
                throw ConnectPacketError.payloadError("no username in payload")
            }
            
            let willUsernameUtf = try MQTTUTF8String(from: decoder, startIndex: UInt32(currentIndex))
            username = willUsernameUtf.value
            
            currentIndex += Int(willUsernameUtf.length) + 2
        }
        
        if headerFlags.password {
            guard currentIndex < decoder.count else {
                throw ConnectPacketError.payloadError("no password in payload")
            }
            
            let willPasswordUtf = try MQTTData(from: decoder, startIndex: UInt32(currentIndex))
            password = willPasswordUtf.value
            
            currentIndex += Int(willPasswordUtf.length) + 2
        }
        
        self.willProperties = willProperties
        self.willTopic = willTopic
        self.willPayload = willPayload
        self.username = username
        self.password = password
    }
    
    func encode() throws -> [UInt8] {
        var bytes: [UInt8] = []
        
        let clientIdUtf8 = try MQTTUTF8String(clientId)
        bytes.append(contentsOf: clientIdUtf8.bytes)
        
        if let willProperties = willProperties {
            bytes.append(contentsOf: try willProperties.encode())
        }
        
        if let willTopic = willTopic {
            let willTopicUtf8 = try MQTTUTF8String(willTopic)
            bytes.append(contentsOf: willTopicUtf8.bytes)
        }
        
        if let willPayload = willPayload {
            let willPayloadData = try MQTTData(willPayload)
            bytes.append(contentsOf: willPayloadData.bytes)
        }
        
        if let username = username {
            let usernameUtf8 = try MQTTUTF8String(username)
            bytes.append(contentsOf: usernameUtf8.bytes)
        }
        
        if let password = password {
            let passwordUtf8 = try MQTTData(password)
            bytes.append(contentsOf: passwordUtf8.bytes)
        }
        
        return bytes
    }
}

public struct WillProperties {
    let delayInterval: UInt32
    let payloadFormatIndicator: UInt8
    let messageExpiryInterval: UInt32?
    let contentType: String?
    let responseTopic: String?
    let correlationData: Data?
    let userProperty: [String: String]?
    
    let length: UInt32
    
    init(
        delayInterval: UInt32 = 0,
        payloadFormatIndicator: UInt8 = 0,
        messageExpiryInterval: UInt32? = nil,
        contentType: String? = nil,
        responseTopic: String? = nil,
        correlationData: Data? = nil,
        userProperty: [String: String]? = nil
        ) {
        self.delayInterval = delayInterval
        self.payloadFormatIndicator = payloadFormatIndicator
        self.messageExpiryInterval = messageExpiryInterval
        self.contentType = contentType
        self.responseTopic = responseTopic
        self.correlationData = correlationData
        self.userProperty = userProperty
        self.length = 0
    }
    
    init(decoder: [UInt8]) throws {
        
        var delayInterval: UInt32 = 0
        var payloadFormatIndicator: UInt8 = 0
        var messageExpiryInterval: UInt32? = nil
        var contentType: String? = nil
        var responseTopic: String? = nil
        var correlationData: Data? = nil
        var userProperty: [String: String] = [:]
        
        let lengthVariable = try VariableByteInteger(from: decoder)
        guard decoder.count - lengthVariable.bytes.count >= lengthVariable.value else {
            throw ConnectPacketError.payloadError("Length do not match")
        }
        
        self.length = lengthVariable.value + UInt32(lengthVariable.bytes.count)
        
        var isDecoded: [MQTTPropertyIdentifier: Bool] = [:]
        var currentIndex = lengthVariable.bytes.count
        
        while currentIndex < length {
            
            if let property = try FourByteProperty(MQTTPropertyIdentifier.willDelayInterval, decoder, startIndex: currentIndex) {
                if isDecoded[property.identifier] == true {
                    throw ConnectPacketError.payloadError("willDelayInterval")
                }
                isDecoded[property.identifier] = true
                
                delayInterval = property.value
                currentIndex += property.propertyLength + 1
            }
            
            if let property = try ByteProperty(MQTTPropertyIdentifier.payloadFormatIndicator, decoder, startIndex: currentIndex) {
                if isDecoded[property.identifier] == true {
                    throw ConnectPacketError.payloadError("payloadFormatIndicator")
                }
                isDecoded[property.identifier] = true
                
                payloadFormatIndicator = property.value
                currentIndex += property.propertyLength + 1
            }
            
            if let property = try FourByteProperty(MQTTPropertyIdentifier.messageExpiryInterval, decoder, startIndex: currentIndex) {
                if isDecoded[property.identifier] == true {
                    throw ConnectPacketError.payloadError("messageExpiryInterval")
                }
                isDecoded[property.identifier] = true
                
                messageExpiryInterval = property.value
                currentIndex += property.propertyLength + 1
            }
            
            if let property = try StringProperty(MQTTPropertyIdentifier.contentType, decoder, startIndex: currentIndex) {
                if isDecoded[property.identifier] == true {
                    throw ConnectPacketError.payloadError("contentType")
                }
                isDecoded[property.identifier] = true
                
                contentType = property.value
                currentIndex += property.propertyLength + 1
            }
            
            if let property = try StringProperty(MQTTPropertyIdentifier.responseTopic, decoder, startIndex: currentIndex) {
                if isDecoded[property.identifier] == true {
                    throw ConnectPacketError.payloadError("responseTopic")
                }
                isDecoded[property.identifier] = true
                
                responseTopic = property.value
                currentIndex += property.propertyLength + 1
            }
            
            if let property = try DataProperty(MQTTPropertyIdentifier.correlationData, decoder, startIndex: currentIndex) {
                if isDecoded[property.identifier] == true {
                    throw ConnectPacketError.duplicateQuality("correlationData")
                }
                isDecoded[property.identifier] = true
                
                correlationData = property.value
                currentIndex += property.propertyLength + 1
            }
            
            while let property = try StringPairProperty(MQTTPropertyIdentifier.userProperty, decoder, startIndex: currentIndex) {
                userProperty[property.key] = property.value
                currentIndex += property.propertyLength + 1
            }
        }
        
        self.delayInterval = delayInterval
        self.payloadFormatIndicator = payloadFormatIndicator
        self.messageExpiryInterval = messageExpiryInterval
        self.contentType = contentType
        self.responseTopic = responseTopic
        self.correlationData = correlationData
        self.userProperty = userProperty
        
    }
    
    func encode() throws -> [UInt8] {
        var bytes: [UInt8] = []
        
        bytes.append(MQTTPropertyIdentifier.willDelayInterval.rawValue)
        bytes.append(contentsOf: delayInterval.bytes)
        
        bytes.append(MQTTPropertyIdentifier.payloadFormatIndicator.rawValue)
        bytes.append(payloadFormatIndicator)
        
        if let property = messageExpiryInterval {
            bytes.append(MQTTPropertyIdentifier.messageExpiryInterval.rawValue)
            bytes.append(contentsOf: property.bytes)
        }
        
        if let property = contentType {
            bytes.append(MQTTPropertyIdentifier.contentType.rawValue)
            let utf8 = try MQTTUTF8String(property)
            bytes.append(contentsOf: utf8.bytes)
        }
        
        if let property = responseTopic {
            bytes.append(MQTTPropertyIdentifier.responseTopic.rawValue)
            let utf8 = try MQTTUTF8String(property)
            bytes.append(contentsOf: utf8.bytes)
        }
        
        if let property = correlationData {
            bytes.append(MQTTPropertyIdentifier.correlationData.rawValue)
            let utf8 = try MQTTData(property)
            bytes.append(contentsOf: utf8.bytes)
        }
        
        if let property = userProperty {
            for prop in property {
                bytes.append(MQTTPropertyIdentifier.userProperty.rawValue)
                let utf8 = try MQTTUTF8StringPair(prop.key, prop.value)
                bytes.append(contentsOf: utf8.bytes)
            }
        }
        
        let propertyLength = VariableByteInteger(UInt32(bytes.count))
        return propertyLength.bytes + bytes
    }
}
