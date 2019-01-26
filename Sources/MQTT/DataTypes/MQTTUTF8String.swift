//
//  UTF8String.swift
//  CNIOAtomics
//
//  Created by Mukesh on 26/01/19.
//

import Foundation

enum MQTTDataTypeError: Error {
    case invalidUtf8String
    case invalidBinaryData
}

struct MQTTUTF8String {
    let value: String
    let length: UInt16
    let bytes: [UInt8]
    
    init(_ value: String) throws {
        let utf8View = value.utf8
        if utf8View.count > UInt16.max {
            throw MQTTDataTypeError.invalidUtf8String
        }
        
        self.value = value
        self.length = UInt16(utf8View.count)
        self.bytes = length.bytes + utf8View.map { $0 }
    }
    
    init(from decoder: [UInt8], startIndex: UInt32 = 0) throws {
        let startIndex = Int(startIndex + 2)
        
        guard startIndex <= decoder.count else {
            throw MQTTDataTypeError.invalidUtf8String
        }
        
        length = UInt16(decoder[startIndex-2], decoder[startIndex-1])

        let endIndex = startIndex + Int(length)
        
        guard endIndex <= decoder.count else {
            throw MQTTDataTypeError.invalidUtf8String
        }
        
        let bytes = decoder[startIndex..<endIndex].map { $0 }
        self.bytes = [decoder[startIndex-2], decoder[startIndex-1]] + bytes
        
        guard let value = String(bytes: bytes, encoding: .utf8) else {
            throw MQTTDataTypeError.invalidUtf8String
        }
        self.value = value
    }
}

struct MQTTUTF8StringPair {
    let key: String
    let value: String
    let keyLength: UInt16
    let valueLength: UInt16
    let bytes: [UInt8]
    
    init(_ key: String, _ value: String) throws {
        let keyUtf = try MQTTUTF8String(key)
        let valueUtf = try MQTTUTF8String(value)
        
        self.init(keyUtf, valueUtf)
    }
    
    private init(_ keyUtf: MQTTUTF8String, _ valueUtf: MQTTUTF8String) {
        self.key = keyUtf.value
        self.value = valueUtf.value
        self.keyLength = keyUtf.length
        self.valueLength = valueUtf.length
        self.bytes = keyUtf.bytes + valueUtf.bytes
    }
    
    init(from bytes: [UInt8], startIndex: UInt32 = 0) throws {
        let keyUtf = try MQTTUTF8String(from: bytes, startIndex: startIndex)
        let startIndex = startIndex + UInt32(keyUtf.length) + 2
        let valueUtf = try MQTTUTF8String(from: bytes, startIndex: startIndex)
        
        self.init(keyUtf, valueUtf)
    }
}
