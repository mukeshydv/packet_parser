//
//  ConnectPacket.swift
//  MQTTTests
//
//  Created by Mukesh on 16/02/19.
//

import XCTest
@testable import MQTT

class ConnectPacketTest: XCTestCase {
    func testDecoding() {
        let bytes: [UInt8] = [
            16, 143, 1, 0, 4, 77, 81, 84, 84, 5, 198, 0, 0, 47, 17, 0, 0, 4, 210, 33, 1, 176, 39, 0, 0, 0, 100, 34, 1, 200, 25, 1, 23, 1, 38, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116, 21, 0, 4, 116, 101, 115, 116, 22, 0, 4, 1, 2, 3, 4, 0, 9, 109, 121, 45, 100, 101, 118, 105, 99, 101, 47, 24, 0, 0, 4, 210, 1, 0, 2, 0, 0, 16, 225, 3, 0, 4, 116, 101, 115, 116, 8, 0, 5, 116, 111, 112, 105, 99, 9, 0, 4, 1, 2, 3, 4, 38, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116, 0, 2, 97, 98, 0, 4, 100, 101, 97, 100, 0, 6, 109, 117, 107, 101, 115, 104, 0, 6, 109, 117, 107, 101, 115, 104
        ]
        
        let testDecodedPacket = try! ConnectPacket(decoder: bytes)
        
        XCTAssert(testDecodedPacket.protocolName == "MQTT")
        XCTAssert(testDecodedPacket.flags.cleanStart)
        XCTAssert(testDecodedPacket.payload.clientId == "my-device")
        XCTAssert(testDecodedPacket.keepAlive == 0)
        XCTAssert(testDecodedPacket.payload.username == "mukesh")
        XCTAssert(testDecodedPacket.flags.username)
        XCTAssert(String(data: testDecodedPacket.payload.password!, encoding: .utf8) == "mukesh")
        XCTAssert(testDecodedPacket.flags.password)
        XCTAssert(testDecodedPacket.payload.willTopic == "ab")
        XCTAssert(String(data: testDecodedPacket.payload.willPayload!, encoding: .utf8) == "dead")
        XCTAssert(testDecodedPacket.payload.willProperties?.delayInterval == 1234)
        XCTAssert(testDecodedPacket.payload.willProperties?.payloadFormatIndicator == false)
        XCTAssert(testDecodedPacket.payload.willProperties?.messageExpiryInterval == 4321)
        XCTAssert(testDecodedPacket.payload.willProperties?.contentType == "test")
        XCTAssert(testDecodedPacket.payload.willProperties?.responseTopic == "topic")
        XCTAssert(testDecodedPacket.payload.willProperties?.correlationData!.array == [1, 2, 3, 4])
        XCTAssert(testDecodedPacket.payload.willProperties?.userProperty == ["test": "test"])
        XCTAssert(testDecodedPacket.properties.sessionExpiryInterval == 1234)
        XCTAssert(testDecodedPacket.properties.receiveMaximum == 432)
        XCTAssert(testDecodedPacket.properties.maximumPacketSize == 100)
        XCTAssert(testDecodedPacket.properties.topicAliasMaximum == 456)
        XCTAssert(testDecodedPacket.properties.requestResponseInformation == true)
        XCTAssert(testDecodedPacket.properties.requestProblemInformation == true)
        XCTAssert(testDecodedPacket.properties.userProperty == ["test": "test"])
        XCTAssert(testDecodedPacket.properties.authenticationMethod == "test")
        XCTAssert(testDecodedPacket.properties.authenticationData!.array == [1, 2, 3, 4])
    }
    
    func testEncoding() {
        let properties = ConnectPacket.Header(
            sessionExpiryInterval: 10,
            userProperty: ["key": "value"],
            authenticationMethod: "authMethod",
            authenticationData: Data([0, 2, 43])
        )
        let flags = ConnectPacket.Flags(username: true, password: true, willRetain: false, willQos: 1, willFlag: true, cleanStart: true)
        let willProperties = ConnectPacket.Payload.Properties(
            delayInterval: 123,
            payloadFormatIndicator: false,
            messageExpiryInterval: 23875,
            contentType: "application/json",
            responseTopic: "sampleTopic",
            correlationData: Data([78, 43]),
            userProperty: ["test": "user3"]
        )
        let payload = ConnectPacket.Payload(clientId: "", willProperties: willProperties, willTopic: "topic",
                                            willPayload: Data([1, 2]), username: "test", password: Data([4,5]))
        let connectPacket = ConnectPacket(flags: flags, keepAlive: 0x000A, properties: properties, payload: payload)
        let request = MQTTRequestMessage.connect(connectPacket)
        
        let encoded = request.encoded
        
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
        XCTAssert(decodedPacket.properties.userProperty == connectPacket.properties.userProperty, "Decoding failed")
        XCTAssert(decodedPacket.properties.authenticationMethod == connectPacket.properties.authenticationMethod, "Decoding failed")
        XCTAssert(decodedPacket.properties.authenticationData == connectPacket.properties.authenticationData, "Decoding failed")
        
        XCTAssert(decodedPacket.payload.clientId == connectPacket.payload.clientId, "Decoding failed")
        XCTAssert(decodedPacket.payload.username == connectPacket.payload.username, "Decoding failed")
        XCTAssert(decodedPacket.payload.password == connectPacket.payload.password, "Decoding failed")
        XCTAssert(decodedPacket.payload.willTopic == connectPacket.payload.willTopic, "Decoding failed")
        
        XCTAssert(decodedPacket.payload.willProperties?.delayInterval == connectPacket.payload.willProperties?.delayInterval, "Decoding failed")
        XCTAssert(decodedPacket.payload.willProperties?.payloadFormatIndicator == connectPacket.payload.willProperties?.payloadFormatIndicator, "Decoding failed")
        XCTAssert(decodedPacket.payload.willProperties?.contentType == connectPacket.payload.willProperties?.contentType, "Decoding failed")
        XCTAssert(decodedPacket.payload.willProperties?.correlationData == connectPacket.payload.willProperties?.correlationData, "Decoding failed")
        XCTAssert(decodedPacket.payload.willProperties?.messageExpiryInterval == connectPacket.payload.willProperties?.messageExpiryInterval, "Decoding failed")
        XCTAssert(decodedPacket.payload.willProperties?.responseTopic == connectPacket.payload.willProperties?.responseTopic, "Decoding failed")
        XCTAssert(decodedPacket.payload.willProperties?.userProperty == connectPacket.payload.willProperties?.userProperty, "Decoding failed")
    }
    
    static var allTests = [
        ("testEncoding", testEncoding),
        ("testDecoding", testDecoding),
    ]
}
