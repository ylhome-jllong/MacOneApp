//
//  AppDelegate.swift
//  MacOneApp
//
//  Created by 江龙 on 2020/5/13.
//  Copyright © 2020 江龙. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // 窗口（应用）关闭应用不可以终止 后点击Dock菜单再次打开应用
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        sender.windows[0].makeKeyAndOrderFront(self)
        return true
    }
    
}

