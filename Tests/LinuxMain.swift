import XCTest

import MQTTTests

var tests = [XCTestCaseEntry]()
tests += MQTTTests.allTests()
XCTMain(tests)
