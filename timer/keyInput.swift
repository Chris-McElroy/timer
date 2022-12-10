//
//  keyInput.swift
//  timer
//
//  Created by Chris McElroy on 11/7/22.
//

import SwiftUI

// based off https://stackoverflow.com/a/61155272/8222178
struct KeyEventHandling: NSViewRepresentable {
	let view: KeyView = KeyView()
	
	init(handleKeyDown: @escaping (NSEvent) -> Void, ready: @escaping () -> Void, start: @escaping () -> Void, end: @escaping () -> Void) {
		view.handleKeyDown = handleKeyDown
		view.ready = ready
		view.start = start
		view.end = end
	}
	
	class KeyView: NSView {
		let leftControl = NSEvent.ModifierFlags(rawValue: 1048840)
		let rightOption = NSEvent.ModifierFlags(rawValue: 524608)
		let readyKeys = NSEvent.ModifierFlags(rawValue: 1573192)
		var lastPress: NSEvent.ModifierFlags = NSEvent.ModifierFlags.init([])
		var spaceTimer: Timer? = nil
		
		var handleKeyDown: (NSEvent) -> Void = { _ in }
		var ready: () -> Void = {}
		var start: () -> Void = {}
		var end: () -> Void = {}
		
		override var acceptsFirstResponder: Bool { true }
		
		override func keyDown(with event: NSEvent) {
			handleKeyDown(event)
		}
		
		override func flagsChanged(with event: NSEvent) {
			if event.modifierFlags == readyKeys {
				if lastPress != readyKeys {
					ready()
				}
			} else if lastPress == readyKeys {
				start()
			}
			if event.modifierFlags.isStrictSuperset(of: lastPress) {
				end()
			}
			lastPress = event.modifierFlags
		}
	}

	func makeNSView(context: Context) -> NSView {
		DispatchQueue.main.async { // wait till next event cycle
			view.window?.makeFirstResponder(view)
		}
		return view
	}

	func updateNSView(_ nsView: NSView, context: Context) {
	}
}
