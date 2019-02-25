//
//  MQTTEncoder.swift
//  MQTT
//
//  Created by Mukesh on 22/01/19.
//

import Foundation
import NIO

public class MQTTPacketEncoder: ChannelOutboundHandler {
    public typealias OutboundIn = MQTTPacket
    public typealias OutboundOut = ByteBuffer
    
    public func write(ctx: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let request = unwrapOutboundIn(data)
        let bytes = try! request.encode()
        var buffer = ByteBufferAllocator().buffer(capacity: bytes.count)
        buffer.write(bytes: bytes)
        
        let response = wrapOutboundOut(buffer)
        ctx.write(response, promise: promise)
    }
}
