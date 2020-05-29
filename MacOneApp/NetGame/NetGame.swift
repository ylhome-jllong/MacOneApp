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
class NetGame: NSObject,ClientProtocol {

    /// 网络游戏层网络消息结构
    struct NetGameMSG: Codable {
        /// 网络游戏层命令
        var cmd: CMD
        /// 发送的棋子坐标
        var point: NSPoint?
    }
    /// 网络游戏层命令
    enum CMD: Int,Codable {
        /// 准备游戏
        case ready
        /// 开始游戏玩家1
        case play1
        /// 开始游戏玩家2
        case play2
        /// 鼠标移到
        case mouseDragged
        /// 鼠标按下
        case mouseDown
        /// 鼠标弹起
        case mouseUp
    }
    
    
    /// 游戏实例
    var game: Game?
    /// 客户端实例
    private var client = Client()
   
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
    
    /// 委托处理相关事件
    var delegate: NetGameProtocol?
    

    
    /// 数据解码
    static func toNetGameMSG(data:Data) -> NetGameMSG?{
        let jsonDecoder = JSONDecoder()
        let netGameMsg = try? jsonDecoder.decode(NetGameMSG.self, from: data)
        return netGameMsg
    }
    /// 数据编码
    static func toSendData(msg: NetGameMSG) -> Data?{
        let jsonEncoder = JSONEncoder()
        let senddata = try? jsonEncoder.encode(msg)
        return senddata
    }
    

    
    

//========== 客户端工作 ========================================================================
    
    
    /// 连接服务器
    func linkServer(address: String, port: Int32) {
        client.delegate = self
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
        if let sendData = Self.toSendData(msg: NetGameMSG(cmd: .ready, point: nil)){
            client.sendMsg(data: sendData)
            netGameState = .realy
        }
    }
    
    
//========== ClientProtocol 协议实现======================================
    /// Socket_Client 回调消息处理
    func msgArrive(data: Data) {
        // 解码数据
        if let msg = Self.toNetGameMSG(data: data){
            var localPoint=CGPoint(x: 0, y: 0)
            if (msg.point != nil) {localPoint = toLocalLPoint(msg.point!)}
            // 回主线程运行
            DispatchQueue.main.async {
                switch msg.cmd {
                case .play1:self.myTeam = .black;self.delegate?.OnNew(nil);self.netGameState = .play
                case .play2:self.myTeam = .red;self.delegate?.OnNewPlus(nil);self.netGameState = .play
                case .mouseDown:self.delegate?.mouseDown(point: localPoint)
                case .mouseDragged:self.delegate?.mouseDragged(point: localPoint)
                case .mouseUp:self.delegate?.mouseUp(point: localPoint)
                // 现在也不知道它要做什么
                case .ready:break
                }
            }
        }
       
    }
    /// 收到关闭客户端消息时处理
    func msgClienClose() {
        DispatchQueue.main.async {
            self.clientState = false
            self.netGameState = .free
            self.delegate?.OnCloseGame(nil)
        }
    }
    
    
    /// 网络发布鼠标按下
    func netMouseDown(point: NSPoint){
        let netPoint = toNetGamePoint(point)
        if let sendData = Self.toSendData(msg: NetGameMSG(cmd: .mouseDown, point: netPoint)){
            client.sendMsg(data: sendData)
        }
        
    }
    /// 网络发布鼠标拖动
    func netMouseDragged(point: NSPoint){
         let netPoint = toNetGamePoint(point)
        if let sendData = Self.toSendData(msg: NetGameMSG(cmd: .mouseDragged, point: netPoint)){
             client.sendMsg(data: sendData)
        }
        
    }
    /// 网络发布鼠标弹起
    func netMouseUp(point: NSPoint){
        let netPoint = toNetGamePoint(point)
        if let sendData = Self.toSendData(msg: NetGameMSG(cmd: .mouseUp, point: netPoint)){
            client.sendMsg(data: sendData)
        }
    }
    
    
    /// 转化为相对坐标用于网络传输
    private func toNetGamePoint(_ oldPoint: CGPoint)->CGPoint{
        var newPoint = CGPoint(x: 0.0, y: 0.0)
        newPoint.x = oldPoint.x/game!.checkerboard.boardSize!.width
        newPoint.y = oldPoint.y/game!.checkerboard.boardSize!.height
        return newPoint
    }
    /// 坐标转换回本机坐标
    private func toLocalLPoint(_ oldPoint: CGPoint)->CGPoint{
        var newPoint = CGPoint(x: 0.0, y: 0.0)
        newPoint.x = oldPoint.x*game!.checkerboard.boardSize!.width
        newPoint.y = oldPoint.y*game!.checkerboard.boardSize!.height
        return newPoint
        
    }
    
    
    
    
    

}


/// 网络游戏类委托协议
protocol NetGameProtocol {
    /// 新建黑对红委托处理
    func OnNew(_ sender: Any?)
    /// 新建红对黑委托处理
    func OnNewPlus(_ sender: Any?)
    /// 关闭游戏委托处理
    func OnCloseGame(_ sender: Any?)
    /// 鼠标按下事件委托处理
    func mouseDown(point: NSPoint)
    /// 鼠标弹起事件委托处理
    func mouseUp(point: NSPoint)
    /// 鼠标拖动委托处理
    func mouseDragged(point: NSPoint)
}

