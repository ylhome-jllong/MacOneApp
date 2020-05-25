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
class NetGameServer: NSObject {
    
    
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
        init(clientManager: ClientManager,opponent: GamePlayer?,gameState: NetGame.NetGameState){
            self.clientManager = clientManager
            self.opponent = opponent
            self.gameState = gameState
        }
    }
    /// 已连接服务器的游戏玩家
    private var gamePlayers = [GamePlayer]()
    
    
    
    
//========== 服务器工作 ========================================================================
    /// 开启服务器 成功返回IP
    func openServer() -> String {
        if (serverState == .serving){return server.serverIP}//服务器已经开启
        else{
            // 测试默认使用127.0.0.1：3200
            serverState = server.stat(address: "127.0.0.1", port: 3200)
            // 设置socket回调函数
            server.addClientCallbackFunc = self.addPlayerCallbackFunc
            server.delClientCallbackFunc = self.delPlayerCallbackFunc
            server.msgArriveCallBackFunc = self.msgArriveServer
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
    
                print("Server: 客户端配对成功\(gamePlayer!.clientManager.tcpClient!.address)--\(gamePlayer2.clientManager.tcpClient!.address)")
                    return
                }
            }
        gamePlayer!.gameState = .realy
        print("Server: 客户端ready\(gamePlayer!.clientManager.tcpClient!.address)")
    
    }
    
    
    /// 有新玩家接入服务器，Socket回调函
    func addPlayerCallbackFunc(clientManager: ClientManager){
        let gamePlayer = GamePlayer(clientManager: clientManager , opponent: nil, gameState: .free)
        // 加入玩家列表
        gamePlayers.append(gamePlayer)        
    }
    /// 有玩家推出服务器，Socket回调函数
    func delPlayerCallbackFunc(clientManager: ClientManager){
        for index in 0...gamePlayers.endIndex {
            // 寻找玩家列表中的位置
            if(gamePlayers[index].clientManager == clientManager){
                // 如果有手玩家也通知他推出
                if let opponent = gamePlayers[index].opponent{opponent.clientManager.sendCloseMsg()}
                // 删除列表中的玩家
                gamePlayers.remove(at: index)
                // 跳出
                break
            }
        }
    }
    /// 有消息到达服务器（消息转发）
    func msgArriveServer(clientManager: ClientManager,data: Data){
        processMsg(clientManager: clientManager, data: data)
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
    
    

}