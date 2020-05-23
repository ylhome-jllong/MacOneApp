//
//  NetServerVC.swift
//  MacOneApp
//
//  Created by 江龙 on 2020/5/19.
//  Copyright © 2020 江龙. All rights reserved.
//

import Cocoa

class NetServerVC: NSViewController {

    
    /// NetGame实例由主VC 初始化
    var netGame: NetGame?
    /// 存储父级回调函数
    var callbackFunc: ((String)->())?
    
    
    /// 按钮
    @IBOutlet weak var openButton: NSButton!
    @IBOutlet weak var closeButton: NSButton!
    @IBOutlet weak var serverStateText: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        serverStateText.stringValue = netGame!.serverState.describe
        if netGame!.serverState.stare{
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
        let ss = netGame!.openServer()
        if (ss.stare){
            openButton.isEnabled = false
            closeButton.isEnabled = true
            self.callbackFunc?("服务器开启")
        }
        serverStateText.stringValue = ss.describe
    }
    
    /// 服务器关闭按钮
    @IBAction func OnClose(_ sender: Any) {
        
        
        netGame!.closeServer()
        serverStateText.stringValue = netGame!.serverState.describe
        openButton.isEnabled = true
        closeButton.isEnabled = false
        self.callbackFunc?("服务器关闭")
    }
    
 
    
    
}
