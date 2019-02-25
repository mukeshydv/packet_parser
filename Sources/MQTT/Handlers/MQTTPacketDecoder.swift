//
//  MQTTDecoder.swift
//  MQTT
//
//  Created by Mukesh on 22/01/19.
//

import Foundation
import NIO

public class MQTTPacketDecoder: ByteToMessageDecoder {
    public typealias InboundIn = ByteBuffer
    public typealias InboundOut = MQTTPacket
    public var cumulationBuffer: ByteBuffer?
    
    private let mqttDecoder = MQTTDecoder()
    
    deinit {
        mqttDecoder.completionHandler = nil
    }
    
    public func decoderAdded(ctx: ChannelHandlerContext) {
        mqttDecoder.completionHandler = { packet in
            let data = self.wrapInboundOut(packet)
            ctx.fireChannelRead(data)
        }
    }
    
    public func decoderRemoved(ctx: ChannelHandlerContext) {
        mqttDecoder.completionHandler = nil
    }
    
    public func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        var buffer = unwrapInboundIn(data)
        do {
            try mqttDecoder.decode(&buffer)
        } catch {
            ctx.fireErrorCaught(error)
            ctx.close(promise: nil)
        }
    }
    
    public func decode(ctx: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        return .needMoreData
    }
    
    public func channelReadComplete(ctx: ChannelHandlerContext) {
        ctx.fireChannelReadComplete()
    }
    
    public func errorCaught(ctx: ChannelHandlerContext, error: Error) {
        ctx.fireErrorCaught(error)
        
        if error is PacketError {
            ctx.close(promise: nil)
        }
    }
}
