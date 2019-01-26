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
        let flags = ConnectPacketFlag(username: true, password: true, willRetain: false, willQos: 1, willFlag: true, cleanStart: true)
        let willProperties = WillProperties(delayInterval: 123)
        let payload = ConnectPayload(clientId: "", willProperties: willProperties, willTopic: "topic",
                                     willPayload: Data([1, 2]), username: "test", password: Data([4,5]))
        let connectPacket = ConnectPacket(flags: flags, keepAlive: 0x000A, properties: properties, payload: payload)
        let request = MQTTRequestMessage.connect(connectPacket)
        
        let encoded = request.encoded
        print(encoded)
        
        let decodedPacket = try! ConnectPacket(decoder: encoded)
        XCTAssert(decodedPacket.flags.cleanStart == connectPacket.flags.cleanStart, "Decoding failed")
        XCTAssert(decodedPacket.flags.username == connectPacket.flags.username, "Decoding failed")
        XCTAssert(decodedPacket.flags.willQos == connectPacket.flags.willQos, "Decoding failed")
        XCTAssert(decodedPacket.keepAlive == connectPacket.keepAlive, "Decoding failed")
        XCTAssert(decodedPacket.flags.password == connectPacket.flags.password, "Decoding failed")
        XCTAssert(decodedPacket.protocolName == connectPacket.protocolName, "Decoding failed")
        XCTAssert(decodedPacket.flags.willFlag == connectPacket.flags.willFlag, "Decoding failed")
        XCTAssert(decodedPacket.flags.willRetain == connectPacket.flags.willRetain, "Decoding failed")
        
        XCTAssert(decodedPacket.properties.sessionExpiryInterval == connectPacket.properties.sessionExpiryInterval, "Decoding failed")
        XCTAssert(decodedPacket.properties.authenticationData == connectPacket.properties.authenticationData, "Decoding failed")
        XCTAssert(decodedPacket.properties.authenticationMethod == connectPacket.properties.authenticationMethod, "Decoding failed")
        XCTAssert(decodedPacket.properties.maximumPacketSize == connectPacket.properties.maximumPacketSize, "Decoding failed")
        XCTAssert(decodedPacket.properties.receiveMaximum == connectPacket.properties.receiveMaximum, "Decoding failed")
        XCTAssert(decodedPacket.properties.requestProblemInformation == connectPacket.properties.requestProblemInformation, "Decoding failed")
        XCTAssert(decodedPacket.properties.requestResponseInformation == connectPacket.properties.requestResponseInformation, "Decoding failed")
        XCTAssert(decodedPacket.properties.topicAliasMaximum == connectPacket.properties.topicAliasMaximum, "Decoding failed")
        
        XCTAssert(decodedPacket.payload.clientId == connectPacket.payload.clientId, "Decoding failed")
        XCTAssert(decodedPacket.payload.username == connectPacket.payload.username, "Decoding failed")
        XCTAssert(decodedPacket.payload.password == connectPacket.payload.password, "Decoding failed")
        XCTAssert(decodedPacket.payload.willTopic == connectPacket.payload.willTopic, "Decoding failed")
        
        XCTAssert(decodedPacket.payload.willProperties?.delayInterval == connectPacket.payload.willProperties?.delayInterval, "Decoding failed")
        XCTAssert(decodedPacket.payload.willProperties?.payloadFormatIndicator == connectPacket.payload.willProperties?.payloadFormatIndicator, "Decoding failed")
    }
    
    static var allTests = [
        ("testEncoding", testEncoding),
        ]
}
