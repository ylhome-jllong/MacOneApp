//
//  NetGame.swift
//  MacOneApp
//
//  Created by 江龙 on 2020/5/19.
//  Copyright © 2020 江龙. All rights reserved.
//

import Cocoa
import SwiftSocket
/// 网络游戏处理类
class NetGame: NSObject {
    
    /// 游戏实例
    var game: Game?
    /// 服务器实例
    private var server = Server()
    /// 客户端实例
    private var client = Client()
    /// 服务器状态
    var serverState = ServerState(stare: false, describe: "服务器未开启")
    /// 我方棋子色彩
    private(set) var myTeam = Piece.TeamType.black
    /// 客户端连接服务器状态
    private(set) var clientState = false
    /// 网络游戏状态
    private(set) var netGameState: NetGameState = .free
    enum NetGameState {
        case play
        case realy
        case free
    }
    
    
    var OnNew: ((Any?)->())?
    var OnNewPlus: ((Any?)->())?
    var OnCloseGame: ((Any?)->())?
    var mouseDown: ((NSPoint)->())?
    var mouseDragged: ((NSPoint)->())?
    var mouseUp:((NSPoint)->())?
    

    /// 开启服务器
    func openServer() -> ServerState {
        if (serverState.stare){return serverState}//服务器已经开启
        else{
            // 测试默认使用127.0.0.1：3200
             serverState = server.stat(address: "127.0.0.1", port: 3200)
             return serverState
        }
    }
    /// 关闭服务器
    func closeServer(){
        serverState = server.stop()
    }
    
    
    /// 连接服务器
    func linkServer(address: String, port: Int32) {
        client.callbackFunc = self.callbackFunc
        clientState = client.startClient(address: address, port: port)
    }
    
    /// 主动断开服务器
    func disconnectServer(){
        clientState = false
        netGameState = .free
        client.close()
    }
    /// 准备游戏
    func readyGame(){
        // 向服务器发送准备游戏
        let msg = MSG(cmd: "ready", content: "",point: nil)
        client.sendMsg(msg: msg)
        netGameState = .realy
    }
    
    
    
    /// Socket_Client 回调消息处理
    func callbackFunc(msg:MSG){
        // 回主线程运行
        DispatchQueue.main.async {
            switch msg.content {
            case "play1":self.myTeam = .black;self.OnNew?(nil);self.netGameState = .play
            case "play2":self.myTeam = .red;self.OnNewPlus?(nil);self.netGameState = .play
            case "MouseDown":self.mouseDown?(msg.point!)
            case "MouseDragged":self.mouseDragged?(msg.point!)
            case "MouseUp":self.mouseUp?(msg.point!)
            // 被动断开服务器
            case "ClientClose":self.clientState = false;self.netGameState = .free;self.OnCloseGame?(nil)
                default:
                       break
            }
        }
       
        
    }
    
    /// 网络发布鼠标按下
    func netMouseDown(point: NSPoint){
        let msg = MSG(cmd: "msg", content: "MouseDown", point: point)
        client.sendMsg(msg: msg)
    }
    /// 网络发布鼠标拖动
    func netMouseDragged(point: NSPoint){
        let msg = MSG(cmd: "msg", content: "MouseDragged", point: point)
        client.sendMsg(msg: msg)
    }
    /// 网络发布鼠标弹起
    func netMouseUp(point: NSPoint){
        let msg = MSG(cmd: "msg", content: "MouseUp", point: point)
        client.sendMsg(msg: msg)
    }

}



