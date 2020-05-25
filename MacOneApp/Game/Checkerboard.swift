//
//  Checkerboard.swift
//  MacOneApp
//
//  Created by 江龙 on 2020/5/13.
//  Copyright © 2020 江龙. All rights reserved.
//

import Cocoa
/// 棋盘类
class Checkerboard: NSObject {
    /// 棋盘图
    var boardImage: NSImage?
    /// 棋盘大小
    var boardSize: NSSize?
    /// 棋盘网格大小
    var lattice: NSSize?
    /// 棋盘点位 [x][y]
    var grid = [[NSPoint]]()  //数组的定义方式
    /// 旗子容器
    var pieces: [[Piece?]]!   // 可选型数组
    /// 棋子的大小
    private(set) var pieceSize = NSSize()
    
    /// 棋子容器初始化
    func initPieces() {
        pieces = [[Piece?]]()
        for _ in 1...9{//X轴
            var t_Pieces = [Piece?]()
            for _ in 1...10{// Y轴
                t_Pieces.append(nil)
            }
            pieces?.append(t_Pieces)
        }
    }
    
    
    /// 初始化棋盘
    func initBoard(boardSize: NSSize){
        self.boardSize = boardSize
        
        // 设置棋子的大小
        self.pieceSize = NSSize(width: 50, height: 50)
        
        // 计算间隔
        let jianGe_y = boardSize.height/11
        let jianGe_x = boardSize.width/10
        
        // 初始化网格
        for x in 1...9{
            var y_point = [NSPoint]()
            for y in 1...10{
                y_point.append(NSMakePoint(CGFloat(x)*jianGe_x, CGFloat(y)*jianGe_y))
            }
            grid.append(y_point)
        }
        
       
        
        // 画底板
        boardImage = NSImage(size: boardSize, flipped: true){
            (rect) -> Bool
            in
            NSColor.white.set()
            rect.fill()
            return true}
        
        // 画网格线
        let path = NSBezierPath()
        path.lineWidth = 1
        boardImage?.lockFocus()
        for i in 1...10{
            path.move(to: NSMakePoint(jianGe_x, CGFloat(i)*jianGe_y))
            path.line(to: NSMakePoint(boardSize.width-jianGe_x, CGFloat(i)*jianGe_y))
            path.stroke()
        }
        for i in 1...9{
            path.move(to: NSMakePoint(CGFloat(i)*jianGe_x, jianGe_y))
            path.line(to: NSMakePoint(CGFloat(i)*jianGe_x, boardSize.height-jianGe_y))
            path.stroke()
        }
        // 画特殊标志
        SmallScaleS(x: 1, y: 2, width: 5, path: path)
        SmallScaleS(x: 7, y: 2, width: 5, path: path)
        SmallScaleS(x: 1, y: 7, width: 5, path: path)
        SmallScaleS(x: 7, y: 7, width: 5, path: path)
        SmallScaleS(x: 0, y: 3, width: 5, path: path)
        SmallScaleS(x: 2, y: 3, width: 5, path: path)
        SmallScaleS(x: 4, y: 3, width: 5, path: path)
        SmallScaleS(x: 6, y: 3, width: 5, path: path)
        SmallScaleS(x: 8, y: 3, width: 5, path: path)
        SmallScaleS(x: 0, y: 6, width: 5, path: path)
        SmallScaleS(x: 2, y: 6, width: 5, path: path)
        SmallScaleS(x: 4, y: 6, width: 5, path: path)
        SmallScaleS(x: 6, y: 6, width: 5, path: path)
        SmallScaleS(x: 8, y: 6, width: 5, path: path)
        
        path.move(to: grid[3][0])
        path.line(to: grid[5][2])
        path.move(to: grid[3][2])
        path.line(to: grid[5][0])
        
        path.move(to: grid[3][9])
        path.line(to: grid[5][7])
        path.move(to: grid[3][7])
        path.line(to: grid[5][9])
        
        path.stroke()
        
        
        
        // 画楚河汉界
        NSColor.white.set()
        let rect = NSRect(x: grid[0][4].x+1,y:grid[0][4].y+1,width: 8*jianGe_x-2,height: jianGe_y-2)
        rect.fill()
        // 绘制文字
        let content = "              楚河       汉界"
        let str = NSMutableAttributedString(string: content)
        let selectedRange = NSRange(location: 0, length: content.count)
        // 设置文字字体
        let font=NSFont(name: "华文楷体", size:50);
        // 设置文字颜色
        let color = NSColor.gray
        str.addAttribute(.foregroundColor, value: color, range: selectedRange)
        str.addAttribute(.font, value:font!, range: selectedRange)
        // 绘制
        str.draw(at: NSMakePoint(grid[0][4].x,grid[0][4].y+12))
        
        
        
        
        boardImage?.unlockFocus()
        
    }
    
    
    
    
    
    /// 获得点击位置的棋子
    func getPiece(_ point: NSPoint ) -> Piece?{
        var piece:Piece?
        let r = pieceSize.width/2
        // 寻找可能的棋子
        for x in 0...8{
            for y in 0...9{
                if(point.x < grid[x][y].x + r && point.x > grid[x][y].x - r &&
                    point.y < grid[x][y].y + r && point.y > grid[x][y].y - r)
                {
                    piece = pieces[x][y]
                }
            }
        }
        return piece
        
    }
    
    
    /// 获得可放棋子的位置  没有找到返回-1
    func getPosition(_ point: NSPoint) -> (x: Int,y: Int){
        let r = pieceSize.width/2
        
        // 寻找附近可以放置棋子的位置
        for x in 0...8{
            for y in 0...9{
                if(point.x < grid[x][y].x + r && point.x > grid[x][y].x - r &&
                    point.y < grid[x][y].y + r && point.y > grid[x][y].y - r)
                {
                     return (x,y)
                }
            }
        }
        
        return(-1,-1)
    }

    
    
//========== 私有方法 ===================================================================
    /// 绘制棋盘小标志  要在上下文锁定的前提下使用 width 为离主线的距离
    private func SmallScaleS(x: Int , y: Int, width: CGFloat,path: NSBezierPath){
        
        let point = grid[x][y]
         // 小横线
        if (x != 0){
            path.move(to: NSPoint(x: point.x-(width+20),y: point.y+width))
            path.line(to: NSPoint(x: point.x-width,y: point.y+width))
            
            path.move(to: NSPoint(x: point.x-(width+20),y: point.y-width))
            path.line(to: NSPoint(x: point.x-width,y: point.y-width))
        }
        if (x != 8){
            path.move(to: NSPoint(x: point.x+(width+20),y: point.y+width))
            path.line(to: NSPoint(x: point.x+width,y: point.y+width))

            path.move(to: NSPoint(x: point.x+(width+20),y: point.y-width))
            path.line(to: NSPoint(x: point.x+width,y: point.y-width))
        }
         
         // 小竖线
        if(x != 0 ){
            path.move(to: NSPoint(x: point.x-width,y: point.y+(width+20)))
            path.line(to: NSPoint(x: point.x-width,y: point.y+width))
            
            path.move(to: NSPoint(x: point.x-width,y: point.y-(width+20)))
            path.line(to: NSPoint(x: point.x-width,y: point.y-width))
        }
        if (x != 8 ){
            path.move(to: NSPoint(x: point.x+width,y: point.y+(width+20)))
            path.line(to: NSPoint(x: point.x+width,y: point.y+width))

            path.move(to: NSPoint(x: point.x+width,y: point.y-(width+20)))
            path.line(to: NSPoint(x: point.x+width,y: point.y-width))
            
        }
        
         path.stroke()
    }
}
