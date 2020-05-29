//
//  MainView.swift
//  MacOneApp
//
//  Created by 江龙 on 2020/5/13.
//  Copyright © 2020 江龙. All rights reserved.
//

import Cocoa

class MainView: NSView {
    
    // 游戏类由VC初始化提供
    var game: Game?
    /// 用于标志红对黑游戏
    var  reversal = false

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        
        // 游戏已经开始
        if(game!.gameState){
            // 绘制棋盘
            let width = game!.checkerboard.boardSize!.width
            let height = game!.checkerboard.boardSize!.height
            game?.checkerboard.boardImage?.draw(at: NSMakePoint(0, 0), from: CGRect(x: 0, y: 0, width: width, height: height), operation: .copy, fraction: 100)
            // 绘制棋子
            for x in 0...8{
                for y in 0...9{
                    // 提请红黑坐标转换
                    let point = reversalCoordinate(game!.checkerboard.grid[x][y])
                    let rect = NSMakeRect(point.x-25 ,point.y-25,50,50)
                    game?.checkerboard.pieces[x][y]?.pieceImage?.draw(in: rect)
                }
            }
            
            // 绘制提起的棋子
            if (game?.raisePiece != nil ){
                // 提请红黑坐标转换
                let point = reversalCoordinate(game!.raisePiece!.point)
                let rect = NSMakeRect(point.x-25 ,point.y-25,50,50)
                game?.raisePiece?.piece?.pieceImage?.draw(in: rect)
            }
            
        }
        
        
        
    }
    
    /// 红黑对战坐标转换，事先要设置reversal，false为黑对红 ture 为红对黑
    func reversalCoordinate(_ oldPoint: NSPoint) ->NSPoint{
        let size = self.game!.checkerboard.boardSize!
        var newPoint = oldPoint
        let r = game!.checkerboard.pieceSize.width/2
        
        
        // 位置限制
        if (newPoint.x<r){newPoint.x = r}
        else if (newPoint.x > size.width-r){newPoint.x = size.width - r}
        if (newPoint.y<r){newPoint.y = r}
        else if (newPoint.y > size.height-r){newPoint.y = size.height - r}
        
        // 红对黑坐标转置
        if(reversal){
            newPoint.x = abs(newPoint.x - size.width)
            newPoint.y = abs(newPoint.y - size.height)
        }
    
        return newPoint
    }
    
    
}
