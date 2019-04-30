//
//  swiftkcp.swift
//  SwiftKcp
//
//  Created by 彭运筹 on 2017/2/8.
//  Copyright © 2017年 peng yun chou. All rights reserved.
//

import Foundation
import ikcp

public protocol KcpOutputer {
    func kcp(kcp:Kcp,outputData:Data) -> Int
}
fileprivate func dummyKcpOutput(buf:UnsafePointer<Int8>?,len:Int32,kcp:UnsafeMutablePointer<IKCPCB>?,ud:UnsafeMutableRawPointer?) -> Int32{
    assert(ud != nil, "user data can not be null")
    return Unmanaged<Kcp>.fromOpaque(ud!).takeUnretainedValue().kcpOutput(buf: buf, len: len, kcp: kcp, ud: ud)
}
public class Kcp {
    fileprivate var kcp:UnsafeMutablePointer<ikcpcb>!
    fileprivate var outputer:KcpOutputer!
    public let identifier:Int
    public init(conv: UInt32, recvBufferSize:Int32 = 1024) {
        self.identifier = Int(conv)
        let pointer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        kcp = ikcp_create(conv, pointer)
        kcp.pointee.output = dummyKcpOutput
    }
    
    public func outputer(_ outputer: KcpOutputer) {
        self.outputer = outputer
    }
    
    public func setMtu(mtu: Int32) -> Int32 {
        return ikcp_setmtu(kcp, mtu)
    }
    
    public func wndSize(sndwnd: Int32, rcvwnd: Int32) -> Int32 {
        return ikcp_wndsize(kcp, sndwnd, rcvwnd)
    }
    
    public func noDelay(nodelay: Int32, interval: Int32, resend: Int32, nc: Int32) -> Int32 {
        return ikcp_nodelay(kcp, nodelay, interval, resend, nc)
    }
    
    func kcpOutput(buf:UnsafePointer<Int8>?,len:Int32,kcp:UnsafeMutablePointer<IKCPCB>?,ud:UnsafeMutableRawPointer?) -> Int32{
        assert(buf != nil, "buffer can not be null")
        let data = Data(bytes: buf!, count: Int(len))
        return Int32(self.outputer.kcp(kcp: self, outputData: data))
    }
    public func update(millisec:UInt32){
        ikcp_update(self.kcp, millisec)
    }
    
    public func send(data:Data) -> Int32{
        return data.withUnsafeBytes { [unowned self](byte:UnsafePointer<Int8>) -> Int32 in
            return ikcp_send(self.kcp, byte, Int32(data.count))
        }
    }
    
    public func input(data:Data) -> Int32{
        return data.withUnsafeBytes { [unowned self](byte:UnsafePointer<Int8>) -> Int32 in
            return ikcp_input(self.kcp, byte, data.count)
        }
    }

    public func recv(bufferLen:Int32 = 1024) -> Data{
        let buffer = UnsafeMutablePointer<Int8>.allocate(capacity: Int(bufferLen))
        let len = ikcp_recv(self.kcp, buffer, bufferLen)
        if len <= 0{  return Data() }
        return Data(bytes: buffer, count: Int(len))
    }
    
}

extension Kcp:Equatable{
    public static func ==(lhs: Kcp, rhs: Kcp) -> Bool{
        return lhs.identifier == rhs.identifier
    }
}
