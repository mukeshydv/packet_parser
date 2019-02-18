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
            52, 60, 0, 4, 116, 101, 115, 116, 0, 42, 47, 1, 1, 2, 0, 0, 16, 225, 35, 0, 100, 8, 0, 5, 116, 111, 112, 105, 99, 9, 0, 4, 1, 2, 3, 4, 38, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116, 11, 120, 3, 0, 4, 116, 101, 115, 116, 116, 101, 115, 116
        ]
        
        let testDecodedPacket = try! PublishPacket(decoder: bytes)!
        
        XCTAssert(testDecodedPacket.qos == 2)
        XCTAssert(testDecodedPacket.dup == false)
        XCTAssert(testDecodedPacket.retain == false)
        XCTAssert(testDecodedPacket.header.identifier == 42)
        XCTAssert(testDecodedPacket.header.topicName == "test")
        XCTAssert(testDecodedPacket.header.properties.payloadFormatIndicator == true)
        XCTAssert(testDecodedPacket.header.properties.messageExpiryInterval == 4321)
        XCTAssert(testDecodedPacket.header.properties.topicAlias == 100)
        XCTAssert(testDecodedPacket.header.properties.responseTopic == "topic")
        XCTAssert(testDecodedPacket.header.properties.correlationData == Data([1, 2, 3, 4]))
        XCTAssert(testDecodedPacket.header.properties.userProperty == ["test": "test"])
        XCTAssert(testDecodedPacket.header.properties.subscriptionIdentifier == [120])
        XCTAssert(testDecodedPacket.header.properties.contentType == "test")
        XCTAssert(String(data: testDecodedPacket.payload!, encoding: .utf8) == "test")
    }
    
    func testDecodingEmpty() {
        let bytes: [UInt8] = [
            48, 7, 0, 4, 116, 101, 115, 116, 0
        ]
        
        let testDecodedPacket = try! PublishPacket(decoder: bytes)!
        
        XCTAssert(testDecodedPacket.dup == false)
        XCTAssert(testDecodedPacket.retain == false)
        XCTAssert(testDecodedPacket.qos == 0)
        XCTAssert(testDecodedPacket.header.topicName == "test")
    }
    
    func testEncodingFilled() {
        let properties = PublishPacket.Header.Property(payloadFormatIndicator: true, messageExpiryInterval: 4321, topicAlias: 100, responseTopic: "topic", correlationData: Data([1, 2, 3, 4]), userProperty: ["test": "test"], subscriptionIdentifier: [120], contentType: "test")
    
        let header = PublishPacket.Header(topicName: "test", identifier: 42, properties: properties)
        let payload = "test".data(using: .utf8)!
        let packet = PublishPacket(dup: false, qos: 2, retain: false, header: header, payload: payload)
        
        let encodedBytes = try! packet.encoded()
        
        let expectedBytes: [UInt8] = [
            52, 60, 0, 4, 116, 101, 115, 116, 0, 42, 47, 1, 1, 2, 0, 0, 16, 225, 35, 0, 100, 8, 0, 5, 116, 111, 112, 105, 99, 9, 0, 4, 1, 2, 3, 4, 38, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116, 11, 120, 3, 0, 4, 116, 101, 115, 116, 116, 101, 115, 116
        ]
        
        XCTAssert(encodedBytes == expectedBytes)
    }
    
    func testEncodingEmpty() {
        let header = PublishPacket.Header(topicName: "test")
        let packet = PublishPacket(dup: false, qos: 0, retain: false, header: header)

        let encodedBytes = try! packet.encoded()

        let expectedBytes: [UInt8] = [
            48, 7, 0, 4, 116, 101, 115, 116, 0
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
