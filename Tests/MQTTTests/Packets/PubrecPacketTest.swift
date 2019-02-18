//
//  PubrecPacketTest.swift
//  MQTTTests
//
//  Created by Mukesh on 18/02/19.
//

import XCTest
@testable import MQTT

class PubrecPacketTest: XCTestCase {
    func testDecoding() {
        let bytes: [UInt8] = [
            80, 24, 0, 42, 16, 20, 31, 0, 4, 116, 101, 115, 116, 38, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116
        ]
        
        let testDecodedPacket = try! PubrecPacket(decoder: bytes)!
        
        XCTAssert(testDecodedPacket.header.identifier == 42)
        XCTAssert(testDecodedPacket.header.reasonCode == .noMatchingSubscribers)
        XCTAssert(testDecodedPacket.header.properties.reasonString == "test")
        XCTAssert(testDecodedPacket.header.properties.userProperty == ["test": "test"])
    }
    
    func testDecodingEmpty() {
        let bytes: [UInt8] = [
            80, 3, 0, 42, 16
        ]
        
        let testDecodedPacket = try! PubrecPacket(decoder: bytes)!
        
        XCTAssert(testDecodedPacket.header.identifier == 42)
        XCTAssert(testDecodedPacket.header.reasonCode == .noMatchingSubscribers)
    }
    
    func testDecodingSuccessEmpty() {
        let bytes: [UInt8] = [
            80, 2, 0, 42
        ]
        
        let testDecodedPacket = try! PubrecPacket(decoder: bytes)!
        
        XCTAssert(testDecodedPacket.header.identifier == 42)
        XCTAssert(testDecodedPacket.header.reasonCode == .success)
    }
    
    func testEncodingFilled() {
        let properties = PubrecPacket.Header.Property(reasonString: "test", userProperty: ["test": "test"])
        let header = PubrecPacket.Header(identifier: 42, reasonCode: .noMatchingSubscribers, properties: properties)
        let packet = PubrecPacket(header: header)
        
        let encodedBytes = try! packet.encoded()
        let expectedBytes: [UInt8] = [
            80, 24, 0, 42, 16, 20, 31, 0, 4, 116, 101, 115, 116, 38, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116
        ]
        
        XCTAssert(encodedBytes == expectedBytes)
    }
    
    func testEncodingEmpty() {
        let header = PubrecPacket.Header(identifier: 42, reasonCode: .noMatchingSubscribers)
        let packet = PubrecPacket(header: header)
        
        let encodedBytes = try! packet.encoded()
        let expectedBytes: [UInt8] = [
            80, 4, 0, 42, 16, 0
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
