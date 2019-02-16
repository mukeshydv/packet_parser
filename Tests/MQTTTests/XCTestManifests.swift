import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(MQTTTests.allTests),
        testCase(DataTypesTests.allTests),
        testCase(ConnectPacketTest.allTests),
        testCase(ConnackPacketTest.allTests)
    ]
}
#endif
