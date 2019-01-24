//
//  MQTTTypes.swift
//  MQTT
//
//  Created by Mukesh on 22/01/19.
//

import Foundation

public enum MQTTRequestMessage {
    case connect
}

public enum MQTTResponseMessage {
    case connectAck
}

struct VariableByteInteger {
    let value: UInt32
    let bytes: [UInt8]
    
    init(_ value: UInt32) {
        self.value = value
        self.bytes = []
    }
    
    init(_ bytes: UInt8...) {
        self.value = 0
        self.bytes = bytes
    }
}

// Packet format
// Fixed Header
//              -------------------------------------------
//              |Bit      | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
//              -------------------------------------------
//              |byte 1   | control packet| Flags         |
//              -------------------------------------------
//              |byte 2   | Remaining Length              |
//              -------------------------------------------
/// Bit 7-4 in Control header
///
/// - reserved: Forbidden
/// - CONNECT: Connection request (Client to server)
/// - CONNACK: Connect acknowledgment (Server to client)
/// - PUBLISH: Publish message (bidirectional)
/// - PUBACK: Publish acknowledgment (bidirectional)
/// - PUBREC: Publish received (QoS 2 delivery part 1) (bidirectional)
/// - PUBREL: Publish release (QoS 2 delivery part 2) (bidirectional)
/// - PUBCOMP: Publish complete (QoS 2 delivery part 3) (bidirectional)
/// - SUBSCRIBE: Subscribe request (Client to server)
/// - SUBACK: Subscribe acknowledgment (Server to client)
/// - UNSUBSCRIBE: Unsubscribe request (Client to server)
/// - UNSUBACK: Unsubscribe acknowledgment (Server to client)
/// - PINGREQ: PING request (Client to server)
/// - PINGRESP: PING response (Server to client)
/// - DISCONNECT: Disconnect notification (bidirectional)
/// - AUTH: Authentication exchange (bidirectional)
enum MQTTControlPacketType: UInt8 {
    case reserved = 0x0 // Forbidden
    
    
    // packet fixed header: 0001 0000
    // variable header: protocol name, protocol level, connect flags, keep alive and properties
    // 
    case CONNECT = 0x1 // Connection request (Client to server)
    case CONNACK = 0x2 // Connect acknowledgment (Server to client)
    case PUBLISH = 0x3 // Publish message (bidirectional)
    case PUBACK = 0x4 // Publish acknowledgment (bidirectional)
    case PUBREC = 0x5
    case PUBREL = 0x6
    case PUBCOMP = 0x7
    case SUBSCRIBE = 0x8
    case SUBACK = 0x9
    case UNSUBSCRIBE = 0xA
    case UNSUBACK = 0xB
    case PINGREQ = 0xC
    case PINGRESP = 0xD
    case DISCONNECT = 0xE
    case AUTH = 0xF
    
    var supportedPropertyIdentifiers: [PropertyIdentifier] {
        switch self {
        case .reserved:
            return []
        case .CONNECT:
            return [
                .sessionExpiryInterval,
                .authenticationMethod,
                .authenticationData,
                .requestProblemInformation,
                .requestResponseInformation,
                .receiveMaximum,
                .topicAliasMaximum,
                .userProperty,
                .maximumPacketSize
            ]
        case .CONNACK:
            return [
                .sessionExpiryInterval,
                .assignClientIdentifier,
                .serverKeepAlive,
                .authenticationMethod,
                .authenticationData,
                .responseInformation,
                .serverReference,
                .reasonString,
                .receiveMaximum,
                .topicAliasMaximum,
                .maximumQoS,
                .retainAvailable,
                .userProperty,
                .maximumPacketSize,
                .wildcardSubscriptionAvailable,
                .subscriptionIdentifierAvailable,
                .sharedSubscriptionAvailable
            ]
        case .PUBLISH:
            return [
                .payloadFormatIndicator,
                .messageExpiryInterval,
                .contentType,
                .responseTopic,
                .correlationData,
                .subscriptionIdentifier,
                .topicAlias,
                .userProperty
            ]
        case .PUBACK:
            return [
                .reasonString,
                .userProperty
            ]
        case .PUBREC:
            return [
                .reasonString,
                .userProperty
            ]
        case .PUBREL:
            return [
                .reasonString,
                .userProperty
            ]
        case .PUBCOMP:
            return [
                .reasonString,
                .userProperty
            ]
        case .SUBSCRIBE:
            return [
                .subscriptionIdentifier,
                .userProperty
            ]
        case .SUBACK:
            return [
                .reasonString,
                .userProperty
            ]
        case .UNSUBSCRIBE:
            return [
                .userProperty
            ]
        case .UNSUBACK:
            return [
                .reasonString,
                .userProperty
            ]
        case .PINGREQ:
            return []
        case .PINGRESP:
            return []
        case .DISCONNECT:
            return [
                .sessionExpiryInterval,
                .serverReference,
                .reasonString,
                .userProperty
            ]
        case .AUTH:
            return [
                .authenticationMethod,
                .authenticationData,
                .reasonString,
                .userProperty
            ]
        }
    }
}

enum PropertyIdentifier: UInt8 {
    case payloadFormatIndicator = 0x01
    case messageExpiryInterval = 0x02
    case contentType = 0x03
    case responseTopic = 0x08
    case correlationData = 0x09
    case subscriptionIdentifier = 0x0B
    case sessionExpiryInterval = 0x11
    case assignClientIdentifier = 0x12
    case serverKeepAlive = 0x13
    case authenticationMethod = 0x15
    case authenticationData = 0x16
    case requestProblemInformation = 0x17
    case willDelayInterval = 0x18
    case requestResponseInformation = 0x19
    case responseInformation = 0x1A
    case serverReference = 0x1C
    case reasonString = 0x1F
    case receiveMaximum = 0x21
    case topicAliasMaximum = 0x22
    case topicAlias = 0x23
    case maximumQoS = 0x24
    case retainAvailable = 0x25
    case userProperty = 0x26
    case maximumPacketSize = 0x27
    case wildcardSubscriptionAvailable = 0x28
    case subscriptionIdentifierAvailable = 0x29
    case sharedSubscriptionAvailable = 0x2A
    
    var dataType: MQTTDataType {
        switch self {
        case .payloadFormatIndicator:
            return .byte
        case .messageExpiryInterval:
            return .fourByteInteger
        case .contentType:
            return .utf8String
        case .responseTopic:
            return .utf8String
        case .correlationData:
            return .binary
        case .subscriptionIdentifier:
            return .variableByteInteger
        case .sessionExpiryInterval:
            return .fourByteInteger
        case .assignClientIdentifier:
            return .utf8String
        case .serverKeepAlive:
            return .twoByteInteger
        case .authenticationMethod:
            return .utf8String
        case .authenticationData:
            return .binary
        case .requestProblemInformation:
            return .byte
        case .willDelayInterval:
            return .fourByteInteger
        case .requestResponseInformation:
            return .byte
        case .responseInformation:
            return .utf8String
        case .serverReference:
            return .utf8String
        case .reasonString:
            return .utf8String
        case .receiveMaximum:
            return .twoByteInteger
        case .topicAliasMaximum:
            return .twoByteInteger
        case .topicAlias:
            return .twoByteInteger
        case .maximumQoS:
            return .byte
        case .retainAvailable:
            return .byte
        case .userProperty:
            return .utf8String
        case .maximumPacketSize:
            return .fourByteInteger
        case .wildcardSubscriptionAvailable:
            return .byte
        case .subscriptionIdentifierAvailable:
            return .byte
        case .sharedSubscriptionAvailable:
            return .byte
        }
    }
    
    var isWillProperty: Bool {
        switch self {
        case .payloadFormatIndicator,
             .messageExpiryInterval,
             .contentType,
             .responseTopic,
             .correlationData,
             .willDelayInterval,
             .userProperty:
            return true
        case .subscriptionIdentifier,
             .sessionExpiryInterval,
             .assignClientIdentifier,
             .serverKeepAlive,
             .authenticationMethod,
             .authenticationData,
             .requestProblemInformation,
             .requestResponseInformation,
             .responseInformation,
             .serverReference,
             .reasonString,
             .receiveMaximum,
             .topicAliasMaximum,
             .topicAlias,
             .maximumQoS,
             .retainAvailable,
             .maximumPacketSize,
             .wildcardSubscriptionAvailable,
             .subscriptionIdentifierAvailable,
             .sharedSubscriptionAvailable:
            return false
        }
    }
}

enum MQTTDataType {
    case byte
    case twoByteInteger
    case fourByteInteger
    case utf8String
    case binary
    case variableByteInteger
}

enum ReasonCode {
    case success
    case normalDisconnection
    case grantQoS0
    case grantQos1
    case grantQos2
    case disconnectWithWillMessage
    case noMatchingSubscribers
    case noSubscriberExisted
    case continueAuthentication
    case reAuthenticate
    case unspecifiedError
    case malformedPacket
    case protocolError
    case implementationSpecificError
    case unsupportedProtocolVersion
    case clientIdentifierNotValid
    case badUsernameOrPassword
    case notAuthorized
    case serverUnavailable
    case serverBusy
    case banned
    case serverShuttingDown
    case badAuthenticationMethod
    case keepAliveTimeout
    case sessionTakenOver
    case topicFilterInvalid
    case topicNameInvalid
    case packetIdentifierInUse
    case packetIdentifierNotFound
    case receiveMaximumExceeded
    case topicAliasInvalid
    case packetTooLarge
    case messageRateTooHigh
    case quotaExceeded
    case administrativeAction
    case payloadFormatInvalid
    case retainNotSupported
    case qosNotSupported
    case useAnotherServer
    case serverMoved
    case sharedSubscriptionNotSupported
    case connectionRateExceeded
    case maximumConnectTime
    case subscriptionIdentifierNotSupported
    case wildcardSubscriptionNotSupported
    
    var value: UInt8 {
        switch self {
        case .success,
             .normalDisconnection,
             .grantQoS0:
            return 0x00
        case .grantQos1:
            return 0x01
        case .grantQos2:
            return 0x02
        case .disconnectWithWillMessage:
            return 0x04
        case .noMatchingSubscribers:
            return 0x10
        case .noSubscriberExisted:
            return 0x11
        case .continueAuthentication:
            return 0x18
        case .reAuthenticate:
            return 0x19
        case .unspecifiedError:
            return 0x80
        case .malformedPacket:
            return 0x81
        case .protocolError:
            return 0x82
        case .implementationSpecificError:
            return 0x83
        case .unsupportedProtocolVersion:
            return 0x84
        case .clientIdentifierNotValid:
            return 0x85
        case .badUsernameOrPassword:
            return 0x86
        case .notAuthorized:
            return 0x87
        case .serverUnavailable:
            return 0x88
        case .serverBusy:
            return 0x89
        case .banned:
            return 0x8A
        case .serverShuttingDown:
            return 0x8B
        case .badAuthenticationMethod:
            return 0x8C
        case .keepAliveTimeout:
            return 0x8D
        case .sessionTakenOver:
            return 0x8E
        case .topicFilterInvalid:
            return 0x8F
        case .topicNameInvalid:
            return 0x90
        case .packetIdentifierInUse:
            return 0x91
        case .packetIdentifierNotFound:
            return 0x92
        case .receiveMaximumExceeded:
            return 0x93
        case .topicAliasInvalid:
            return 0x94
        case .packetTooLarge:
            return 0x95
        case .messageRateTooHigh:
            return 0x96
        case .quotaExceeded:
            return 0x97
        case .administrativeAction:
            return 0x98
        case .payloadFormatInvalid:
            return 0x99
        case .retainNotSupported:
            return 0x9A
        case .qosNotSupported:
            return 0x9B
        case .useAnotherServer:
            return 0x9C
        case .serverMoved:
            return 0x9D
        case .sharedSubscriptionNotSupported:
            return 0x9E
        case .connectionRateExceeded:
            return 0x9F
        case .maximumConnectTime:
            return 0xA0
        case .subscriptionIdentifierNotSupported:
            return 0xA1
        case .wildcardSubscriptionNotSupported:
            return 0xA2
        }
    }
}
