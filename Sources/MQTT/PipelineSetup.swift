//
//  PipelineSetup.swift
//  MQTT
//
//  Created by Mukesh on 24/01/19.
//

import Foundation
import NIO

public extension ChannelPipeline {
    func configureServerPipeline() -> EventLoopFuture<Void> {
        let handlers: [ChannelHandler] = [MQTTRequestDecoder(), MQTTResponseEncoder()]
        return addHandlers(handlers, first: true)
    }
    
    func configureClientPipeline() -> EventLoopFuture<Void> {
        let handlers: [ChannelHandler] = [MQTTResponseDecoder(), MQTTRequestEncoder()]
        return addHandlers(handlers, first: true)
    }
}


extension UInt32 {
    var bytes: [UInt8] {
        return [
            UInt8((self & 0xFF000000) >> 24),
            UInt8((self & 0x00FF0000) >> 16),
            UInt8((self & 0x0000FF00) >> 8),
            UInt8(self & 0x000000FF)
        ]
    }
}

extension UInt16 {
    var bytes: [UInt8] {
        return [
            UInt8((self & 0xFF00) >> 8),
            UInt8(self & 0x00FF)
        ]
    }
}

extension String {
    var bytes: [UInt8] {
        return utf8.map { $0 }
    }
    
    var utf8EncodedBytes: [UInt8] {
        let utf8View = utf8
        if utf8View.count > UInt16.max {
            return []
        }
        
        return UInt16(utf8View.count).bytes + utf8View.map { $0 }
    }
}

extension Data {
    var bytes: [UInt8] {
        let count = self.count
        if count > UInt16.max {
            return []
        }
        
        return UInt16(count).bytes + self.map { $0 }
    }
}
