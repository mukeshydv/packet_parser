//
//  PubrelPacketTest.swift
//  MQTTTests
//
//  Created by Mukesh on 18/02/19.
//

import XCTest
@testable import MQTT

class PubrelPacketTest: XCTestCase {
    func testDecoding() {
        let bytes: [UInt8] = [
            98, 24, 0, 42, 16, 20, 31, 0, 4, 116, 101, 115, 116, 38, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116
        ]
        
        let testDecodedPacket = try! PubrelPacket(decoder: bytes)!
        
        XCTAssert(testDecodedPacket.header.identifier == 42)
        XCTAssert(testDecodedPacket.header.reasonCode == .noMatchingSubscribers)
        XCTAssert(testDecodedPacket.header.properties.reasonString == "test")
        XCTAssert(testDecodedPacket.header.properties.userProperty == ["test": "test"])
    }
    
    func testDecodingEmpty() {
        let bytes: [UInt8] = [
            98, 3, 0, 42, 16
        ]
        
        let testDecodedPacket = try! PubrelPacket(decoder: bytes)!
        
        XCTAssert(testDecodedPacket.header.identifier == 42)
        XCTAssert(testDecodedPacket.header.reasonCode == .noMatchingSubscribers)
    }
    
    func testDecodingSuccessEmpty() {
        let bytes: [UInt8] = [
            98, 2, 0, 42
        ]
        
        let testDecodedPacket = try! PubrelPacket(decoder: bytes)!
        
        XCTAssert(testDecodedPacket.header.identifier == 42)
        XCTAssert(testDecodedPacket.header.reasonCode == .success)
    }
    
    func testEncodingFilled() {
        let properties = PubrelPacket.Header.Property(reasonString: "test", userProperty: ["test": "test"])
        let header = PubrelPacket.Header(identifier: 42, reasonCode: .noMatchingSubscribers, properties: properties)
        let packet = PubrelPacket(header: header)
        
        let encodedBytes = try! packet.encoded()
        let expectedBytes: [UInt8] = [
            98, 24, 0, 42, 16, 20, 31, 0, 4, 116, 101, 115, 116, 38, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116
        ]
        
        XCTAssert(encodedBytes == expectedBytes)
    }
    
    func testEncodingEmpty() {
        let header = PubrelPacket.Header(identifier: 42, reasonCode: .noMatchingSubscribers)
        let packet = PubrelPacket(header: header)
        
        let encodedBytes = try! packet.encoded()
        let expectedBytes: [UInt8] = [
            98, 3, 0, 42, 16
        ]
        
        XCTAssert(encodedBytes == expectedBytes)
    }
    
    static var allTests = [
        ("testEncodingEmpty", testEncodingEmpty),
        ("testEncodingFilled", testEncodingFilled),
        ("testDecoding", testDecoding),
        ("testDecodingEmpty", testDecodingEmpty),
        ("testDecodingSuccessEmpty", testDecodingSuccessEmpty),
    ]
}
