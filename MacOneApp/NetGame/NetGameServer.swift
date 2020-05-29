//
//  NetGameServer.swift
//  MacOneApp
//
//  Created by 江龙 on 2020/5/23.
//  Copyright © 2020 江龙. All rights reserved.
//
//问题：1.客户端接入的处理（回调Func）
//     2.客户端通知服务器的消息处理如 read 处理
//



import Cocoa

/// 网络游戏服务器
class NetGameServer: NSObject,ServerProtocol {
    
    
    
    /// 服务器实例
    private var server = Server()
    /// 服务器工作状态
    private(set) var serverState = Server.ServerState.shutdown
    /// 玩家数据结构
    class GamePlayer {
        /// TCP连接
        var clientManager: ClientManager
        /// 对手TCP连接
        var opponent: GamePlayer?
        /// 现在的游戏状态
        var gameState: NetGame.NetGameState
        /// 对战组
        var group = -1
        
        ///
        init(clientManager: ClientManager,opponent: GamePlayer?,gameState: NetGame.NetGameState){
            self.clientManager = clientManager
            self.opponent = opponent
            self.gameState = gameState
        }
    }
    /// 已连接服务器的游戏玩家
    private(set) var gamePlayers = [GamePlayer]()
    
    /// 通知代理协议（有相关变化时通知上一级处理）
    var notifyDelegate: NetGameServerProtocol?
    
    
//========== 服务器工作 ========================================================================
    /// 开启服务器 成功返回IP
    func openServer() -> String {
        if (serverState == .serving){return server.serverIP}//服务器已经开启
        else{
            // 测试默认使用127.0.0.1：3200
            serverState = server.stat(address: "0.0.0.0", port: 3200)
            // 设置socket的事件代理
            server.delegate = self
            return server.serverIP
        }
    }
    /// 关闭服务器
    func closeServer(){
        serverState = server.stop()
        // 删除所有玩家
        gamePlayers.removeAll()
    }
    
    
    
     /// 处理准备游戏事件
    private func ready(clientManager: ClientManager ){
        let gamePlayer = getGamePlayer(clientManager: clientManager)
        for gamePlayer2 in gamePlayers{
            if (gamePlayer2.gameState == .realy){
                // 找到配对
                gamePlayer!.opponent = gamePlayer2
                gamePlayer2.opponent = gamePlayer
                gamePlayer!.gameState = .play
                gamePlayer2.gameState = .play
                // 回发开始消息
                let sendData1 = NetGame.toSendData(msg: NetGame.NetGameMSG(cmd: .play1, point: nil))
                let sendData2 = NetGame.toSendData(msg: NetGame.NetGameMSG(cmd: .play2, point: nil))
                gamePlayer!.clientManager.sendMsg(data: sendData1)
                gamePlayer2.clientManager.sendMsg(data: sendData2)
                
                // 随机产生对战组号
                gamePlayer!.group = Int(arc4random())
                gamePlayer2.group = gamePlayer!.group
    
                print("Server: 客户端配对成功\(gamePlayer!.clientManager.tcpClient!.address)--\(gamePlayer2.clientManager.tcpClient!.address)")
                self.notifyDelegate?.gamePlayerReady()
                return
            }
        }
        gamePlayer!.gameState = .realy
        self.notifyDelegate?.gamePlayerReady()
        print("Server: 客户端ready\(gamePlayer!.clientManager.tcpClient!.address)")
    
    }
    
    
    /// 消息处理
    private func processMsg(clientManager: ClientManager,data: Data)  {
        //消息解码
        let msg = NetGame.toNetGameMSG(data: data)
        // 消息处理
        switch msg!.cmd {
            // 处理ready消息
        case .ready:ready(clientManager: clientManager)
            // 其他转发给对手
        default:
            //寻找玩家列表中的位置
            if let gamePlayer = getGamePlayer(clientManager: clientManager){
                if let opponent = gamePlayer.opponent{opponent.clientManager.sendMsg(data: data)}
            }
            
        }
    }
    // 获取游戏玩家
    private func getGamePlayer(clientManager: ClientManager) -> GamePlayer? {
        for index in 0...gamePlayers.endIndex {
            if(gamePlayers[index].clientManager == clientManager){
                return gamePlayers[index]
            }
        }
        return nil
    }
    
//========== 协议实现 ======================================================================
    /// 有新玩家接入服务器，Socket回调函
    func addClient(clientManager: ClientManager) {
        let gamePlayer = GamePlayer(clientManager: clientManager , opponent: nil, gameState: .free)
        // 加入玩家列表
        gamePlayers.append(gamePlayer)
        notifyDelegate?.addGamePlayer()
    }
    /// 有玩家退出服务器，Socket回调函数
    func delClient(clientManager: ClientManager) {
        for index in 0...gamePlayers.endIndex {
            // 寻找玩家列表中的位置
            if(gamePlayers[index].clientManager == clientManager){
                // 如果有手玩家也通知他推出
                if let opponent = gamePlayers[index].opponent{
                    opponent.clientManager.sendCloseMsg()
                    // 删除对对战端中的自己
                    opponent.opponent = nil
                }
                // 删除列表中的玩家
                gamePlayers.remove(at: index)
                notifyDelegate?.delGamePlayer()
                // 跳出
                break
            }
        }
    }
    /// 有消息到达服务器（消息转发）
    func msgArrive(clientManager: ClientManager, data: Data) {
        processMsg(clientManager: clientManager, data: data)
    }
    
    
    
}

/// NetGameServer类事件委托协议
protocol NetGameServerProtocol {
    /// 有玩家加入时触发
    func addGamePlayer()
    /// 有玩家退出时触发
    func delGamePlayer()
    /// 有玩家准游戏时触发
    func gamePlayerReady()
    
}
