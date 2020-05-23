//
//  Server.swift
//  Socket
//
//  Created by 江龙 on 2020/5/17.
//  Copyright © 2020 江龙. All rights reserved.
//

import Cocoa
import SwiftSocket




/// Socket 服务器端
class Server: NSObject {
    //  枚举类型要默认支持 Codable 协议，需要声明为具有原始值的形式，
    //  并且原始值的类型需要支持 Codable 协议：
    /// 网络通信层命令
    enum CMD: Int,Codable {
        /// 传递的信息
        case message
        /// 关闭客户端
        case clientClose
        /// 游戏准备（要在后续的版本中删除这个命令）
        case ready
        
    }
    
 
    /// 服务器连接对象
    var tcpServer: TCPServer!
    /// 服务器工作状态
    var serverState = ServerState(stare: false, describe: "服务器关闭")
    /// 客户端管理器
    var clientManagers = [ClientManager]()
    
    
    /// 启动服务器 错误返回原因，成功返回IP
    func stat(address: String, port: Int32) -> ServerState{
        
        // 初始化tcpSever对象
        self.tcpServer = TCPServer(address: address, port: port)
        // 开始监听 注意要打开沙箱的网络功能
        let status = tcpServer.listen()
        switch status {
        case .success:
            serverState.stare = true
            serverState.describe = "开启服务：\(tcpServer.address):\(tcpServer.port)"
            // 开始监听循环
            listenLoop()
            
        case .failure(let error) :
            serverState.stare = false
            serverState.describe = "开启服务失败：\(error.localizedDescription)"
        }
        return serverState
    }
    
    /// 监听循环等待客户端接入（列队异步）
    private func listenLoop(){
            // 新建线程开始监听
        DispatchQueue(label: "Server").async {
                // 只要服务开着就监听
                while self.serverState.stare {
                    let tcpClient = self.tcpServer.accept()
                    // 有正确的客户端接入新建线与他沟通
                    if (tcpClient != nil){
                        self.handleClient(tcpClient!)
                        print("客户端 \(tcpClient!.address):\(tcpClient!.port)")
                    }
                }
            }
        }
    
    /// 停止服务
    func stop() -> ServerState{
        // 服务器停止监听
        self.serverState.stare = false
        self.serverState.describe = "服务器关闭"
        // 关闭tcpServer接口
        _ = self.tcpServer.close()
        // 遍历所有客户端管理器并关闭他们
        for clientManager in clientManagers{
            clientManager.kill()
        }
        // 移除所有
        clientManagers.removeAll()
        
        return serverState
    }
    
    ///  移除客户端
    func remove(_ clientMangager: ClientManager){
        if let possibleIndex=self.clientManagers.firstIndex(of: clientMangager){
            clientManagers.remove(at: possibleIndex)
            
            // 回发消息 “ClientClose“
            clientMangager.sendMsg(msg: MSG(cmd: .clientClose, content: "", point: nil))
            // 如果有对战方也通知其关闭
            clientMangager.opponent?.sendMsg(msg: MSG(cmd: .clientClose, content: "", point: nil))
            // 关闭客户端链接
            clientMangager.kill()
        }
    }
    
    
    /// 处理客户端管理器回传的消息
    func processClientMsg(clientManager: ClientManager, msg: MSG)  {
        // 消息处理
        switch msg.cmd {
        case .message:// 消息转发给对方
            if(clientManager.opponent != nil){
                clientManager.opponent?.sendMsg(msg: msg)
            }
            // 消息打印在服务器
//            print("server_msg:\(msg.content)")
        case .ready://准备游戏（为了简单先只接收两个客户端）
            msgReady(clientManager: clientManager)
        case .clientClose:// 关闭客户端连接
            remove(clientManager)
        default:
            print("消息处理Err:\(msg)")
            break
        }
    }
    
    /// 处理准备游戏事件
    private func msgReady(clientManager: ClientManager ){
        for clientManager2 in clientManagers{
            if (clientManager2.gameState == "ready"){
                // 找到配对
                clientManager.opponent = clientManager2
                clientManager2.opponent = clientManager
                clientManager.gameState = "play"
                clientManager2.gameState = "play"
                // 回发开始消息
                clientManager.sendMsg(msg: MSG(cmd:.message, content: "play1"))
                clientManager2.sendMsg(msg: MSG(cmd: .message, content: "play2"))
                
                print("Server: 客户端配对成功\(clientManager.tcpClient!.address)--\(clientManager2.tcpClient!.address)")
                return
            }
        }
        clientManager.gameState = "ready"
        print("Server: 客户端ready\(clientManager.tcpClient!.address)")
        
    }
    
    
    
    /// 处理连接的客户端
    private func handleClient(_ tcpClient:TCPClient){
        let clientManager = ClientManager()
        // 客户端管理类初始化
        clientManager.tcpClient = tcpClient
        clientManager.server=self
        // 加入客户端管理列表
        clientManagers.append(clientManager)
        // 开始接收客户端信息
        clientManager.messageLoop()
    }
    

    
}



/// 客户端管理器
class ClientManager: NSObject {
    /// 指向tcpClient 对象
    var tcpClient: TCPClient?
    /// 客户端名字
    var username: String = ""
    ///  指向Server对象
    var server: Server?
    /// 游戏状态
    var gameState: String = ""
    /// 对手的客户端管理器
    var opponent: ClientManager?
    
    
    /// 来自客户端的消息循环（列队异步）
    func messageLoop(){
        DispatchQueue(label: "ClientManager").async {
            while true {
                if let msg = self.readMsg(){
                    self.processMsg(msg: msg)
                    switch msg.cmd {
                    case .clientClose:return //结束消息循环
                    default:break
                    }
                }
                else{
                    //空信息处理
                }
            }
        }
        
    }
    
    /// 关闭客户端
    func kill() {
        _ = self.tcpClient?.close()
    }
    
    /// 发送消息
    func sendMsg(msg: MSG){
        // 序列化数据
        let jsonEncoder = JSONEncoder()
        if let jsonData=try? jsonEncoder.encode(msg)
        {
            // 获得消息长度
            var len:Int32 = Int32(jsonData.count)
            var data = Data(bytes: &len, count: 4)
            data.append(jsonData)
            // 发送数据（含消息的长度值）
            _ = self.tcpClient!.send(data: data)
        }
    }
    
    
    /// 读取客户端消息
    private func readMsg()->MSG?{
        // 读4个字节（信息头，后面内容的长度）
        if let data=self.tcpClient!.read(4){
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
                            print("Socket CM Err jsonData \(jsonString!)")
                            return nil
                    }
                    return msgi
                }
            }
            
        }
        return nil
        
    }
    
  
    
    //处理收到的消息
    private func processMsg(msg:MSG){
        server!.processClientMsg(clientManager: self, msg: msg)
    }

}

// 通信的信息包 满足可转换协议
struct MSG: Codable {
    /// 命令：“msg” ontent:为通信内容。
    var cmd: Server.CMD
    var content: String
    var point: NSPoint?
}

/// 服务器状态数据结构
struct ServerState {
    /// 服务器是否开启
    var stare: Bool
    /// 服务器状态描述
    var describe:String
}
