//
//  Game.swift
//  MacOneApp
//
//  Created by 江龙 on 2020/5/14.
//  Copyright © 2020 江龙. All rights reserved.
//

import Cocoa
/// 游戏实现类，默认黑对红
class Game: NSObject {
    /// 视图大小
    var viewSize: NSSize?
    /// 棋盘
    var checkerboard = Checkerboard()
    /// 棋子
    var piece = [Piece?]()
    /// 提起的棋子
    struct RaisePiece {
        /// 保存提起的棋子
        var piece: Piece?
        /// 保存棋子现在的view坐标
        var point = NSPoint(x: 0,y: 0)
    }
    /// 提起的棋子
    var raisePiece: RaisePiece?
    
    
    
    
    /// 规则返回值
    enum RuleRet {
        /// 可以移动
        case move;
        ///  吃
        case take;
        /// 失败
        case fail;
    }
    /// 现在的进攻方
    private(set) var attacker = Piece.TeamType.black
    /// 游戏状态
    private(set) var gameState = false
    
    
    
    
    /// 初始化  viewSize 视图大小
    init(viewSize: NSSize){
        self.viewSize = viewSize
        super.init()
    }
    /// 开始游戏
    func playGame(){
        // 棋盘初始化
        checkerboard.initBoard(boardSize: self.viewSize!)
        // 棋盘容器初始化
        checkerboard.initPieces()
        // 生成棋子
        generatePieces()
        // 进攻方设置为黑方
        attacker = .black
        // 标志游戏状态
        gameState = true
    }
    /// 结束游戏
    func stopGame(){
        gameState = false
        
    }
    
    
    /// 提起棋子
    func raise(_ point: NSPoint) -> Bool {
        // 获得棋子
        let piece =  checkerboard.getPiece(point)
        // 不为空且是现在的进攻方
        if(piece != nil && piece?.team == attacker){
            let x = piece!.position.x
            let y = piece!.position.y
            checkerboard.pieces[x][y] = nil
            // 创建提起棋子的盒子
            raisePiece = RaisePiece()
            raisePiece!.piece = piece
            raisePiece!.point = checkerboard.grid[x][y]
            return true
        }
        
        return false
    }
    
    /// 移动棋子
    func move(_ point: NSPoint){
        raisePiece?.point = point
    }
    
    /// 放下下棋子
    func lay(){
        var rr = RuleRet.fail
        let pos = checkerboard.getPosition(raisePiece!.point)
        if(pos.x != -1){rr = self.rule(newPos: pos)}
        
        if (rr == .move || rr == .take){
            // 放入棋子
            raisePiece?.piece?.position = (pos.x,pos.y)
            checkerboard.pieces[pos.x][pos.y] = raisePiece?.piece
            // 清空
            raisePiece = nil
            // 进攻方交换
            if(attacker == .black){attacker = .red }
            else{attacker = .black}
        }
        else //不可发棋子弹回原处
        {
            let x = raisePiece!.piece!.position.x
            let y = raisePiece!.piece!.position.y
            
            checkerboard.pieces[x][y] = raisePiece?.piece
            
            // 清空
            raisePiece = nil
        }
    }
    
    
    
    
    
//========== 私有方法 ====================================================================
    /// 生成棋子
    private func generatePieces(){
        let size = checkerboard.pieceSize
        checkerboard.pieces[0][0] = Piece(nID: 0, type:.車, position: (0,0),team: .black, size: size)
        checkerboard.pieces[1][0] = Piece(nID: 1, type:.馬,position: (1,0), team: .black, size: size)
        checkerboard.pieces[2][0] = Piece(nID: 2, type:.象, position: (2,0),team: .black, size: size)
        checkerboard.pieces[3][0] = Piece(nID: 3, type:.士, position: (3,0), team: .black, size: size)
        checkerboard.pieces[4][0] = Piece(nID: 4, type:.将, position: (4,0), team: .black, size: size)
        checkerboard.pieces[5][0] = Piece(nID: 5, type:.士, position: (5,0), team: .black, size: size)
        checkerboard.pieces[6][0] = Piece(nID: 6, type:.象, position: (6,0), team: .black, size: size)
        checkerboard.pieces[7][0] = Piece(nID: 7, type:.馬, position: (7,0), team: .black, size: size)
        checkerboard.pieces[8][0] = Piece(nID: 8, type:.車, position: (8,0), team: .black, size: size)
        checkerboard.pieces[1][2] = Piece(nID: 9, type:.炮, position: (1,2), team: .black, size: size)
        checkerboard.pieces[7][2] = Piece(nID: 10, type:.炮, position: (7,2), team: .black, size: size)
        
        checkerboard.pieces[0][3] = Piece(nID: 11, type:.兵, position: (0,3), team: .black, size: size)
        checkerboard.pieces[2][3] = Piece(nID: 12, type:.兵, position: (2,3), team: .black, size: size)
        checkerboard.pieces[4][3] = Piece(nID: 13, type:.兵, position: (4,3), team: .black, size: size)
        checkerboard.pieces[6][3] = Piece(nID: 14, type:.兵, position: (6,3), team: .black, size: size)
        checkerboard.pieces[8][3] = Piece(nID: 15, type:.兵, position: (8,3), team: .black, size: size)
        
        
        checkerboard.pieces[0][9] = Piece(nID: 16, type:.車, position: (0,9),team: .red, size: size)
        checkerboard.pieces[1][9] = Piece(nID: 17, type:.馬,position: (1,9), team: .red, size: size)
        checkerboard.pieces[2][9] = Piece(nID: 18, type:.象, position: (2,9),team: .red, size: size)
        checkerboard.pieces[3][9] = Piece(nID: 19, type:.士, position: (3,9), team: .red, size: size)
        checkerboard.pieces[4][9] = Piece(nID: 20, type:.将, position: (4,9), team: .red, size: size)
        checkerboard.pieces[5][9] = Piece(nID: 21, type:.士, position: (5,9), team: .red, size: size)
        checkerboard.pieces[6][9] = Piece(nID: 22, type:.象, position: (6,9), team: .red, size: size)
        checkerboard.pieces[7][9] = Piece(nID: 23, type:.馬, position: (7,9), team: .red, size: size)
        checkerboard.pieces[8][9] = Piece(nID: 24, type:.車, position: (8,9), team: .red, size: size)
        checkerboard.pieces[1][7] = Piece(nID: 25, type:.炮, position: (1,7), team: .red, size: size)
        checkerboard.pieces[7][7] = Piece(nID: 26, type:.炮, position: (7,7), team: .red, size: size)

        checkerboard.pieces[0][6] = Piece(nID: 27, type:.兵, position: (0,6), team: .red, size: size)
        checkerboard.pieces[2][6] = Piece(nID: 28, type:.兵, position: (2,6), team: .red, size: size)
        checkerboard.pieces[4][6] = Piece(nID: 29, type:.兵, position: (4,6), team: .red, size: size)
        checkerboard.pieces[6][6] = Piece(nID: 30, type:.兵, position: (6,6), team: .red, size: size)
        checkerboard.pieces[8][6] = Piece(nID: 31, type:.兵, position: (8,6), team: .red, size: size)
    }
    
    /// 规则
    private func rule(newPos: (x: Int,y: Int)) -> RuleRet{
        // 没有移动
        if(newPos == raisePiece!.piece!.position ){return .fail}
        var rr = RuleRet.fail
        
        // 明将判断
        if(rule_jiang_ming(newPos: newPos)){return rr}
        
        // 各种类型的棋子
        switch raisePiece?.piece?.type {
        case .車:rr = rule_che(newPos: newPos)
        case .炮:rr = rule_pao(newPos: newPos)
        case .馬:rr = rule_ma(newPos: newPos)
        case .象:rr = rule_xiang(newPos: newPos)
        case .兵:rr = rule_bing(newPos: newPos)
        case .将:rr = rule_jiang(newPos: newPos)
        case .士:rr = rule_shi(newPos: newPos)
        default:
            break
        }
        return rr
    }
    /// 对于车的规则
    private func rule_che(newPos: (x: Int,y: Int)) -> RuleRet{
        let piece = raisePiece!.piece!
        let oldx = piece.position.x
        let oldy = piece.position.y
        
        // 是否可以移动
        if ((oldx - newPos.x) != 0 && (oldy - newPos.y) != 0){return .fail}
        if (oldx - newPos.x) == 0{
            let miny = oldy < newPos.y ? oldy : newPos.y
            let maxy = oldy > newPos.y ? oldy : newPos.y
            for y in (miny+1) ..< maxy{
                if (checkerboard.pieces[oldx][y] != nil)
                {
                    return .fail
                }
            }
        }
        else{
            let minx = oldx < newPos.x ? oldx : newPos.x
            let maxx = oldx > newPos.x ? oldx : newPos.x
            for x in (minx+1) ..< maxx{
                if (checkerboard.pieces[x][oldy] != nil)
                {
                    return .fail
                }
            }
           
        }
        
        // 是否可以吃对方
        let objPiece = checkerboard.pieces[newPos.x][newPos.y]
        if(objPiece != nil ){
            if objPiece?.team == piece.team {
                // 是自己方棋子
                return .fail
            }
            else{
            return .take
            }
        }
   
        return .move
        
    }
    
    /// 对于炮的规则
    private func rule_pao(newPos:(x: Int,y: Int) ) -> RuleRet{
        let piece = raisePiece!.piece!
        let oldx = piece.position.x
        let oldy = piece.position.y
        // 间隔棋子数
        var spacing = 0
               
       // 是否可以移动
       // 非直线移动
       if ((oldx - newPos.x) != 0 && (oldy - newPos.y) != 0){return .fail}

       // y 方向移动
       if (oldx - newPos.x) == 0{
           let miny = oldy < newPos.y ? oldy : newPos.y
           let maxy = oldy > newPos.y ? oldy : newPos.y
           for y in (miny+1) ..< maxy{
               if (checkerboard.pieces[oldx][y] != nil)
               {
                   spacing += 1
               }
           }
       }
      // x 方向移动
       else{
           let minx = oldx < newPos.x ? oldx : newPos.x
           let maxx = oldx > newPos.x ? oldx : newPos.x
           for x in (minx+1) ..< maxx{
               if (checkerboard.pieces[x][oldy] != nil)
               {
                   spacing += 1
               }
           }
          
       }
       // 目标无棋子，中间无遮挡，可移动
        if (checkerboard.pieces[newPos.x][newPos.y] == nil && spacing == 0 ){return .move}
        // 目标棋子不是自己方，中间间隔1个，可吃
        if (checkerboard.pieces[newPos.x][newPos.y] != nil && spacing == 1 &&
            checkerboard.pieces[newPos.x][newPos.y]!.team != raisePiece!.piece!.team){return .take}
        // 其他无法成功
        return .fail
    }
    
    /// 对于马的规则
    private func rule_ma(newPos:(x: Int,y: Int) ) -> RuleRet{
        let dy = abs(newPos.y - raisePiece!.piece!.position.y)
        let dx = abs(newPos.x - raisePiece!.piece!.position.x)
        // 标志是否可以移动
        var moved = false
        // 可以移动判断
        if(dx == 1 && dy == 2){
            let ty = (newPos.y + raisePiece!.piece!.position.y)/2
            if(checkerboard.pieces[raisePiece!.piece!.position.x][ty] == nil){moved = true}
        }
        else if(dx == 2 && dy == 1){
            let tx = (newPos.x + raisePiece!.piece!.position.x)/2
            if(checkerboard.pieces[tx][raisePiece!.piece!.position.y] == nil){moved = true}
            
        }
        
        // 可以放下
        if (moved && checkerboard.pieces[newPos.x][newPos.y] == nil ) {return .move}
        // 可以吃
        if (moved && checkerboard.pieces[newPos.x][newPos.y] != nil
            && checkerboard.pieces[newPos.x][newPos.y]!.team != raisePiece!.piece!.team)
        {return .take}
        
        return .fail
    }
    
    /// 对于象的规则
    private func rule_xiang(newPos:(x: Int,y: Int)) -> RuleRet{
        
        // 象不可过河
        if(newPos.y > 4 && raisePiece!.piece!.team == .black){return .fail}
        if(newPos.y < 5 && raisePiece!.piece!.team == .red){return .fail}
        
        let dx = abs(newPos.x-raisePiece!.piece!.position.x)
        let dy = abs(newPos.y-raisePiece!.piece!.position.y)
        if(dx == 2 && dy == 2){
            let tx = (newPos.x + raisePiece!.piece!.position.x)/2
            let ty = (newPos.y + raisePiece!.piece!.position.y)/2
            // 有象脚
            if(checkerboard.pieces[tx][ty] != nil){return .fail}
            
            
            if(checkerboard.pieces[newPos.x][newPos.y] != nil ){
                // 目标位置有自己方棋子失败
                if(checkerboard.pieces[newPos.x][newPos.y]!.team == raisePiece!.piece!.team){
                    return .fail
                }
               // 目标位置有对方棋子吃
                else{
                    return .take
                }
            }
            //目标位置没有棋子可以移动
            else{
                return .move
            }
        }
        
        return .fail
    }
    
    /// 对于兵的规则
    private func rule_bing(newPos:(x: Int,y: Int)) -> RuleRet{
        
        // 兵不可后退
        if((newPos.y - raisePiece!.piece!.position.y) < 0 && raisePiece!.piece!.team == .black){return .fail}
        if((newPos.y - raisePiece!.piece!.position.y) > 0 && raisePiece!.piece!.team == .red){return .fail}
        // 兵行单步
        let dx = abs(newPos.x-raisePiece!.piece!.position.x)
        let dy = abs(newPos.y-raisePiece!.piece!.position.y)
        if((dx+dy) != 1){return .fail}
        // 过河前不可左右移动
        if(raisePiece!.piece!.team == .black && raisePiece!.piece!.position.y < 5 && dx != 0){return .fail}
        if(raisePiece!.piece!.team == .red && raisePiece!.piece!.position.y > 4 && dx != 0){return .fail}
        // 目标位置不为空
        if(checkerboard.pieces[newPos.x][newPos.y] != nil){
            // 有自己方棋子失败
            if(checkerboard.pieces[newPos.x][newPos.y]?.team == raisePiece!.piece!.team){
                return .fail
            }
            // 有对方棋子吃
            else{
                return .take
            }
        }
        // 目标位置为空
        else{
            return .move
        }
    }
    
    /// 对于士的规则
    private func rule_shi(newPos:(x: Int,y: Int)) -> RuleRet{
        
        // 限制在米格中
        if(raisePiece!.piece!.team == .black && (newPos.x < 3 || newPos.x > 5 || newPos.y > 2) ){return .fail}
        if(raisePiece!.piece!.team == .red && (newPos.x < 3 || newPos.x > 5 || newPos.y < 7 )){return .fail}
        // 走斜线
        let dx = abs(newPos.x-raisePiece!.piece!.position.x)
        let dy = abs(newPos.y-raisePiece!.piece!.position.y)
        if( dx*dy != 1){return .fail}
        
        
        // 目标位置有没有棋子的判断
        if(checkerboard.pieces[newPos.x][newPos.y] != nil){
            if(checkerboard.pieces[newPos.x][newPos.y]!.team == raisePiece!.piece!.team){return .fail}
            else{
                return .take
            }
        }
        else{
            return .move
        }
        
        
        
    }
    
    /// 对于将的规则
    private func rule_jiang(newPos:(x: Int,y: Int)) -> RuleRet{
        // 限制在米格中
        if(raisePiece!.piece!.team == .black && (newPos.x < 3 || newPos.x > 5 || newPos.y > 2) ){return .fail}
        if(raisePiece!.piece!.team == .red && (newPos.x < 3 || newPos.x > 5 || newPos.y < 7 )){return .fail}
        
        // 行单步
        let dx = abs(newPos.x-raisePiece!.piece!.position.x)
        let dy = abs(newPos.y-raisePiece!.piece!.position.y)
        if((dx+dy) != 1){return .fail}
        
       if(checkerboard.pieces[newPos.x][newPos.y] != nil){
            if(checkerboard.pieces[newPos.x][newPos.y]!.team == raisePiece!.piece!.team){return .fail}
            else{
                return .take
            }
        }
        else{
            return .move
        }
    }
        
    /// 对与明将的判断
    private func rule_jiang_ming(newPos:(x: Int,y: Int)) -> Bool{
        var piece_jiang = [Piece]()
        
        // 对将失败
        for x in 0...8{
            for y in 0...9{
                if(checkerboard.pieces[x][y]?.type == .将){
                    piece_jiang.append(checkerboard.pieces[x][y]!)
                }
            }
        }
        // 棋盘上有2个将时
        if (piece_jiang.count == 2){
            if(piece_jiang[0].position.x == piece_jiang[1].position.x){
                let y1 = piece_jiang[0].position.y
                let y2 = piece_jiang[1].position.y
                let miny = y1 < y2 ? y1 : y2
                let maxy = y1 > y2 ? y1 : y2
                var i = 0
                for y in miny+1 ..< maxy {
                    if (checkerboard.pieces[piece_jiang[0].position.x][y] != nil ){ i += 1}
                }
                if(newPos.x == piece_jiang[0].position.x ){i += 1 }
                if (i==0 ){return true}
            }
        }
        // 棋盘上有1个将时 (移动一定是将)
        if (piece_jiang.count == 1){
            if(piece_jiang[0].position.x == newPos.x){
                let y1 = piece_jiang[0].position.y
                let y2 = newPos.y
                let miny = y1 < y2 ? y1 : y2
                let maxy = y1 > y2 ? y1 : y2
                var i = 0
                for y in miny+1 ..< maxy {
                    if (checkerboard.pieces[piece_jiang[0].position.x][y] != nil ){ i += 1}
                }
                if (i==0 ){return true}
            }
        }
        
        
        return false
    }
}
