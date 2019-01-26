//
//  RequestEncoderTests.swift
//  CNIOAtomics
//
//  Created by Mukesh on 25/01/19.
//

import XCTest
@testable import MQTT

final class RequestEncoderTests: XCTestCase {
    func testEncoding() {
        let properties = ConnectPacketQualities(sessionExpiryInterval: 10)
        let connectPacket = ConnectPacket(username: true, password: true, willRetain: false, willQos: 1, willMessage: true, cleanStart: true, keepAlive: 0x000A, properties: properties)
        let request = MQTTRequestMessage.connect(connectPacket)
        
        let encoded = request.encoded
        let result: [UInt8] = [16, 31, 0, 4, 77, 81, 84, 84, 5, 206, 0, 10, 20, 17, 0, 0, 0, 10, 33, 255, 255, 39, 255, 255, 255, 255, 34, 0, 0, 25, 0, 23, 1]
        
        XCTAssert(result == encoded, "Encoding failed")
    }
    
    static var allTests = [
        ("testEncoding", testEncoding),
        ]
}
