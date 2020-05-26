//
//  ViewController.swift
//  MacOneApp
//
//  Created by 江龙 on 2020/5/13.
//  Copyright © 2020 江龙. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    /// 主视图
    var mainView: MainView!
    /// 游戏实例
    var game:Game?
    /// 网络游戏实例
    var netGame: NetGame?

    
    /// 鼠标按下时收集的数据
    struct MouseData {
        /// 标志是否提起
        var downFlag = false
        // 存储相对位置差
        var dpoint = NSPoint(x: 0,y: 0)
    }
    var mouesData = MouseData()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 设置视图的大小
        mainView = self.view as? MainView
        mainView.setFrameSize(NSMakeSize(1000, 800))
        
        // 初始化游戏
        game = Game(viewSize: NSMakeSize(800,800))
        mainView.game = game
        
        // 初始化网络游戏
        netGame = NetGame()
        // 设置netGame事件处理代理
        netGame?.delegate = self
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    /// 鼠标按下时
    override func mouseDown(with event: NSEvent) {
        // 游戏没有开始跳出
        if(!game!.gameState){return}
        
        // 提请红黑坐标转换
        let point = mainView.reversalCoordinate(event.locationInWindow)
        
        // 我方是否有权移动棋子,无权则跳出不进行后续处理(网络对战才需要)
        if(netGame!.netGameState == .play && (game!.attacker != netGame!.myTeam)){return}
        
        // 鼠标按下后处理
        mouseDown(point: point )
        
        // 发送鼠标事件
        if(netGame!.netGameState == .play){netGame?.netMouseDown(point: point)}

    }
    /// 鼠标按压处理
    func mouseDown(point: NSPoint){
       
        if (!mouesData.downFlag){
            // 提起棋子
            mouesData.downFlag = game!.raise(point)
        
            // 计算鼠标与棋子中心的距离（提升流畅度）
            if(mouesData.downFlag){
                mouesData.dpoint.x = game!.raisePiece!.point.x - point.x
                mouesData.dpoint.y = game!.raisePiece!.point.y - point.y
            }
            mainView.needsDisplay = true
            
        }
    }
    
    
    
    
    /// 拖动鼠标时
    override func mouseDragged(with event: NSEvent) {
        // 游戏没有开始跳出
        if(!game!.gameState){return}
        
        if(mouesData.downFlag){
            // 提请红黑坐标转换
            let point = mainView.reversalCoordinate(event.locationInWindow)
            mouseDragged(point: point)
            // 发送鼠标事件
            if(netGame!.netGameState == .play){netGame?.netMouseDragged(point: point)}
        }
    }
    /// 鼠标拖动处理
    func mouseDragged(point: NSPoint){
        // 计算棋子中心位置提升流畅度
        var _point = point
        _point.x += mouesData.dpoint.x
        _point.y += mouesData.dpoint.y
        // 移动棋子
        game?.move(_point)
        mainView.needsDisplay = true
    }
    
    
    
    
    /// 鼠标抬起
    override func mouseUp(with event: NSEvent) {
        // 游戏没有开始跳出
        if(!game!.gameState){return}
        
        if mouesData.downFlag {
            let point = mainView.reversalCoordinate(event.locationInWindow)
            mouseUp(point: point)
            // 发送鼠标事件
            if(netGame!.netGameState == .play){netGame?.netMouseUp(point: point)}
        }
    }
    func mouseUp(point: NSPoint){
        // 放下棋子
        game?.lay()
        mouesData.downFlag = false
        mainView.needsDisplay = true
    }
    
    
    
    
    
    
    /// 关联菜单New新建游戏
    @IBAction func OnNew(_ sender: Any?){
        game?.playGame()
        mainView.reversal = false
        mainView.needsDisplay = true
        updateMenu()
        
    }
    /// 关联菜单New新建红对黑游戏
    @IBAction func OnNewPlus(_ sender: Any?){
        game?.playGame()
        mainView.reversal = true
        mainView.needsDisplay = true
        updateMenu()
    }
    /// 关联菜单关闭游戏
    @IBAction func OnCloseGame(_ sender: Any?){
        var str = self.view.window!.title
        if let range = str.range(of: " - 已连接服务器"){
            str.removeSubrange(range)
            self.view.window!.title = str
        }
        
        // 结束游戏
        // 如果连接了服务器，就断开服务器
        if(netClientVC!.netGame!.clientState){netClientVC?.OnDisconnect(self)}
        self.game?.stopGame()
        self.mainView.needsDisplay = true
        updateMenu()
    }
    
    
    
    
//======== 网络对战 =======================================================================
    
    /// 网络游戏服务器VC实例
    var netServerVC: NetServerVC?
    /// 网络游戏客户端VC实例
    var netClientVC: NetClientVC?
    
    
    /// 关联菜单 网络游戏服务器
    @IBAction func OnNetGameServer(_ sender: Any?){
        if(netServerVC == nil)
        {
            // 获得Storyboard “NetServerVC" sceneIdentifier
            let sceneIdentifier=NSStoryboard.SceneIdentifier("NetServerVC")
            // 获得Storyboard 中的PopViewController 对象
            netServerVC = self.storyboard?.instantiateController(withIdentifier: sceneIdentifier) as? NetServerVC
            
            // 初始化netGame实例
            //if(netGame == nil){netGame = NetGame()}
            netServerVC!.callbackFunc = self.callbackFunc
        }
        // 弹出窗口
        self.presentAsSheet(netServerVC!)
    }

    /// 关联菜单 连接网络游戏
    @IBAction func OnLinkGameServer(_ sender: Any?){
        if(netClientVC == nil){
            // 获得Storyboard “NetServerVC" sceneIdentifier
            let sceneIdentifier=NSStoryboard.SceneIdentifier("NetClientVC")
            // 获得Storyboard 中的PopViewController 对象
            netClientVC = self.storyboard?.instantiateController(withIdentifier: sceneIdentifier) as? NetClientVC
                
            // 初始化netGame实例
            //if(netGame == nil){netGame = NetGame()}
            netClientVC!.netGame = netGame
            netClientVC!.callbackFunc = self.callbackFunc
            }
            // 弹出窗口
            self.presentAsSheet(netClientVC!)
        }
    
    /// VC类信息回调函数消息
    enum VCCallbackMSG {
        /// 服务器开启
        case serverOpen
        /// 服务器关闭
        case serverClose
        /// 连接服务器
        case linkServer
        /// 断开服务器
        case disconnectServer
        /// 准备开始游戏
        case readyGame
    }
    

    /// 信息回调函数
    func callbackFunc(msg: VCCallbackMSG){
        switch msg {
        case .serverOpen:self.view.window?.title += " - 网络服务开启"
        case .serverClose:
            var str = self.view.window!.title
            let range = str.range(of: " - 网络服务开启")
            str.removeSubrange(range!)
            self.view.window!.title = str
        case .linkServer:
            self.view.window?.title += " - 已连接服务器"
        case .disconnectServer:
            self.OnCloseGame(nil)
        case .readyGame:
            self.updateMenu()
        }
     }
    func updateMenu(){
        let mainMenu = NSApp.mainMenu
        let fileMenuItem = mainMenu?.item(withTitle: "File")
        // 要先设置父级NSMenu 的属性 autoenablesItems = false 然后再设置NSMenuItems 的 属性isEnabled 才有效
        fileMenuItem?.submenu?.autoenablesItems = false
        
        switch self.netGame?.netGameState {
        case .free:
            fileMenuItem?.submenu?.item(withTitle: "新建黑对红")?.isEnabled = true
            fileMenuItem?.submenu?.item(withTitle: "新建红对黑")?.isEnabled = true
        case .play,.realy:
            fileMenuItem?.submenu?.item(withTitle: "新建黑对红")?.isEnabled = false
            fileMenuItem?.submenu?.item(withTitle: "新建红对黑")?.isEnabled = false
        default:
            break
        }

       
        
          
    }
}

///扩展NetGameProtocol协议
extension ViewController: NetGameProtocol{}

