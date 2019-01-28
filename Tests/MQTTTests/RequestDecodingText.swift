//
//  RequestDecodingText.swift
//  MQTTTests
//
//  Created by Mukesh on 28/01/19.
//

import XCTest
@testable import MQTT

final class RequestDecoderTests: XCTestCase {
    func testDecoding() {
        let bytes: [UInt8] = [
            0x10, 0x90, 0x01, 0x00, 0x04, 0x4d, 0x51, 0x54, 0x54, 0x05, 0xc6, 0x00, 0x00, 0x2f, 0x11, 0x00, 0x00, 0x04, 0xd2, 0x21, 0x01, 0xb0, 0x27, 0x00, 0x00, 0x00, 0x64, 0x22, 0x01, 0xc8, 0x19, 0x01, 0x17, 0x01, 0x26, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x15, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x16, 0x00, 0x04, 0x01, 0x02, 0x03, 0x04, 0x00, 0x09, 0x6d, 0x79, 0x2d, 0x64, 0x65, 0x76, 0x69, 0x63, 0x65, 0x2f, 0x18, 0x00, 0x00, 0x04, 0xd2, 0x01, 0x00, 0x02, 0x00, 0x00, 0x10, 0xe1, 0x03, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x08, 0x00, 0x05, 0x74, 0x6f, 0x70, 0x69, 0x63, 0x09, 0x00, 0x04, 0x01, 0x02, 0x03, 0x04, 0x26, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x00, 0x04, 0x74, 0x65, 0x73, 0x74, 0x00, 0x02, 0x61, 0x62, 0x00, 0x04, 0x64, 0x65, 0x61, 0x64, 0x00, 0x06, 0x6d, 0x61, 0x74, 0x74, 0x65, 0x6f, 0x00, 0x07, 0x63, 0x6f, 0x6c, 0x6c, 0x69, 0x6e, 0x61
        ]
        
        let testDecodedPacket = try! ConnectPacket(decoder: bytes)
        print(testDecodedPacket)
        
        XCTAssert(testDecodedPacket.protocolName == "MQTT")
        XCTAssert(testDecodedPacket.flags.cleanStart)
        XCTAssert(testDecodedPacket.payload.clientId == "my-device")
        XCTAssert(testDecodedPacket.keepAlive == 0)
        XCTAssert(testDecodedPacket.payload.username == "matteo")
        XCTAssert(testDecodedPacket.flags.username)
        XCTAssert(testDecodedPacket.flags.password)
        XCTAssert(testDecodedPacket.payload.willTopic == "ab")
        XCTAssert(testDecodedPacket.payload.willPayload != nil)
        XCTAssert(testDecodedPacket.payload.willProperties?.delayInterval == 1234)
        XCTAssert(testDecodedPacket.payload.willProperties?.payloadFormatIndicator == false)
        XCTAssert(testDecodedPacket.payload.willProperties?.messageExpiryInterval == 4321)
        XCTAssert(testDecodedPacket.payload.willProperties?.contentType == "test")
        XCTAssert(testDecodedPacket.payload.willProperties?.responseTopic == "topic")
        XCTAssert(testDecodedPacket.payload.willProperties?.correlationData != nil)
        XCTAssert(testDecodedPacket.payload.willProperties?.userProperty == ["test": "test"])
        XCTAssert(testDecodedPacket.properties.sessionExpiryInterval == 1234)
        XCTAssert(testDecodedPacket.properties.receiveMaximum == 432)
        XCTAssert(testDecodedPacket.properties.maximumPacketSize == 100)
        XCTAssert(testDecodedPacket.properties.topicAliasMaximum == 456)
        XCTAssert(testDecodedPacket.properties.requestResponseInformation == true)
        XCTAssert(testDecodedPacket.properties.requestProblemInformation == true)
        XCTAssert(testDecodedPacket.properties.userProperty == ["test": "test"])
        XCTAssert(testDecodedPacket.properties.authenticationMethod == "test")
        XCTAssert(testDecodedPacket.properties.authenticationData != nil)
        
    }
    
    static var allTests = [
        ("testEncoding", testDecoding),
        ]
}
