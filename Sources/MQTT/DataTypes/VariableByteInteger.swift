//
//  VariableByteInteger.swift
//  MQTT
//
//  Created by Mukesh on 25/01/19.
//

import Foundation

enum VariableByteError: Error {
    case error(String)
}

struct VariableByteInteger {
    let value: UInt32
    let bytes: [UInt8]
    
    init(_ value: UInt32) {
        self.value = value
        
        var bytes: [UInt8] = []
        var x = value;
        repeat {
            var encodedByte: UInt8 = UInt8(x % 128)
            x = x / 128
            
            if x > 0 {
                encodedByte = encodedByte | 128
            }
            
            bytes.append(encodedByte)
        } while x > 0
        
        self.bytes = bytes
    }
    
    init(from bytes: [UInt8], startIndex: Int = 0) throws {
        
        var multiplier: UInt32 = 1
        var value: UInt32 = 0
        var encodedByte: UInt8
        var index = startIndex
        
        repeat {
            guard index < bytes.count else {
                throw VariableByteError.error("Invalid")
            }
            
            encodedByte = bytes[index]
            value += UInt32(encodedByte & 127) * multiplier
            if multiplier > 128 * 128 * 128 {
                throw VariableByteError.error("Size error")
            }
            
            multiplier *= 128
            index += 1
        } while (encodedByte & 128) != 0
        
        self.bytes = bytes[startIndex..<index].map { $0 }
        self.value = value
    }
    
    var totlaLength: Int {
        return bytes.count + Int(value)
    }
}
