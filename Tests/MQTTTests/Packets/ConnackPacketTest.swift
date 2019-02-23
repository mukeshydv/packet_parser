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
            32, 87, 1, 0, 84, 17, 0, 0, 4, 210, 33, 1, 176, 36, 2, 37, 1, 39, 0, 0, 0, 100, 18, 0, 4, 116, 101, 115, 116, 34, 1, 200, 31, 0, 4, 116, 101, 115, 116, 38, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116, 40, 1, 41, 1, 42, 0, 19, 4, 210, 26, 0, 4, 116, 101, 115, 116, 28, 0, 4, 116, 101, 115, 116, 21, 0, 4, 116, 101, 115, 116, 22, 0, 4, 1, 2, 3, 4
        ]
        
        let testDecodedPacket = try! ConnackPacket(decoder: bytes)
        
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
            32, 87, 1, 0, 84, 17, 0, 0, 4, 210, 33, 1, 176, 36, 2, 37, 1, 39, 0, 0, 0, 100, 18, 0, 4, 116, 101, 115, 116, 34, 1, 200, 31, 0, 4, 116, 101, 115, 116, 38, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116, 40, 1, 41, 1, 42, 0, 19, 4, 210, 26, 0, 4, 116, 101, 115, 116, 28, 0, 4, 116, 101, 115, 116, 21, 0, 4, 116, 101, 115, 116, 22, 0, 4, 1, 2, 3, 4
        ]
        XCTAssert(encodedBytes == expectedBytes)
    }
    
    func testEncodingEmpty() {
        let header = ConnackPacket.Header(sessionPresent: false, reasonCode: .success)
        let packet = ConnackPacket(header: header)
        
        let encodedBytes = try! packet.encoded()
        
        let expectedBytes: [UInt8] = [
            32, 2, 0, 0
        ]
        XCTAssert(encodedBytes == expectedBytes)
    }
    
    static var allTests = [
        ("testEncodingEmpty", testEncodingEmpty),
        ("testEncodingFilled", testEncodingFilled),
        ("testDecoding", testDecoding),
        ]
}
