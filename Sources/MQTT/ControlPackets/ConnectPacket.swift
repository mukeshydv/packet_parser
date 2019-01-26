//
//  ConnectPacket.swift
//  MQTT
//
//  Created by Mukesh on 25/01/19.
//

import Foundation

public struct ConnectPacketQualities {
    let sessionExpiryInterval: UInt32
    let receiveMaximum: UInt16
    let maximumPacketSize: UInt32
    let topicAliasMaximum: UInt16
    let requestResponseInformation: UInt8
    let requestProblemInformation: UInt8
    let userProperty: [(String, String)]
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
    
    func encode() -> [UInt8] {
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
            
            let key = property.0.utf8EncodedBytes
            let value = property.1.utf8EncodedBytes
            
            bytes.append(contentsOf: key)
            bytes.append(contentsOf: value)
        }
        
        if let authenticationMethod = self.authenticationMethod {
            bytes.append(PropertyIdentifier.authenticationMethod.rawValue)
            bytes.append(contentsOf: authenticationMethod.utf8EncodedBytes)
        }
        
        if let authenticationData = self.authenticationData {
            bytes.append(PropertyIdentifier.authenticationData.rawValue)
            bytes.append(contentsOf: authenticationData.bytes)
        }
        
        return bytes
    }
}

public struct ConnectPacket {
    let username: Bool
    let password: Bool
    let willRetain: Bool
    let willQos: UInt8
    let willMessage: Bool
    let cleanStart: Bool
    let keepAlive: UInt16
    let properties: ConnectPacketQualities
    
    public init(username: Bool = false,
         password: Bool = false,
         willRetain: Bool = false,
         willQos: UInt8,
         willMessage: Bool = false,
         cleanStart: Bool = false,
         keepAlive: UInt16 = 0,
         properties: ConnectPacketQualities = ConnectPacketQualities()
        ) {
        self.username = username
        self.password = password
        self.willRetain = willRetain
        self.willQos = willQos
        self.willMessage = willMessage
        self.cleanStart = cleanStart
        self.keepAlive = keepAlive
        self.properties = properties
    }
    
    init(decoder: [UInt8]) {
        self.init(willQos: 0)
    }
    
    func encode() -> [UInt8] {
        let variableHeaders = encodeVariableHeader
        let remainingLength = VariableByteInteger(UInt32(variableHeaders.count))
        return [0x10] // Fixed Header
            + remainingLength.bytes // Remaining length
            + variableHeaders // Headers
    }
    
    private var encodeVariableHeader: [UInt8] {
        let encodedProperties = properties.encode()
        let propertyLength = VariableByteInteger(UInt32(encodedProperties.count))
        
        var bytes: [UInt8] = [0x00, 0x04] //
        bytes.append(contentsOf: "MQTT".bytes)
        bytes.append(0x05)
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
