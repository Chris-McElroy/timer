//
//  timerApp.swift
//  timer
//
//  Created by Chris McElroy on 6/28/22.
//

import SwiftUI

@main
struct timerApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ notification: Notification) {
		if let window = NSApplication.shared.windows.first {
			window.titleVisibility = .hidden
			window.titlebarAppearsTransparent = true
		}
		return
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}
}
