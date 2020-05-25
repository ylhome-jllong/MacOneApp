//
//  NetServerVC.swift
//  MacOneApp
//
//  Created by 江龙 on 2020/5/19.
//  Copyright © 2020 江龙. All rights reserved.
//

import Cocoa

class NetServerVC: NSViewController {

    
    /// NetGameServer 实例
    var netGameServer = NetGameServer()
    /// 存储父级回调函数
    var callbackFunc: ((ViewController.VCCallbackMSG)->())?
    
    
    /// 按钮
    @IBOutlet weak var openButton: NSButton!
    @IBOutlet weak var closeButton: NSButton!
    @IBOutlet weak var serverStateText: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        serverStateText.stringValue = "服务器关闭"
        if (netGameServer.serverState == .serving){
            openButton.isEnabled = false
            closeButton.isEnabled = true
        }
        else{
            openButton.isEnabled = true
            closeButton.isEnabled = false
        }
    }
    
    
    /// 完成按钮
    @IBAction func OnOk(_ sender: Any) {
        // 关闭窗口
        self.dismiss(self)
    }
    
    /// 服务器开启按钮
    @IBAction func OnOpen(_ sender: Any) {
        let ss = netGameServer.openServer()
        if (netGameServer.serverState == .serving){
            openButton.isEnabled = false
            closeButton.isEnabled = true
            self.callbackFunc?(.serverOpen)
        }
        serverStateText.stringValue = ss
    }
    
    /// 服务器关闭按钮
    @IBAction func OnClose(_ sender: Any) {
        
        
        netGameServer.closeServer()
        serverStateText.stringValue = "服务器关闭"
        openButton.isEnabled = true
        closeButton.isEnabled = false
        self.callbackFunc?(.serverClose)
    }
    
 
    
    
}
