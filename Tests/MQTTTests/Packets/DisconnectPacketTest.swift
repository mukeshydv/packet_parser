//
//  DisconnectPacketTest.swift
//  MQTTTests
//
//  Created by Mukesh on 21/02/19.
//

import XCTest
@testable import MQTT

class DisconnectPacketTest: XCTestCase {
    func testDecoding() {
        let bytes: [UInt8] = [
            224, 34, 0, 32, 17, 0, 0, 0, 145, 31, 0, 4, 116, 101, 115, 116, 38, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116, 28, 0, 4, 116, 101, 115, 116
        ]
        
        let testDecodedPacket = try! DisconnectPacket(decoder: bytes)
        
        XCTAssert(testDecodedPacket.header.reasonCode == .success)
        XCTAssert(testDecodedPacket.header.properties.sessionExpiryInterval == 145)
        XCTAssert(testDecodedPacket.header.properties.reasonString == "test")
        XCTAssert(testDecodedPacket.header.properties.userProperty == ["test": "test"])
        XCTAssert(testDecodedPacket.header.properties.serverReference == "test")
    }
    
    func testDecodingEmpty() {
        let bytes: [UInt8] = [
            224, 2, 0, 0
        ]
        
        let testDecodedPacket = try! DisconnectPacket(decoder: bytes)
        
        XCTAssert(testDecodedPacket.header.reasonCode == .success)
        XCTAssert(testDecodedPacket.header.properties.sessionExpiryInterval == nil)
        XCTAssert(testDecodedPacket.header.properties.reasonString == nil)
        XCTAssert(testDecodedPacket.header.properties.userProperty == nil)
        XCTAssert(testDecodedPacket.header.properties.serverReference == nil)
    }
    
    func testEncodingFilled() {
        let properties = DisconnectPacket.Header.Property(sessionExpiryInterval: 145, reasonString: "test", userProperty: ["test": "test"], serverReference: "test")
        let header = DisconnectPacket.Header(reasonCode: .success, properties: properties)
        
        let packet = DisconnectPacket(header: header)
        
        let encodedBytes = try! packet.encoded()
        let expectedBytes: [UInt8] = [
            224, 34, 0, 32, 17, 0, 0, 0, 145, 31, 0, 4, 116, 101, 115, 116, 38, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116, 28, 0, 4, 116, 101, 115, 116
        ]
        
        XCTAssert(encodedBytes == expectedBytes)
    }
    
    func testEncodingEmpty() {
        let header = DisconnectPacket.Header()
        
        let packet = DisconnectPacket(header: header)
        
        let encodedBytes = try! packet.encoded()
        let expectedBytes: [UInt8] = [
            224, 0
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
