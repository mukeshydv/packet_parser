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
        print(encoded)
        let result: [UInt8] = [16, 31, 0, 4, 77, 81, 84, 84, 5, 206, 0, 10, 20, 17, 0, 0, 0, 10, 33, 255, 255, 39, 255, 255, 255, 255, 34, 0, 0, 25, 0, 23, 1]
        
        XCTAssert(result == encoded, "Encoding failed")
        
        let decodedPacket = try! ConnectPacket(decoder: encoded)
        XCTAssert(decodedPacket.cleanStart == connectPacket.cleanStart, "Decoding failed")
        XCTAssert(decodedPacket.username == connectPacket.username, "Decoding failed")
        XCTAssert(decodedPacket.willQos == connectPacket.willQos, "Decoding failed")
        XCTAssert(decodedPacket.keepAlive == connectPacket.keepAlive, "Decoding failed")
        XCTAssert(decodedPacket.password == connectPacket.password, "Decoding failed")
        XCTAssert(decodedPacket.protocolName == connectPacket.protocolName, "Decoding failed")
        XCTAssert(decodedPacket.willMessage == connectPacket.willMessage, "Decoding failed")
        XCTAssert(decodedPacket.willRetain == connectPacket.willRetain, "Decoding failed")
        
        XCTAssert(decodedPacket.properties.sessionExpiryInterval == connectPacket.properties.sessionExpiryInterval, "Decoding failed")
        XCTAssert(decodedPacket.properties.authenticationData == connectPacket.properties.authenticationData, "Decoding failed")
        XCTAssert(decodedPacket.properties.authenticationMethod == connectPacket.properties.authenticationMethod, "Decoding failed")
        XCTAssert(decodedPacket.properties.maximumPacketSize == connectPacket.properties.maximumPacketSize, "Decoding failed")
        XCTAssert(decodedPacket.properties.receiveMaximum == connectPacket.properties.receiveMaximum, "Decoding failed")
        XCTAssert(decodedPacket.properties.requestProblemInformation == connectPacket.properties.requestProblemInformation, "Decoding failed")
        XCTAssert(decodedPacket.properties.requestResponseInformation == connectPacket.properties.requestResponseInformation, "Decoding failed")
        XCTAssert(decodedPacket.properties.topicAliasMaximum == connectPacket.properties.topicAliasMaximum, "Decoding failed")
    }
    
    static var allTests = [
        ("testEncoding", testEncoding),
        ]
}
