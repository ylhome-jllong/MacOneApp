//
//  NetClientVC.swift
//  MacOneApp
//
//  Created by 江龙 on 2020/5/20.
//  Copyright © 2020 江龙. All rights reserved.
//




import Cocoa

/// 游戏客户端面板
class NetClientVC: NSViewController {

    /// NetGame 实例
    var netGame: NetGame?
    /// 信息回调函数
    var callbackFunc: ((String)->())?
//    /// 服务器地址
//    @objc var address: String? = "127.0.0.1" //测试默认值
//    /// 服务器端口
//    @objc var port: Int32 = 3200 //测试默认值

    
    
    
    @IBOutlet weak var disconnectButton: NSButton!
    @IBOutlet weak var linkButton: NSButton!
    @IBOutlet weak var addressText: NSTextField!
    @IBOutlet weak var portText: NSTextField!
    @IBOutlet weak var readyGameButton: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
       
        // 测试默认 IP TCP
        addressText.stringValue = "127.0.0.1"
        portText.stringValue = "3200"
    }
    override func viewDidAppear() {
        self.updateControl()
        super.viewDidAppear()
    }
    
    /// 关联关闭窗口按钮
    @IBAction func OnClose(_ sender: Any) {
        self.dismiss(self)
    }
    
    @IBAction func OnLink(_ sender: Any) {
        let address = addressText.stringValue
        let port = Int32(portText.stringValue)
        netGame!.linkServer(address: address, port: port!)
        if( netGame!.clientState){self.callbackFunc?("服务器连接成功")}
        updateControl()
    }
    
    /// 关联断开服务器按钮
    @IBAction func OnDisconnect(_ sender: Any) {
        netGame?.disconnectServer()
        if(!netGame!.clientState){self.callbackFunc?("服务器连接断开")}
        updateControl()
    }
    /// 关联游戏准备按钮
    @IBAction func OnReadyGame(_ sender: Any) {
        self.dismiss(self)
        netGame?.readyGame()
        if(netGame!.netGameState == .realy){self.callbackFunc?("准备游戏")}
    }
    
    /// 更新控件
    private func updateControl(){
        if (netGame!.clientState){
            disconnectButton.isEnabled = true
            readyGameButton.isEnabled = true
               linkButton.isEnabled = false
               addressText.isEnabled = false
               portText.isEnabled = false
        }
        else{
           disconnectButton.isEnabled = false
           readyGameButton.isEnabled = false
           linkButton.isEnabled = true
           addressText.isEnabled = true
           portText.isEnabled = true
        }
        switch netGame?.netGameState {
        case .free:
            readyGameButton.isEnabled = true
        case .play, .realy:
            readyGameButton.isEnabled = false
        default: break
        }
        
    }
    
    
}
