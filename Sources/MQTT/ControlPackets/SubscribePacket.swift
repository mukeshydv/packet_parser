//
//  SubscribePacket.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

public struct SubscribePacket: MQTTPacketCodable {
    let header: Header
    let payload: Payload
    
    public let fixedHeader: MQTTPacketFixedHeader
    
    public init(header: Header, payload: Payload) {
        self.fixedHeader = MQTTPacketFixedHeader(packetType: .SUBSCRIBE, flags: 2)
        
        self.header = header
        self.payload = payload
    }
    
    public init(decoder: [UInt8]) throws {
        if decoder.count == 0 {
            throw PacketError.invalidPacket("Packet identifier invalid")
        }
        
        fixedHeader = try MQTTPacketFixedHeader(networkByte: decoder[0])
        
        if fixedHeader.packetType != .SUBSCRIBE {
            throw PacketError.invalidPacket("Packet identifier invalid")
        }
        
        let variableHeaderLength = try VariableByteInteger(from: decoder, startIndex: 1)
        if variableHeaderLength.value + 1 != decoder.count - variableHeaderLength.bytes.count {
            throw PacketError.invalidPacket("Packet variable header size invalid")
        }
        
        let currentIndex = variableHeaderLength.bytes.count + 1
        let remainingBytes = decoder.dropFirst(currentIndex).array
        
        header = try Header(decoder: remainingBytes)
        
        let payloadBytes = decoder.dropFirst(header.totalLength + currentIndex).array
        payload = try Payload(decoder: payloadBytes)
    }
    
    public func encodedVariableHeader() throws -> [UInt8] {
        return try header.encode()
    }
    
    public func encodedPayload() throws -> [UInt8] {
        return try payload.encode()
    }
}

extension SubscribePacket {
    public struct Header {
        let identifier: UInt16
        let properties: Property
        
        fileprivate var totalLength: Int = 0
        
        public init(identifier: UInt16, properties: Property = .init()) {
            self.identifier = identifier
            self.properties = properties
        }
        
        public init(decoder: [UInt8]) throws {
            if decoder.count < 2 {
                throw PacketError.invalidPacket("identifier not present")
            }
            
            identifier = UInt16(decoder[0], decoder[1])
            
            let remainingBytes = decoder.dropFirst(2).array
            properties = try Property(decoder: remainingBytes)
            
            totalLength = properties.totalLength + 2
        }
        
        func encode() throws -> [UInt8] {
            var bytes: [UInt8] = []
            
            bytes.append(contentsOf: identifier.bytes)
            bytes.append(contentsOf: try properties.encode())
            
            return bytes
        }
    }
    
    public struct Payload {
        let topics: [String: SubscriptionOption]
        
        public init(topics: [String: SubscriptionOption]) {
            self.topics = topics
        }
        
        public init(decoder: [UInt8]) throws {
            if decoder.count == 0 {
                throw PacketError.payloadError("No payload found")
            }
            
            var currentIndex: Int = 0
            var topics: [String: SubscriptionOption] = [:]
            
            while currentIndex < decoder.count {
                let utf8String = try MQTTUTF8String(from: decoder, startIndex: currentIndex)
                currentIndex += utf8String.bytes.count
                
                if currentIndex >= decoder.count {
                    throw PacketError.payloadError("No SubscriptionOption found for \(utf8String.value)")
                }
                
                let option = SubscriptionOption(decoder: decoder[currentIndex])
                
                topics[utf8String.value] = option
                
                currentIndex += 1
            }
            
            self.topics = topics
        }
        
        func encode() throws -> [UInt8] {
            var bytes: [UInt8] = []
            
            for topic in topics {
                let utf8String = try MQTTUTF8String(topic.key)
                
                bytes.append(contentsOf: utf8String.bytes)
                bytes.append(topic.value.encode())
            }
            
            return bytes
        }
    }
}

extension SubscribePacket.Payload {
    public struct SubscriptionOption {
        let maximumQoS: UInt8
        let noLocalOption: Bool
        let retainAsPublished: Bool
        let retainHandling: UInt8
        
        public init(
            maximumQoS: UInt8,
            noLocalOption: Bool,
            retainAsPublished: Bool,
            retainHandling: UInt8
            ) {
            self.maximumQoS = maximumQoS
            self.noLocalOption = noLocalOption
            self.retainAsPublished = retainAsPublished
            self.retainHandling = retainHandling
        }
        
        public init(decoder: UInt8) {
            maximumQoS = decoder & 0x03
            noLocalOption = decoder & 0x04 == 1
            retainAsPublished = decoder & 0x08 == 0x08
            retainHandling = (decoder & 0x30) >> 4
        }
        
        func encode() -> UInt8 {
            
            let maximumQos: UInt8 = self.maximumQoS & 0x03
            let noLocalOption: UInt8 = self.noLocalOption ? 0x04 : 0x0
            let retainAsPublish: UInt8 = self.retainAsPublished ? 0x08 : 0x0
            let retainHandling: UInt8 = (self.retainHandling << 4) & 0x30
            
            return maximumQos | noLocalOption | retainHandling | retainAsPublish
        }
    }
}

extension SubscribePacket.Header {
    public struct Property {
        let subscriptionIdentifier: UInt32?
        let userProperty: [String: String]?
        
        fileprivate var totalLength: Int = 0
        
        public init(subscriptionIdentifier: UInt32? = nil, userProperty: [String: String]? = nil) {
            self.subscriptionIdentifier = subscriptionIdentifier
            self.userProperty = userProperty
        }
        
        public init(decoder: [UInt8]) throws {
            var subscriptionIdentifier: UInt32?
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
                    if decoder[currentIndex] == MQTTPropertyIdentifier.subscriptionIdentifier.rawValue {
                        if isDecoded[.subscriptionIdentifier] == true {
                            throw PacketError.duplicateQuality("subscriptionIdentifier")
                        }
                        isDecoded[.subscriptionIdentifier] = true
                        
                        let variableValue = try VariableByteInteger(from: decoder, startIndex: currentIndex+1)
                        subscriptionIdentifier = variableValue.value
                        currentIndex += variableValue.bytes.count + 1
                    }
                    
                    while let property = try StringPairProperty(MQTTPropertyIdentifier.userProperty, decoder, startIndex: currentIndex) {
                        userProperty[property.key] = property.value
                        currentIndex += property.propertyLength + 1
                    }
                }
            }
            
            self.subscriptionIdentifier = subscriptionIdentifier
            self.userProperty = userProperty.count > 0 ? userProperty : nil
        }
        
        func encode() throws -> [UInt8] {
            var bytes: [UInt8] = []
            
            if let property = subscriptionIdentifier {
                bytes.append(MQTTPropertyIdentifier.subscriptionIdentifier.rawValue)
                
                let variableValue = VariableByteInteger(property)
                bytes.append(contentsOf: variableValue.bytes)
            }
            
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
