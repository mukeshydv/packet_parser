//
//  MQTTTypes.swift
//  MQTT
//
//  Created by Mukesh on 22/01/19.
//

import Foundation

public enum MQTTRequestMessage {
    
}

public enum MQTTResponseMessage {
    
}

// Packet format
//Fixed Header
//format
//390
// |Bit      | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
// |byte 1   | control packet| Flags         |
// |byte 2   | Remaining Length              |

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
    case reserved = 0 // Forbidden
    case CONNECT = 1 // Connection request (Client to server)
    case CONNACK = 2 // Connect acknowledgment (Server to client)
    case PUBLISH = 3 // Publish message (bidirectional)
    case PUBACK = 4 // Publish acknowledgment (bidirectional)
    case PUBREC = 5
    case PUBREL = 6
    case PUBCOMP = 7
    case SUBSCRIBE = 8
    case SUBACK = 9
    case UNSUBSCRIBE = 10
    case UNSUBACK = 11
    case PINGREQ = 12
    case PINGRESP = 13
    case DISCONNECT = 14
    case AUTH = 15
    
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
