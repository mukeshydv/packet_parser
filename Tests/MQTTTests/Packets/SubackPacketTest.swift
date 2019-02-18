//
//  SubackPacketTest.swift
//  MQTTTests
//
//  Created by Mukesh on 18/02/19.
//

import XCTest
@testable import MQTT

class SubackPacketTest: XCTestCase {
    func testDecoding() {
        let bytes: [UInt8] = [
            144, 27, 0, 42, 20, 31, 0, 4, 116, 101, 115, 116, 38, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116, 0, 1, 2, 128
        ]
        
        let testDecodedPacket = try! SubackPacket(decoder: bytes)!
        
        XCTAssert(testDecodedPacket.header.identifier == 42)
        XCTAssert(testDecodedPacket.header.properties.reasonString == "test")
        XCTAssert(testDecodedPacket.header.properties.userProperty == ["test": "test"])
        XCTAssert(testDecodedPacket.payload == [.success, .grantQos1, .grantQos2, .unspecifiedError])
    }
    
    func testDecodingEmpty() {
        let bytes: [UInt8] = [
            144, 4, 0, 42, 0, 0
        ]
        
        let testDecodedPacket = try! SubackPacket(decoder: bytes)!
        
        XCTAssert(testDecodedPacket.header.identifier == 42)
        XCTAssert(testDecodedPacket.payload == [.success])
    }
    
    func testEncodingFilled() {
        let properties = SubackPacket.Header.Property(reasonString: "test", userProperty: ["test": "test"])
        let header = SubackPacket.Header(identifier: 42, properties: properties)
        let packet = SubackPacket(header: header, payload: [.success, .grantQos1, .grantQos2, .unspecifiedError])
        
        let encodedBytes = try! packet.encoded()
        let expectedBytes: [UInt8] = [
            144, 27, 0, 42, 20, 31, 0, 4, 116, 101, 115, 116, 38, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116, 0, 1, 2, 128
        ]
        
        XCTAssert(encodedBytes == expectedBytes)
    }
    
    func testEncodingEmpty() {
        let header = SubackPacket.Header(identifier: 42)
        let packet = SubackPacket(header: header, payload: [.success])
        
        let encodedBytes = try! packet.encoded()
        let expectedBytes: [UInt8] = [
            144, 4, 0, 42, 0, 0
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
