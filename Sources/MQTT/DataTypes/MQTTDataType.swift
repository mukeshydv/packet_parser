//
//  MQTTDataType.swift
//  CNIOAtomics
//
//  Created by Mukesh on 26/01/19.
//

import Foundation

extension UInt32 {
    var bytes: [UInt8] {
        return [
            UInt8((self & 0xFF000000) >> 24),
            UInt8((self & 0x00FF0000) >> 16),
            UInt8((self & 0x0000FF00) >> 8),
            UInt8(self & 0x000000FF)
        ]
    }
    
    init(_ msb: UInt8, _ byte2: UInt8, _ byte1: UInt8, _ lsb: UInt8) {
        self.init(
            UInt32(msb) << 24 |
                UInt32(byte2) << 16 |
                UInt32(byte1) << 8 |
                UInt32(lsb)
        )
    }
}

extension UInt16 {
    var bytes: [UInt8] {
        return [
            UInt8((self & 0xFF00) >> 8),
            UInt8(self & 0x00FF)
        ]
    }
    
    init(_ msb: UInt8, _ lsb: UInt8) {
        self.init(UInt16(msb) << 8 | UInt16(lsb))
    }
}

extension Data {
//    var bytes: [UInt8] {
//        let count = self.count
//        if count > UInt16.max {
//            return []
//        }
//        
//        return UInt16(count).bytes + self.array
//    }
    
    init(_ bytes: [UInt8]) {
        self.init(bytes: bytes)
    }
}
