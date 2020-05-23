//
//  Client.swift
//  Socket
//
//  Created by 江龙 on 2020/5/17.
//  Copyright © 2020 江龙. All rights reserved.
//

import Cocoa
import SwiftSocket


class Client: NSObject {

    /// 指向TCPClient对象TCPClient
    var tcpClient: TCPClient!
    
    /// 可回调回调NetGame的回调函数
    var callbackFunc: ((MSG)->())?
    
    
    /// 启动客户端并链接服务器
    func startClient(address: String, port: Int32) -> Bool {
        // 初始化tcpClient对象
        tcpClient = TCPClient(address: address, port: port)
        
        // 连接服务器
        let state = tcpClient.connect(timeout: 30)
        switch state {
        case .success:
                self.msgLoop()
            return true
        case .failure(let error):
            print("客户端连接服务器错误\(error.localizedDescription)")
            return false
        }
    }
    /// 断开连接
    func close(){
        // 发消息给服务器已关闭客户端管理
        self.sendMsg(msg: MSG(cmd: .clientClose, content: "", point: nil))
       
    }
    
    /// 发送消息
    func sendMsg(msg:MSG){
          // 序列化数据
        let jsonEncoder = JSONEncoder()
        if let jsonData=try? jsonEncoder.encode(msg){
         
            // 获得消息长度
            var len:Int32 = Int32(jsonData.count)
            var data = Data(bytes: &len, count: 4)
            // 发送数据（含消息的长度值）
            data.append(jsonData)
            _ = self.tcpClient!.send(data: data)
        }
        
        
    }
    
    /// 读取消息
    private func readMsg()->MSG?{
        // 读4个字节（信息头，后面内容的长度）
        if let data = self.tcpClient!.read(4){
            if data.count == 4{
                // 解析后面内容的长度
                let ndata = NSData(bytes: data, length: data.count)
                var len: Int32 = 0
                ndata.getBytes(&len, length: data.count)
                // 读取信息的内容长度len
                if let buff=self.tcpClient!.read(Int(len)){
                    let msgd = Data(bytes: buff, count: buff.count)
                    // 反序列化数据
                    let jsonDecoder = JSONDecoder()
                    guard let msgi = try? jsonDecoder.decode(MSG.self, from: msgd)else{
                        let jsonString = String(data: msgd,encoding: .utf8)
                        print("Socket Client Err jsonData \(jsonString!)")
                        return nil
                    }
                    return msgi
                }
            }
            
        }
        
        return nil
        
    }
    /// 消息循环（列队异步）
    private func msgLoop(){
        DispatchQueue(label:"Client").async {
            while true{
                // 有效消息
                if let msg = self.readMsg(){
                    self.processMessage(msg: msg)
                    if(msg.cmd == .clientClose){ return}//结束循环
                }
                // 无效消息
                else{
                }
            }
        }
    }
   
    //处理消息
    private func processMessage(msg:MSG){
        
        switch(msg.cmd){
        case .message:
            callbackFunc?(msg)
            print("Clent_msg:\(msg.content)")
        case .clientClose:
            // 断开连接
            self.tcpClient.close()
            // 让上一层处理
            callbackFunc?(MSG(cmd:.message, content: "ClientClose", point: nil))
            
        default: break
        }
    }

}
