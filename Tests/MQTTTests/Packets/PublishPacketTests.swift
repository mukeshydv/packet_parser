//
//  PublishPacketTests.swift
//  MQTTTests
//
//  Created by Mukesh on 17/02/19.
//

import XCTest
@testable import MQTT

class PublishPacketTests: XCTestCase {
    func testDecoding() {
        let bytes: [UInt8] = [
            0x34, 0x3c, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x00, 0x2a, 0x2f, 0x01, 0x01, 0x02, 0x00, 0x00, 0x10, 0xe1, 0x23, 0x00, 0x64, 0x08, 0x00, 0x05, 0x74, 0x6f, 0x70, 0x69, 0x63, 0x09, 0x00, 0x04, 0x01, 0x02, 0x03, 0x04, 0x26, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x0b, 0x78, 0x03, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x74, 0x65, 0x73, 0x74
        ]
        
        let testDecodedPacket = try! PublishPacket(decoder: bytes)!
        
        XCTAssert(testDecodedPacket.qos == 2)
        XCTAssert(testDecodedPacket.dup == false)
        XCTAssert(testDecodedPacket.retain == false)
        XCTAssert(testDecodedPacket.header.identifier == 42)
        XCTAssert(testDecodedPacket.header.topicName == "test")
        XCTAssert(testDecodedPacket.header.properties?.payloadFormatIndicator == true)
        XCTAssert(testDecodedPacket.header.properties?.messageExpiryInterval == 4321)
        XCTAssert(testDecodedPacket.header.properties?.topicAlias == 100)
        XCTAssert(testDecodedPacket.header.properties?.responseTopic == "topic")
        XCTAssert(testDecodedPacket.header.properties?.correlationData == Data([1, 2, 3, 4]))
        XCTAssert(testDecodedPacket.header.properties?.userProperty == ["test": "test"])
        XCTAssert(testDecodedPacket.header.properties?.subscriptionIdentifier == [120])
        XCTAssert(testDecodedPacket.header.properties?.contentType == "test")
    }
    
    func testDecodingEmpty() {
        let bytes: [UInt8] = [
            0x30, 0x07, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x00
        ]
        
        let testDecodedPacket = try! PublishPacket(decoder: bytes)!
        
        XCTAssert(testDecodedPacket.dup == false)
        XCTAssert(testDecodedPacket.retain == false)
        XCTAssert(testDecodedPacket.qos == 0)
        XCTAssert(testDecodedPacket.header.topicName == "test")
    }
    
    func testEncodingFilled() {
        let properties = ConnackPacket.Header.Property(sessionExpiryInterval: 1234, receiveMaximum: 432, maximumQoS: 2, retainAvailable: true, maximumPacketSize: 100, assignedClientIdentifier: "test", topicAliasMaximum: 456, reasonString: "test", userProperties: ["test": "test"], wildcardSubscriptionAvailable: true, subscriptionIdentifiersAvailable: true, sharedSubscriptionAvailable: false, serverKeepAlive: 1234, responseInformation: "test", serverReference: "test", authenticationMethod: "test", authenticationData: Data([1, 2, 3, 4]))
        
        let header = ConnackPacket.Header(sessionPresent: true, reasonCode: .success, properties: properties)
        let packet = ConnackPacket(header: header)
        
        let encodedBytes = try! packet.encoded()
        
        let expectedBytes: [UInt8] = [
            0x20, 0x57, 0x01, 0x00, 0x54, 0x11, 0x00, 0x00, 0x04, 0xd2, 0x21, 0x01, 0xb0, 0x24, 0x02, 0x25, 0x01, 0x27, 0x00, 0x00, 0x00, 0x64, 0x12, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x22, 0x01, 0xc8, 0x1f, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x26, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x28, 0x01, 0x29, 0x01, 0x2a, 0x00, 0x13, 0x04, 0xd2, 0x1a, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x1c, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x15, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x16, 0x00, 0x04, 0x01, 0x02, 0x03, 0x04
        ]
        XCTAssert(encodedBytes == expectedBytes)
    }
    
    func testEncodingEmpty() {
//        let header = PublishPacket.Header(topicName: "test")
//        let packet = PublishPacket(dup: false, qos: 0, retain: false, header: header)
//
//        let encodedBytes = try! packet.encoded()
//
//        let expectedBytes: [UInt8] = [
//            0x30, 0x07, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x00
//        ]
//        XCTAssert(encodedBytes == expectedBytes)
    }
    
    static var allTests = [
        ("testEncodingEmpty", testEncodingEmpty),
        ("testEncodingFilled", testEncodingFilled),
        ("testDecoding", testDecoding),
        ("testDecodingEmpty", testDecodingEmpty),
        ]
}
