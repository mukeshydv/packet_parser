//
//  UnsubscribePacketTest.swift
//  MQTTTests
//
//  Created by Mukesh on 21/02/19.
//

import XCTest
@testable import MQTT

class UnsubscribePacketTest: XCTestCase {
    func testDecoding() {
        let bytes: [UInt8] = [
            162, 31, 0, 42, 13, 38, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116, 0, 7, 97, 47, 116, 111, 112, 105, 99
        ]
        
        let testDecodedPacket = try! UnsubscribePacket(decoder: bytes)!
        
        XCTAssert(testDecodedPacket.header.identifier == 42)
        XCTAssert(testDecodedPacket.header.properties.userProperty == ["test": "test"])
        XCTAssert(testDecodedPacket.payload == ["test", "a/topic"])
    }
    
    func testDecodingEmpty() {
        let bytes: [UInt8] = [
            162, 18, 0, 42, 0, 0, 4, 116, 101, 115, 116, 0, 7, 97, 47, 116, 111, 112, 105, 99
        ]
        
        let testDecodedPacket = try! UnsubscribePacket(decoder: bytes)!
        
        XCTAssert(testDecodedPacket.header.identifier == 42)
        XCTAssert(testDecodedPacket.header.properties.userProperty == nil)
        XCTAssert(testDecodedPacket.payload == ["test", "a/topic"])
    }
    
    func testEncodingFilled() {
        let properties = UnsubscribePacket.Header.Property(userProperty: ["test": "test"])
        let header = UnsubscribePacket.Header(identifier: 42, properties: properties)
        
        let payload = ["test", "a/topic"]
        let packet = UnsubscribePacket(header: header, payload: payload)
        
        let encodedBytes = try! packet.encoded()
        let expectedBytes: [UInt8] = [
            162, 31, 0, 42, 13, 38, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116, 0, 7, 97, 47, 116, 111, 112, 105, 99
        ]
        
        XCTAssert(encodedBytes == expectedBytes)
    }
    
    func testEncodingEmpty() {
        let header = UnsubscribePacket.Header(identifier: 42)
        
        let payload = ["test", "a/topic"]
        let packet = UnsubscribePacket(header: header, payload: payload)
        
        let encodedBytes = try! packet.encoded()
        let expectedBytes: [UInt8] = [
            162, 18, 0, 42, 0, 0, 4, 116, 101, 115, 116, 0, 7, 97, 47, 116, 111, 112, 105, 99
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
