//
//  MQTTTypes.swift
//  MQTT
//
//  Created by Mukesh on 22/01/19.
//

import Foundation



public enum MQTTRequestMessage {
    case connect(ConnectPacket)
    
    var encoded: [UInt8] {
        switch self {
        case .connect(let packet):
            return try! packet.encode()
        }
    }
}

public enum MQTTResponseMessage {
    case connectAck
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
