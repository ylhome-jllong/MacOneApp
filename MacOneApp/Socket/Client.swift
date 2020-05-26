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
    
    /// 事件处理代理
    var delegate: ClientProtocol?
    
    
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
        sendCloseMsg()
       
    }
    
    /// 发送消息
    func sendMsg(data: Data?){
        // 数据封装
        let msg = Server.MSG(cmd: .message, content: data)
        // 数据转化为可发送的Data
        if let sendData = Server.toSendData(msg: msg) {
            _ = self.tcpClient!.send(data: sendData)
        }
    }
    /// 向服务器发送关闭客户端消息
    private func sendCloseMsg(){
        let msg = Server.MSG(cmd: .clientClose, content: nil )
        if let sendData = Server.toSendData(msg: msg){
            _ = self.tcpClient!.send(data: sendData)
        }
    }
    
    
    /// 读取消息
    private func readMsg()->Server.MSG?{
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
                    guard let msgi = try? jsonDecoder.decode(Server.MSG.self, from: msgd)else{
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
    private func processMessage(msg:Server.MSG){
        
        switch(msg.cmd){
        case .message:
            delegate?.msgArrive(data: msg.content!)
            print("Clent_msg:\(msg.content!)")
        case .clientClose:
            // 断开连接
            self.tcpClient.close()
            // 让上一层处理
            let retMsg = NetGame.NetGameMSG(cmd: .stopGame, point: nil)
            let retData = NetGame.toSendData(msg: retMsg)
            delegate?.msgArrive(data: retData!)
        }
    }

}

/// Client事件委托协议
protocol ClientProtocol {
    /// 有消息到达委托处理
    func msgArrive(data: Data)
}
