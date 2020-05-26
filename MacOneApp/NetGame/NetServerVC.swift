//
//  NetServerVC.swift
//  MacOneApp
//
//  Created by 江龙 on 2020/5/19.
//  Copyright © 2020 江龙. All rights reserved.
//

import Cocoa

class NetServerVC: NSViewController,NetGameServerProtocol{
  
    /// NetGameServer 实例
    var netGameServer = NetGameServer()
    /// 存储父级回调函数
    var callbackFunc: ((ViewController.VCCallbackMSG)->())?
    
    
    @IBOutlet weak var clinetTableView: NSTableView!
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
        
        // 设置网络游戏服务器通知代理
        netGameServer.notifyDelegate = self
        // 设置数据列表代理
        clinetTableView.delegate = self
        clinetTableView.dataSource = self
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
    
    /// 数据列表数据行确定
    func numberOfRows(in tableView: NSTableView) -> Int {
        return netGameServer.gamePlayers.count
    }
    
    /// 数据列表数据绑定
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var newView: NSTableCellView?
        switch tableColumn?.identifier.rawValue {
        case "Name":
            newView = tableView.makeView(withIdentifier: .init("Name"), owner: nil) as? NSTableCellView
            newView?.textField?.stringValue = "\(row+1)号用户"
        case "IP":
            newView = tableView.makeView(withIdentifier: .init("IP"), owner: nil) as? NSTableCellView
            newView?.textField?.stringValue = self.netGameServer.gamePlayers[row].clientManager.tcpClient!.address
        case "Port":
            newView = tableView.makeView(withIdentifier: .init("Port"), owner: nil) as? NSTableCellView
            newView?.textField?.stringValue = "\( self.netGameServer.gamePlayers[row].clientManager.tcpClient!.port)"
        case "Group":
            newView = tableView.makeView(withIdentifier: .init("Port"), owner: nil) as? NSTableCellView
            newView?.textField?.stringValue = "\( self.netGameServer.gamePlayers[row].group)"
        default:
            newView = nil
        }
        return newView
    }
    // 更新列表
    func updateView(){
        DispatchQueue.main.async {
            self.clinetTableView.reloadData()
        }
    }
    
//======== NetGameServerProtocol 协议实现============================================
   
  func addGamePlayer() {
       updateView()
   }
   
   func delGamePlayer() {
       updateView()
   }
   
   func gamePlayerReady() {
       updateView()
   }
    
    
}

extension NetServerVC: NSTableViewDelegate,NSTableViewDataSource{}
