import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(MQTTTests.allTests),
        testCase(RequestEncoderTests.allTests),
        testCase(DataTypesTests.allTests),
        testCase(RequestDecoderTests.allTests)
    ]
}
#endif
