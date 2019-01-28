//
//  MQTTDecoder.swift
//  MQTT
//
//  Created by Mukesh on 22/01/19.
//

import Foundation
import NIO

public class MQTTRequestDecoder: ByteToMessageDecoder {
    public typealias InboundIn = ByteBuffer
    public typealias InboundOut = MQTTRequestMessage
    public var cumulationBuffer: ByteBuffer?
    
    public func decode(ctx: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        print(buffer.readBytes(length: buffer.capacity))
        print(buffer.readString(length: buffer.capacity))
        ctx.fireChannelRead(self.wrapInboundOut(.connect(ConnectPacket(payload: ConnectPacket.Payload(clientId: "")))))
        return .needMoreData
    }
}

public class MQTTResponseDecoder: ByteToMessageDecoder {
    public typealias InboundIn = ByteBuffer
    public typealias InboundOut = MQTTResponseMessage
    
    public var cumulationBuffer: ByteBuffer?
    
    public func decode(ctx: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        ctx.fireChannelRead(wrapInboundOut(.connectAck))
        return .needMoreData
    }
}
