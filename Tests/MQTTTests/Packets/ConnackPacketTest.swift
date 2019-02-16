//
//  ConnackPacketTest.swift
//  MQTTTests
//
//  Created by Mukesh on 16/02/19.
//

import XCTest
@testable import MQTT

class ConnackPacketTest: XCTestCase {
    func testDecoding() {
        let bytes: [UInt8] = [
            0x20, 0x57, 0x01, 0x00, 0x54, 0x11, 0x00, 0x00, 0x04, 0xd2, 0x21, 0x01, 0xb0, 0x24, 0x02, 0x25, 0x01, 0x27, 0x00, 0x00, 0x00, 0x64, 0x12, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x22, 0x01, 0xc8, 0x1f, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x26, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x28, 0x01, 0x29, 0x01, 0x2a, 0x00, 0x13, 0x04, 0xd2, 0x1a, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x1c, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x15, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x16, 0x00, 0x04, 0x01, 0x02, 0x03, 0x04
        ]
        
        let testDecodedPacket = try! ConnackPacket(decoder: bytes)!
        
        XCTAssert(testDecodedPacket.header.flags.sessionPresent == true)
        XCTAssert(testDecodedPacket.header.reasonCode == .success)
        XCTAssert(testDecodedPacket.header.properties?.assignedClientIdentifier == "test")
        XCTAssert(testDecodedPacket.header.properties?.authenticationData == Data([1, 2, 3, 4]))
        XCTAssert(testDecodedPacket.header.properties?.authenticationMethod == "test")
        XCTAssert(testDecodedPacket.header.properties?.maximumPacketSize == 100)
        XCTAssert(testDecodedPacket.header.properties?.maximumQoS == 2)
        XCTAssert(testDecodedPacket.header.properties?.reasonString == "test")
        XCTAssert(testDecodedPacket.header.properties?.receiveMaximum == 432)
        XCTAssert(testDecodedPacket.header.properties?.responseInformation == "test")
        XCTAssert(testDecodedPacket.header.properties?.retainAvailable == true)
        XCTAssert(testDecodedPacket.header.properties?.serverKeepAlive == 1234)
        XCTAssert(testDecodedPacket.header.properties?.serverReference == "test")
        XCTAssert(testDecodedPacket.header.properties?.sessionExpiryInterval == 1234)
        XCTAssert(testDecodedPacket.header.properties?.sharedSubscriptionAvailable == false)
        XCTAssert(testDecodedPacket.header.properties?.subscriptionIdentifiersAvailable == true)
        XCTAssert(testDecodedPacket.header.properties?.topicAliasMaximum == 456)
        XCTAssert(testDecodedPacket.header.properties?.userProperties == ["test": "test"])
        XCTAssert(testDecodedPacket.header.properties?.wildcardSubscriptionAvailable == true)
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
        let header = ConnackPacket.Header(sessionPresent: false, reasonCode: .success)
        let packet = ConnackPacket(header: header)
        
        let encodedBytes = try! packet.encoded()
        
        let expectedBytes: [UInt8] = [
            0x20, 0x02, 0x00, 0x00
        ]
        XCTAssert(encodedBytes == expectedBytes)
    }
    
    static var allTests = [
        ("testEncodingEmpty", testEncodingEmpty),
        ("testEncodingFilled", testEncodingFilled),
        ("testDecoding", testDecoding),
        ]
}
