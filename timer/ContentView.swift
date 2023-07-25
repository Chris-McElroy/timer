//
//  ContentView.swift
//  timer
//
//  Created by Chris McElroy on 6/28/22.
//

import SwiftUI

struct ContentView: View {
	@State var time: Int = 0
	@State var startTime: Int = 0
	@State var timer: Timer? = nil
	@State var ready: Bool = false
	@State var save: Bool = false
	@State var delete: Bool = false
	@State var showTimes: Bool = false
	@State var showMinutes: Bool = false
	@State var times: [Int] = allTimes()
	@State var startMenu: Bool = true
	@State var endMenu: Bool = false
	@State var finishedRounds: Bool = false
	@State var totalRounds: Int? = nil
	@State var roundsRemaining: Int? = nil
	@State var deleteRecordedTime: (Int, Int)? = nil
	@State var update: Bool = false
	
    var body: some View {
		ZStack {
			HStack {
				Spacer()
				VStack {
					Spacer().frame(height: 100)
					Spacer()
					Text(timeString(time))
						.font(.system(size: 100))
					Spacer().opacity(update ? 1 : 0)
					Text(subText)
					Spacer()
				}
				Spacer()
			}
					.frame(minWidth: 240, minHeight: 240)
					.background(Rectangle().foregroundColor(.black))
					.background(KeyEventHandling(handleKeyDown: handleKeyDown, ready: setReady, start: startTimer, end: end))
					.onTapGesture {
						end()
					}
			if startMenu {
				VStack(spacing: 50) {
					Text("1 round").onTapGesture { start(withRounds: 1) }
					Text("3 rounds").onTapGesture { start(withRounds: 3) }
					Text("5 rounds").onTapGesture { start(withRounds: 5) }
					Text("indefinite").onTapGesture { start(withRounds: nil) }
				}
				.frame(minWidth: 200, maxWidth: 1000, minHeight: 200, maxHeight: 1000)
				.background(Rectangle().foregroundColor(.black))
			}
			if endMenu {
				let rounds = totalRounds ?? 1
				if rounds == 1 {
					Text(timeString(times.last ?? 0))
						.textSelection(.enabled)
						.frame(minWidth: 200, maxWidth: 1000, minHeight: 200, maxHeight: 1000)
						.background(Rectangle().foregroundColor(.black))
						.font(.system(size: 36))
				} else {
					let roundTimes = times.dropFirst(times.count - rounds)
					let middle = Double(roundTimes.sorted().dropFirst().dropLast().reduce(0, { $0 + $1 }))
					let middleAv = Int((middle/Double(rounds - 2)).rounded(.toNearestOrAwayFromZero))
					let maxTime = roundTimes.max() ?? 0
					let minTime = roundTimes.min() ?? 0
					let summaryString = roundTimes.map({
						$0 == maxTime || $0 == minTime ? "(\(timeString($0)))" : timeString($0)
					}).joined(separator: "  ")
					VStack(spacing: 80) {
						Text("score: \(timeString(middleAv))")
						Text(summaryString)
					}
					.textSelection(.enabled)
					.frame(minWidth: 200, maxWidth: 1000, minHeight: 200, maxHeight: 1000)
					.background(Rectangle().foregroundColor(.black))
					.font(.system(size: 36))
				}
			}
			if showTimes {
				VStack {
					Spacer()
					let sortedTimes = times.sorted()
					ForEach(0..<10, id: \.self) { i in
						if sortedTimes.count > i {
							HStack {
								if deleteRecordedTime?.0 == i {
									Text("delete")
								} else {
									Text(String(i + 1) + ".")
								}
								Text(timeString(sortedTimes[i]))
								Text(deleteRecordedTime?.0 == i ? "?" : "X")
									.onTapGesture {
										deleteRecordedTime = (i, sortedTimes[i])
									}
							}
						} else {
							Text("xx")
						}
					}
					Spacer()
					if times.count > 5 {
						Text("past 5 average " + timeString(times.dropFirst(times.count - 5).reduce(0, { $0 + $1 })/5))
						 .padding(5)
					}
					if times.count > 25 {
						Text("past 25 average " + timeString(times.dropFirst(times.count - 25).reduce(0, { $0 + $1 })/25))
						 .padding(5)
					}
					if times.count >= 100 {
						Text("past 100 average " + timeString(times.dropFirst(times.count - 100).reduce(0, { $0 + $1 })/100))
							.padding(5)
					}
					Text("lifetime average " + timeString(times.reduce(0, { $0 + $1 })/times.count))
						.padding(5)
					Text("total count " + String(times.count))
						.padding(5)
					Spacer()
				}
				.frame(minWidth: 240, minHeight: 240)
				.background(Rectangle().foregroundColor(.black))
			}
		}
		.ignoresSafeArea()
		.foregroundColor(.white)
		.background(Rectangle().foregroundColor(.black))
    }
	
	var subText: String {
		if ready { return "ready" }
		if delete { return "delete?" }
		if save { return "save?" }
		return ""
	}
	
	static func allTimes() -> [Int] {
		UserDefaults.standard.array(forKey: "times") as? [Int] ?? []
	}
	
	func start(withRounds rounds: Int?) {
		startMenu = false
		totalRounds = rounds
		roundsRemaining = rounds
	}
	
	func startTimer() {
		guard !startMenu && !finishedRounds && !showTimes && !save else { return }
		ready = false
		startTime = Date.ms
		timer?.invalidate()
		timer = Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true, block: { _ in
			time = (Date.ms - startTime)
		})
	}
	
	func setReady() {
		guard !startMenu && !finishedRounds && !showTimes && !save else { return }
		ready = true
		time = 0
	}
	
	func end() {
		guard timer != nil else { return }
		timer?.invalidate()
		timer = nil
		time = (Date.ms - startTime)
		save = true
	}
	
	func handleKeyDown(event: NSEvent) {
		guard timer == nil else { end(); return }
		
		if event.characters == "t" && event.modifierFlags.rawValue == 256 {
			showTimes.toggle()
			return
		}
		
		if event.characters == "m" && event.modifierFlags.rawValue == 256 {
			showMinutes.toggle()
			return
		}
		
		if showTimes {
			if let deleteRecordedTime {
				if event.characters == "i" && event.modifierFlags.contains(.command) {
					if let badI = times.lastIndex(of: deleteRecordedTime.1) {
						times.remove(at: badI)
						UserDefaults.standard.set(times, forKey: "times")
					}
				}
				self.deleteRecordedTime = nil
			}
			return
		}
		
		if delete {
			if event.specialKey == .delete {
				deleteTime()
			} else {
				delete = false
			}
			return
		}
		
		if save && event.characters == "s" && event.modifierFlags.contains(.command) {
			saveTime()
			return
		}
		
		if save && event.characters == "i" && event.modifierFlags.contains(.command) {
			delete = true
			return
		}
	}
	
	func saveTime() {
		times.append(time)
		UserDefaults.standard.set(times, forKey: "times")
		startTime = 0
		if let prevRounds = roundsRemaining {
			roundsRemaining = prevRounds - 1
			if roundsRemaining == 0 {
				finishedRounds = true
				endMenu = true
			}
		}
		save = false
	}
	
	func deleteTime() {
		time = 0
		startTime = 0
		delete = false
		save = false
	}

	func timeString(_ n: Int) -> String {
		if showMinutes {
			return String(format: "%01d:%02d.%02d", n/60000, (n/1000) % 60, (n/10) % 100)
		}
		return String(format: "%01d.%02d", n/1000, (n/10) % 100)
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Date {
	static var now: TimeInterval {
		timeIntervalSinceReferenceDate
	}
	
	static var ms: Int {
		Int(now*1000)
	}
}
