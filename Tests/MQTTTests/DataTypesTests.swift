//
//  DataTypesTests.swift
//  MQTTTests
//
//  Created by Mukesh on 26/01/19.
//

import XCTest
@testable import MQTT

final class DataTypesTests: XCTestCase {
    func testEmptyStringSuccess() {
        let emptyString = ""
        
        let utfString = try? MQTTUTF8String(emptyString)
        
        XCTAssert(utfString?.value == emptyString, "String test failed")
        XCTAssert(utfString?.length == 0, "String test failed")
        XCTAssert(utfString?.bytes == [0x0, 0x0], "String test failed")
    }
    
    func testNonEmptyStringSuccess() {
        let nonEmptyString = "A test string"
        
        let utfString = try? MQTTUTF8String(nonEmptyString)
        
        XCTAssert(utfString?.value == nonEmptyString, "String test failed")
        XCTAssert(utfString?.length == 13, "String test failed")
        XCTAssert(utfString?.bytes == [0, 13, 65, 32, 116, 101, 115, 116, 32, 115, 116, 114, 105, 110, 103], "String test failed")
    }
    
    static var allTests = [
        ("testEmptyStringSuccess", testEmptyStringSuccess),
        ("testNonEmptyStringSuccess", testNonEmptyStringSuccess)
    ]
}
