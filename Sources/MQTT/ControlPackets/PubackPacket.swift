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
    
    func encodedVariableHeader() throws -> [UInt8] {
        // TODO:
        return []
    }
    
    func encodedPayload() throws -> [UInt8] {
        // TODO:
        return []
    }
}

extension PubackPacket {
    struct Header {
        let identifier: UInt16
        let reasonCode: ReasonCode
        let properties: Property?
        
        init(
            identifier: UInt16,
            reasonCode: ReasonCode = .success,
            properties: Property? = nil
            ) {
            self.identifier = identifier
            self.reasonCode = reasonCode
            self.properties = properties
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
        
        func encode() throws -> [UInt8] {
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
            
            let propertyLength = VariableByteInteger(UInt32(bytes.count))
            return propertyLength.bytes + bytes
        }
    }
}
