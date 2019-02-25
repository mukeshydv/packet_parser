//
//  MQTTTypes.swift
//  MQTT
//
//  Created by Mukesh on 22/01/19.
//

import Foundation

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
public enum MQTTControlPacketType: UInt8 {
    case reserved = 0x0 // Forbidden
    
    case CONNECT = 0x1
    case CONNACK = 0x2
    case PUBLISH = 0x3
    case PUBACK = 0x4
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

public enum ReasonCode: UInt8 {
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

public enum MQTTPacket {
    case connect(ConnectPacket)
    case auth(AuthPacket)
    case connack(ConnackPacket)
    case disconnect(DisconnectPacket)
    case pingReq(PingReqPacket)
    case pingResp(PingRespPacket)
    case puback(PubackPacket)
    case pubcomp(PubcompPacket)
    case publish(PublishPacket)
    case pubrec(PubrecPacket)
    case pubrel(PubrelPacket)
    case suback(SubackPacket)
    case subscribe(SubscribePacket)
    case unsuback(UnsubackPacket)
    case unsubscribe(UnsubscribePacket)
    
    func encode() throws -> [UInt8] {
        return try packet.encoded()
    }
    
    var packet: MQTTPacketCodable {
        switch self {
        case .connect(let packet):
            return packet
        case .auth(let packet):
            return packet
        case .connack(let packet):
            return packet
        case .disconnect(let packet):
            return packet
        case .pingReq(let packet):
            return packet
        case .pingResp(let packet):
            return packet
        case .puback(let packet):
            return packet
        case .pubcomp(let packet):
            return packet
        case .publish(let packet):
            return packet
        case .pubrec(let packet):
            return packet
        case .pubrel(let packet):
            return packet
        case .suback(let packet):
            return packet
        case .subscribe(let packet):
            return packet
        case .unsuback(let packet):
            return packet
        case .unsubscribe(let packet):
            return packet
        }
    }
}

extension Sequence {
    var array: [Element] {
        return Array(self)
    }
}
