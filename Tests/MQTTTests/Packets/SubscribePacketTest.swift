//
//  SubscribePacketTest.swift
//  MQTTTests
//
//  Created by Mukesh on 19/02/19.
//

import XCTest
@testable import MQTT

class SubscribePacketTest: XCTestCase {
    func testDecoding() {
        let bytes: [UInt8] = [
            130, 26, 0, 42, 16, 11, 145, 1, 38, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116, 24
        ]
        
        let testDecodedPacket = try! SubscribePacket(decoder: bytes)!
        
        XCTAssert(testDecodedPacket.header.identifier == 42)
        XCTAssert(testDecodedPacket.header.properties.subscriptionIdentifier == 145)
        XCTAssert(testDecodedPacket.header.properties.userProperty == ["test": "test"])
        XCTAssert(testDecodedPacket.payload.topics["test"] != nil)
        XCTAssert(testDecodedPacket.payload.topics["test"]!.maximumQoS == 0)
        XCTAssert(testDecodedPacket.payload.topics["test"]!.noLocalOption == false)
        XCTAssert(testDecodedPacket.payload.topics["test"]!.retainAsPublished == true)
        XCTAssert(testDecodedPacket.payload.topics["test"]!.retainHandling == 1)
    }
    
    func testDecodingEmpty() {
        let bytes: [UInt8] = [
            130, 10, 0, 42, 0, 0, 4, 116, 101, 115, 116, 24
        ]
        
        let testDecodedPacket = try! SubscribePacket(decoder: bytes)!
        
        XCTAssert(testDecodedPacket.header.identifier == 42)
        XCTAssert(testDecodedPacket.header.properties.subscriptionIdentifier == nil)
        XCTAssert(testDecodedPacket.header.properties.userProperty == nil)
        XCTAssert(testDecodedPacket.payload.topics["test"] != nil)
        XCTAssert(testDecodedPacket.payload.topics["test"]!.maximumQoS == 0)
        XCTAssert(testDecodedPacket.payload.topics["test"]!.noLocalOption == false)
        XCTAssert(testDecodedPacket.payload.topics["test"]!.retainAsPublished == true)
        XCTAssert(testDecodedPacket.payload.topics["test"]!.retainHandling == 1)
    }
    
    func testEncodingFilled() {
        let properties = SubscribePacket.Header.Property(subscriptionIdentifier: 145, userProperty: ["test": "test"])
        let header = SubscribePacket.Header(identifier: 42, properties: properties)
        
        let topicOption = SubscribePacket.Payload.SubscriptionOption(maximumQoS: 0, noLocalOption: false, retainAsPublished: true, retainHandling: 1)
        let payload = SubscribePacket.Payload(topics: ["test": topicOption])
        let packet = SubscribePacket(header: header, payload: payload)
        
        let encodedBytes = try! packet.encoded()
        let expectedBytes: [UInt8] = [
            130, 26, 0, 42, 16, 11, 145, 1, 38, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116, 24
        ]
        
        XCTAssert(encodedBytes == expectedBytes)
    }
    
    func testEncodingEmpty() {
        let header = SubscribePacket.Header(identifier: 42)
        
        let topicOption = SubscribePacket.Payload.SubscriptionOption(maximumQoS: 0, noLocalOption: false, retainAsPublished: true, retainHandling: 1)
        let payload = SubscribePacket.Payload(topics: ["test": topicOption])
        let packet = SubscribePacket(header: header, payload: payload)
        
        let encodedBytes = try! packet.encoded()
        let expectedBytes: [UInt8] = [
            130, 10, 0, 42, 0, 0, 4, 116, 101, 115, 116, 24
        ]
        
        XCTAssert(encodedBytes == expectedBytes)
    }
    
    static var allTests = [
        ("testEncodingEmpty", testEncodingEmpty),
        ("testEncodingFilled", testEncodingFilled),
        ("testDecoding", testDecoding),
        ("testDecodingEmpty", testDecodingEmpty),
        ]
}
