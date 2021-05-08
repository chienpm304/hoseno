//
//  AppDelegate.swift
//  Hoseno
//
//  Created by Chien Pham on 5/8/21.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = OnboardView(viewModel: .init())

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        
        window.level = .floating
        // show notification
//        showNotification()
        
        NotificationCenter.default.addObserver(self, selector: #selector(pinWindow), name: .init("pin"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unpinWindow), name: .init("unpin"), object: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc private func pinWindow() {
        window.level = .floating
    }
    
    @objc private func unpinWindow() {
        window.level = .normal
    }

    func showNotification() -> Void {
        let notification = NSUserNotification()
        
        // All these values are optional
        notification.title = "Test of notification"
        notification.subtitle = "Subtitle of notifications"
        notification.informativeText = "Main informative text"
        notification.contentImage = NSImage(named: "Icon")
        notification.soundName = NSUserNotificationDefaultSoundName
        
        NSUserNotificationCenter.default.deliver(notification)
        
    }
}

