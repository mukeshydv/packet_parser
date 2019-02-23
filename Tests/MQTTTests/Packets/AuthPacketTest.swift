//
//  AuthPacketTest.swift
//  CNIOAtomics
//
//  Created by Mukesh on 22/02/19.
//

import XCTest
@testable import MQTT

class AuthPacketTest: XCTestCase {
    func testDecoding() {
        let bytes: [UInt8] = [
            240, 36, 0, 34, 21, 0, 4, 116, 101, 115, 116, 22, 0, 4, 0, 1, 2, 3, 31, 0, 4, 116, 101, 115, 116, 38, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116
        ]
        
        let testDecodedPacket = try! AuthPacket(decoder: bytes)
        
        XCTAssert(testDecodedPacket.header.reasonCode == .success)
        XCTAssert(testDecodedPacket.header.properties.authenticationMethod == "test")
        XCTAssert(testDecodedPacket.header.properties.reasonString == "test")
        XCTAssert(testDecodedPacket.header.properties.userProperty == ["test": "test"])
        XCTAssert(testDecodedPacket.header.properties.authenticationData == Data([0, 1, 2, 3]))
    }
    
    func testDecodingEmpty() {
        let bytes: [UInt8] = [
            240, 2, 0, 0
        ]
        
        let testDecodedPacket = try! AuthPacket(decoder: bytes)
        
        XCTAssert(testDecodedPacket.header.reasonCode == .success)
        XCTAssert(testDecodedPacket.header.properties.authenticationData == nil)
        XCTAssert(testDecodedPacket.header.properties.reasonString == nil)
        XCTAssert(testDecodedPacket.header.properties.userProperty == nil)
        XCTAssert(testDecodedPacket.header.properties.authenticationMethod == nil)
    }
    
    func testEncodingFilled() {
        let properties = AuthPacket.Header.Property(authenticationMethod: "test", authenticationData: Data([0, 1, 2, 3]), reasonString: "test", userProperty: ["test": "test"])
        let header = AuthPacket.Header(reasonCode: .success, properties: properties)
        
        let packet = AuthPacket(header: header)
        
        let encodedBytes = try! packet.encoded()
        let expectedBytes: [UInt8] = [
            240, 36, 0, 34, 21, 0, 4, 116, 101, 115, 116, 22, 0, 4, 0, 1, 2, 3, 31, 0, 4, 116, 101, 115, 116, 38, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116
        ]
        
        XCTAssert(encodedBytes == expectedBytes)
    }
    
    func testEncodingEmpty() {
        let header = AuthPacket.Header()
        
        let packet = AuthPacket(header: header)
        
        let encodedBytes = try! packet.encoded()
        let expectedBytes: [UInt8] = [
            240, 0
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
