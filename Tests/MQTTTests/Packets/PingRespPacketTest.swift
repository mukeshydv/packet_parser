//
//  PingRespPacketTest.swift
//  CNIOAtomics
//
//  Created by Mukesh on 22/02/19.
//

import XCTest
@testable import MQTT

class PingRespPacketTest: XCTestCase {
    func testDecoding() {
        let bytes: [UInt8] = [
            208, 0
        ]
        
        let testDecodedPacket = try! PingRespPacket(decoder: bytes)
        XCTAssert(testDecodedPacket != nil)
    }
    
    func testEncodingEmpty() {
        let packet = PingRespPacket()
        
        let encodedBytes = try! packet.encoded()
        let expectedBytes: [UInt8] = [
            208, 0
        ]
        
        XCTAssert(encodedBytes == expectedBytes)
    }
    
    static var allTests = [
        ("testEncodingEmpty", testEncodingEmpty),
        ("testDecoding", testDecoding),
        ]
}
