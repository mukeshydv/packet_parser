//
//  MQTTEncoder.swift
//  MQTT
//
//  Created by Mukesh on 22/01/19.
//

import Foundation
import NIO

public class MQTTResponseEncoder: ChannelOutboundHandler {
    public typealias OutboundIn = MQTTResponseMessage
    public typealias OutboundOut = IOData
    
    public func write(ctx: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        
    }
}

public class MQTTRequestEncoder: ChannelOutboundHandler {
    public typealias OutboundIn = MQTTRequestMessage
    public typealias OutboundOut = IOData
    
    public func write(ctx: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        
    }
}
