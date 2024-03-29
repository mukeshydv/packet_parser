import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(MQTTTests.allTests),
        testCase(DataTypesTests.allTests),
        testCase(ConnectPacketTest.allTests),
        testCase(ConnackPacketTest.allTests),
        testCase(PublishPacketTests.allTests),
        testCase(PubackPacketTest.allTests),
        testCase(PubrecPacketTest.allTests),
        testCase(PubrelPacketTest.allTests),
        testCase(PubcompPacketTest.allTests),
        testCase(SubscribePacketTest.allTests),
        testCase(SubackPacketTest.allTests),
        testCase(UnsubscribePacketTest.allTests),
        testCase(UnsubackPacketTest.allTests),
        testCase(DisconnectPacketTest.allTests),
        testCase(AuthPacketTest.allTests),
        testCase(PingReqPacketTest.allTests),
        testCase(PingRespPacketTest.allTests)
    ]
}
#endif
