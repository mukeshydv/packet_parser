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
    public typealias OutboundOut = ByteBuffer
    
    public func write(ctx: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        var buffer = ctx.channel.allocator.buffer(capacity: 2)
        buffer.write(bytes: [0, 1])
        ctx.write(wrapOutboundOut(buffer), promise: promise)
    }
}

public class MQTTRequestEncoder: ChannelOutboundHandler {
    public typealias OutboundIn = MQTTRequestMessage
    public typealias OutboundOut = ByteBuffer
    
    public func write(ctx: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let request = unwrapOutboundIn(data)
        switch request {
        case .connect:
            var buffer = ctx.channel.allocator.buffer(capacity: 2)
            buffer.write(bytes: [0,1])
            ctx.write(wrapOutboundOut(buffer), promise: promise)
        }
    }
}
