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
            0x30, 0x07, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x00
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
            0x34, 0x3c, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x00, 0x2a, 0x2f, 0x01, 0x01, 0x02, 0x00, 0x00, 0x10, 0xe1, 0x23, 0x00, 0x64, 0x08, 0x00, 0x05, 0x74, 0x6f, 0x70, 0x69, 0x63, 0x09, 0x00, 0x04, 0x01, 0x02, 0x03, 0x04, 0x26, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x0b, 0x78, 0x03, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x74, 0x65, 0x73, 0x74
        ]
        
        XCTAssert(encodedBytes == expectedBytes)
    }
    
    func testEncodingEmpty() {
        let header = PublishPacket.Header(topicName: "test")
        let packet = PublishPacket(dup: false, qos: 0, retain: false, header: header)

        let encodedBytes = try! packet.encoded()

        let expectedBytes: [UInt8] = [
            0x30, 0x07, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x00
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
