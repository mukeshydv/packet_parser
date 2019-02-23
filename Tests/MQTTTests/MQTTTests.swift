import XCTest
import NIO
@testable import MQTT

final class MQTTTests: XCTestCase {
    func testExample() {
        let decoder = MQTTDecoder()
        
        decoder.completionHandler = { (packet) in
            switch packet {
                
            case .connect(let packet):
                self.validate(connect: packet)
            case .auth(_):
                break
            case .connack(_):
                break
            case .disconnect(_):
                break
            case .pingReq(_):
                break
            case .pingResp(_):
                break
            case .puback(_):
                break
            case .pubcomp(_):
                break
            case .publish(_):
                break
            case .pubrec(_):
                break
            case .pubrel(_):
                break
            case .suback(let packet):
                self.validate(suback: packet)
            case .subscribe(_):
                break
            case .unsuback(_):
                break
            case .unsubscribe(_):
                break
            }
        }
        
        var buffer = ByteBufferAllocator().buffer(capacity: 1024)
        
        try! decoder.decode(&buffer)
        
        buffer.write(bytes: [16, 143, 1, 0, 4, 77, 81, 84, 84, 5, 198, 0, 0, 47, 17, 0, 0, 4, 210, 33, 1, 176, 39, 0, 0, 0, 100, 34, 1, 200, 25, 1, 23, 1, 38, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116, 21, 0, 4, 116, 101, 115, 116, 22, 0, 4, 1, 2, 3, 4, 0])
        
        try! decoder.decode(&buffer)
        
        buffer.write(bytes: [9, 109, 121, 45, 100, 101, 118, 105, 99, 101, 47, 24, 0, 0, 4, 210, 1, 0, 2, 0, 0, 16, 225, 3, 0, 4, 116, 101, 115, 116, 8, 0, 5, 116, 111, 112, 105, 99, 9, 0, 4, 1, 2, 3, 4, 38, 0, 4, 116, 101, 115, 116, 0, 4, 116, 101, 115, 116, 0, 2])
        
        try! decoder.decode(&buffer)
        
        buffer.write(bytes: [97, 98, 0, 4, 100, 101, 97, 100, 0, 6, 109, 117, 107, 101, 115, 104, 0, 6, 109, 117, 107, 101, 115, 104, 144, 4, 0, 42, 0, 0])
        
        try! decoder.decode(&buffer)
    }

    private func validate(connect: ConnectPacket) {
        XCTAssert(connect.protocolName == "MQTT")
        XCTAssert(connect.flags.cleanStart)
        XCTAssert(connect.payload.clientId == "my-device")
        XCTAssert(connect.keepAlive == 0)
        XCTAssert(connect.payload.username == "mukesh")
        XCTAssert(connect.flags.username)
        XCTAssert(String(data: connect.payload.password!, encoding: .utf8) == "mukesh")
        XCTAssert(connect.flags.password)
        XCTAssert(connect.payload.willTopic == "ab")
        XCTAssert(String(data: connect.payload.willPayload!, encoding: .utf8) == "dead")
        XCTAssert(connect.payload.willProperties?.delayInterval == 1234)
        XCTAssert(connect.payload.willProperties?.payloadFormatIndicator == false)
        XCTAssert(connect.payload.willProperties?.messageExpiryInterval == 4321)
        XCTAssert(connect.payload.willProperties?.contentType == "test")
        XCTAssert(connect.payload.willProperties?.responseTopic == "topic")
        XCTAssert(connect.payload.willProperties?.correlationData!.array == [1, 2, 3, 4])
        XCTAssert(connect.payload.willProperties?.userProperty == ["test": "test"])
        XCTAssert(connect.properties.sessionExpiryInterval == 1234)
        XCTAssert(connect.properties.receiveMaximum == 432)
        XCTAssert(connect.properties.maximumPacketSize == 100)
        XCTAssert(connect.properties.topicAliasMaximum == 456)
        XCTAssert(connect.properties.requestResponseInformation == true)
        XCTAssert(connect.properties.requestProblemInformation == true)
        XCTAssert(connect.properties.userProperty == ["test": "test"])
        XCTAssert(connect.properties.authenticationMethod == "test")
        XCTAssert(connect.properties.authenticationData!.array == [1, 2, 3, 4])
    }
    
    private func validate(suback: SubackPacket) {
        XCTAssert(suback.header.identifier == 42)
        XCTAssert(suback.payload == [.success])
    }
    
    static var allTests = [
        ("testExample", testExample),
    ]
}
