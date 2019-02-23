//
//  UnsubackPacketTest.swift
//  MQTTTests
//
//  Created by Mukesh on 21/02/19.
//

import XCTest
@testable import MQTT

class UnsubackPacketTest: XCTestCase {
    func testDecoding() {
        let bytes: [UInt8] = [
            176, 25, 0, 42, 20, 31, 0, 4, 116, 101, 115, 116, 38, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116, 0, 128
        ]
        
        let testDecodedPacket = try! UnsubackPacket(decoder: bytes)
        
        XCTAssert(testDecodedPacket.header.identifier == 42)
        XCTAssert(testDecodedPacket.header.properties.reasonString == "test")
        XCTAssert(testDecodedPacket.header.properties.userProperty == ["test": "test"])
        XCTAssert(testDecodedPacket.payload == [.success, .unspecifiedError])
    }
    
    func testDecodingEmpty() {
        let bytes: [UInt8] = [
            176, 5, 0, 42, 0, 0, 128
        ]
        
        let testDecodedPacket = try! UnsubackPacket(decoder: bytes)
        
        XCTAssert(testDecodedPacket.header.identifier == 42)
        XCTAssert(testDecodedPacket.header.properties.reasonString == nil)
        XCTAssert(testDecodedPacket.header.properties.userProperty == nil)
        XCTAssert(testDecodedPacket.payload == [.success, .unspecifiedError])
    }
    
    func testEncodingFilled() {
        let properties = UnsubackPacket.Header.Property(reasonString: "test", userProperty: ["test": "test"])
        let header = UnsubackPacket.Header(identifier: 42, properties: properties)
        
        let payload = [ReasonCode.success, .unspecifiedError]
        let packet = UnsubackPacket(header: header, payload: payload)
        
        let encodedBytes = try! packet.encoded()
        let expectedBytes: [UInt8] = [
            176, 25, 0, 42, 20, 31, 0, 4, 116, 101, 115, 116, 38, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116, 0, 128
        ]
        
        XCTAssert(encodedBytes == expectedBytes)
    }
    
    func testEncodingEmpty() {
        let header = UnsubackPacket.Header(identifier: 42)
        
        let payload = [ReasonCode.success, .unspecifiedError]
        let packet = UnsubackPacket(header: header, payload: payload)
        
        let encodedBytes = try! packet.encoded()
        let expectedBytes: [UInt8] = [
            176, 5, 0, 42, 0, 0, 128
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
