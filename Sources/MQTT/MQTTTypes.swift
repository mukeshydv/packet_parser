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
            return try! packet.encoded()
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

enum ReasonCode: UInt8 {
    case success = 0x00
//    case normalDisconnection
//    case grantQoS0
    case grantQos1 = 0x01
    case grantQos2 = 0x02
    case disconnectWithWillMessage = 0x04
    case noMatchingSubscribers = 0x10
    case noSubscriberExisted = 0x11
    case continueAuthentication = 0x18
    case reAuthenticate = 0x19
    case unspecifiedError = 0x80
    case malformedPacket = 0x81
    case protocolError = 0x82
    case implementationSpecificError = 0x83
    case unsupportedProtocolVersion = 0x84
    case clientIdentifierNotValid = 0x85
    case badUsernameOrPassword = 0x86
    case notAuthorized = 0x87
    case serverUnavailable = 0x88
    case serverBusy = 0x89
    case banned = 0x8A
    case serverShuttingDown = 0x8B
    case badAuthenticationMethod = 0x8C
    case keepAliveTimeout = 0x8D
    case sessionTakenOver = 0x8E
    case topicFilterInvalid = 0x8F
    case topicNameInvalid = 0x90
    case packetIdentifierInUse = 0x91
    case packetIdentifierNotFound = 0x92
    case receiveMaximumExceeded = 0x93
    case topicAliasInvalid = 0x94
    case packetTooLarge = 0x95
    case messageRateTooHigh = 0x96
    case quotaExceeded = 0x97
    case administrativeAction = 0x98
    case payloadFormatInvalid = 0x99
    case retainNotSupported = 0x9A
    case qosNotSupported = 0x9B
    case useAnotherServer = 0x9C
    case serverMoved = 0x9D
    case sharedSubscriptionNotSupported = 0x9E
    case connectionRateExceeded = 0x9F
    case maximumConnectTime = 0xA0
    case subscriptionIdentifierNotSupported = 0xA1
    case wildcardSubscriptionNotSupported = 0xA2
}
