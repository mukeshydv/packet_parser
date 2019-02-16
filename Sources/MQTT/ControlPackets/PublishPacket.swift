//
//  PublishPacket.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct PublishPacket: MQTTPacketCodable {
    
    let dup: Bool
    let qos: UInt8
    let retain: Bool
    let header: Header
    let payload: Data?
    
    let fixedHeader: MQTTPacketFixedHeader
    
    init(dup: Bool, qos: UInt8, retain: Bool, header: Header, payload: Data? = nil) {
        self.dup = dup
        self.qos = qos
        self.retain = retain
        self.header = header
        self.payload = payload
        
        let flag = (dup ? 0x08 : 0x00) | (retain ? 0x01 : 00) | qos
        self.fixedHeader = MQTTPacketFixedHeader(packetType: .PUBLISH, flags: flag)
    }
    
    init?(decoder: [UInt8]) throws {
        if decoder.count == 0 {
            return nil
        }
        
        fixedHeader = MQTTPacketFixedHeader(networkByte: decoder[0])
        
        if fixedHeader.packetType != .PUBLISH {
            return nil
        }
        
        dup = fixedHeader.flags & 0x08 == 1
        retain = fixedHeader.flags & 0x01 == 1
        qos = (fixedHeader.flags & 0x06) >> 1
        
        let variableHeaderLength = try VariableByteInteger(from: decoder, startIndex: 1)
        if variableHeaderLength.value + 1 != decoder.count - variableHeaderLength.bytes.count {
            throw PacketError.invalidPacket("Packet variable header size invalid")
        }
        
        let currentIndex = variableHeaderLength.bytes.count + 1
        let remainingBytes = decoder.dropFirst(currentIndex).map { $0 }
        
        var payload: Data?
        if let header = try Header(decoder: remainingBytes, qos: qos) {
            self.header = header
            
            let payloadBytes = decoder.dropFirst(header.totalLength + currentIndex).map { $0 }
            payload = Data(payloadBytes)
        } else {
            return nil
        }
        
        self.payload = payload
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

extension PublishPacket {
    struct Header {
        let topicName: String
        let identifier: UInt16?
        let properties: Property?
        
        fileprivate var totalLength: Int = 0
        
        init(topicName: String, identifier: UInt16? = nil, properties: Property? = nil) {
            self.topicName = topicName
            self.identifier = identifier
            self.properties = properties
        }
        
        init?(decoder: [UInt8], qos: UInt8) throws {
            if decoder.count == 0 {
                throw PacketError.invalidPacket("topic name not found")
            }
            
            let stringData = try MQTTUTF8String(from: decoder)
            topicName = stringData.value
            
            var identifier: UInt16? = nil
            var properties: Property? = nil
            
            var currentIndex = stringData.bytes.count
            
            if qos > 0 && decoder.count >= currentIndex + 1 {
                identifier = UInt16(decoder[currentIndex], decoder[currentIndex+1])
                currentIndex += 2
            }
            
            let remainingBytes = decoder.dropFirst(currentIndex).map { $0 }
            properties = try Property(decoder: remainingBytes)
            
            self.identifier = identifier
            self.properties = properties
            self.totalLength = currentIndex + (properties?.totalLength ?? 0)
        }
    }
}

extension PublishPacket.Header {
    struct Property {
        let payloadFormatIndicator: Bool?
        let messageExpiryInterval: UInt32?
        let topicAlias: UInt16?
        let responseTopic: String?
        let correlationData: Data?
        let userProperty: [String: String]?
        let subscriptionIdentifier: [UInt32]?
        let contentType: String?
        
        fileprivate var totalLength: Int = 0
        
        init(
            payloadFormatIndicator: Bool? = nil,
            messageExpiryInterval: UInt32? = nil,
            topicAlias: UInt16? = nil,
            responseTopic: String? = nil,
            correlationData: Data? = nil,
            userProperty: [String: String]? = nil,
            subscriptionIdentifier: [UInt32]? = nil,
            contentType: String?
            ) {
            self.payloadFormatIndicator = payloadFormatIndicator
            self.messageExpiryInterval = messageExpiryInterval
            self.topicAlias = topicAlias
            self.responseTopic = responseTopic
            self.correlationData = correlationData
            self.userProperty = userProperty
            self.subscriptionIdentifier = subscriptionIdentifier
            self.contentType = contentType
        }
        
        init?(decoder: [UInt8]) throws {
            var payloadFormatIndicator: Bool? = nil
            var messageExpiryInterval: UInt32? = nil
            var topicAlias: UInt16? = nil
            var responseTopic: String? = nil
            var correlationData: Data? = nil
            var userProperty: [String: String] = [:]
            var subscriptionIdentifier: [UInt32] = []
            var contentType: String? = nil
            
            if decoder.count > 0 {
                
                let variableLength = try VariableByteInteger(from: decoder)
                if variableLength.value > decoder.count - variableLength.bytes.count {
                    throw PacketError.invalidPacket("Packet variable properties size invalid")
                }
                totalLength = variableLength.totlaLength
                
                var isDecoded: [MQTTPropertyIdentifier: Bool] = [:]
                var currentIndex = variableLength.bytes.count
                
                while currentIndex < decoder.count, currentIndex < totalLength {
                    
                    if let property = try ByteProperty(MQTTPropertyIdentifier.payloadFormatIndicator, decoder, startIndex: currentIndex) {
                        if isDecoded[property.identifier] == true {
                            throw PacketError.duplicateQuality("payloadFormatIndicator")
                        }
                        isDecoded[property.identifier] = true
                        
                        payloadFormatIndicator = property.value == 0x01
                        currentIndex += property.propertyLength + 1
                    }
                    
                    if let property = try FourByteProperty(MQTTPropertyIdentifier.messageExpiryInterval, decoder, startIndex: currentIndex) {
                        if isDecoded[property.identifier] == true {
                            throw PacketError.duplicateQuality("messageExpiryInterval")
                        }
                        isDecoded[property.identifier] = true
                        
                        messageExpiryInterval = property.value
                        currentIndex += property.propertyLength + 1
                    }
                    
                    if let property = try TwoByteProperty(MQTTPropertyIdentifier.topicAlias, decoder, startIndex: currentIndex) {
                        if isDecoded[property.identifier] == true {
                            throw PacketError.duplicateQuality("topicAlias")
                        }
                        isDecoded[property.identifier] = true
                        
                        topicAlias = property.value
                        currentIndex += property.propertyLength + 1
                    }
                    
                    if let property = try StringProperty(MQTTPropertyIdentifier.responseTopic, decoder, startIndex: currentIndex) {
                        if isDecoded[property.identifier] == true {
                            throw PacketError.duplicateQuality("responseTopic")
                        }
                        isDecoded[property.identifier] = true
                        
                        responseTopic = property.value
                        currentIndex += property.propertyLength + 1
                    }
                    
                    if let property = try DataProperty(MQTTPropertyIdentifier.correlationData, decoder, startIndex: currentIndex) {
                        if isDecoded[property.identifier] == true {
                            throw PacketError.duplicateQuality("correlationData")
                        }
                        isDecoded[property.identifier] = true
                        
                        correlationData = property.value
                        currentIndex += property.propertyLength + 1
                    }
                    
                    while let property = try StringPairProperty(MQTTPropertyIdentifier.userProperty, decoder, startIndex: currentIndex) {
                        userProperty[property.key] = property.value
                        currentIndex += property.propertyLength + 1
                    }
                    
                    while currentIndex < decoder.count && decoder[currentIndex] == MQTTPropertyIdentifier.subscriptionIdentifier.rawValue {
                        let variableValue = try VariableByteInteger(from: decoder, startIndex: currentIndex+1)
                        subscriptionIdentifier.append(variableValue.value)
                        
                        currentIndex += variableValue.bytes.count + 1
                    }
                    
                    if let property = try StringProperty(MQTTPropertyIdentifier.contentType, decoder, startIndex: currentIndex) {
                        if isDecoded[property.identifier] == true {
                            throw PacketError.duplicateQuality("contentType")
                        }
                        isDecoded[property.identifier] = true
                        
                        contentType = property.value
                        currentIndex += property.propertyLength + 1
                    }
                }
            }
            
            self.payloadFormatIndicator = payloadFormatIndicator
            self.messageExpiryInterval = messageExpiryInterval
            self.topicAlias = topicAlias
            self.responseTopic = responseTopic
            self.correlationData = correlationData
            self.userProperty = userProperty
            self.subscriptionIdentifier = subscriptionIdentifier
            self.contentType = contentType
        }
    }
}
