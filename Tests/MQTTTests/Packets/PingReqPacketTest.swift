//
//  PingReqPacketTest.swift
//  CNIOAtomics
//
//  Created by Mukesh on 22/02/19.
//

import XCTest
@testable import MQTT

class PingReqPacketTest: XCTestCase {
    func testDecoding() {
        let bytes: [UInt8] = [
            192, 0
        ]
        
        let _ = try! PingReqPacket(decoder: bytes)
        XCTAssert(true)
    }
    
    func testEncodingEmpty() {
        let packet = PingReqPacket()
        
        let encodedBytes = try! packet.encoded()
        let expectedBytes: [UInt8] = [
            192, 0
        ]
        
        XCTAssert(encodedBytes == expectedBytes)
    }
    
    static var allTests = [
        ("testEncodingEmpty", testEncodingEmpty),
        ("testDecoding", testDecoding),
        ]
}
