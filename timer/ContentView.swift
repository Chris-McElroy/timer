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
	@State var showTimes: Bool = false
	@State var times: [Int] = allTimes()
	@State var startMenu: Bool = true
	@State var endMenu: Bool = false
	@State var finishedRounds: Bool = false
	@State var totalRounds: Int? = nil
	@State var roundsRemaining: Int? = nil
	
    var body: some View {
		ZStack {
			HStack {
				Spacer()
				VStack {
					Spacer().frame(height: 100)
					Spacer()
					Text(timeString(time))
						.font(.system(size: 100))
					Spacer()
					Text(ready ? "ready" : (timer == nil ? "reset" : "end"))
					Spacer()
				}
				Spacer()
			}
					.frame(minWidth: 240, minHeight: 240)
					.background(Rectangle().foregroundColor(.black))
//					.gesture(startGesture)
					.background(KeyEventHandling(ready: {
						guard !startMenu && !finishedRounds && !showTimes else { return }
						ready = true
						time = 0
					}, start: {
						guard !startMenu && !finishedRounds && !showTimes else { return }
						ready = false
						startTime = Date.ms
						timer?.invalidate()
						timer = Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true, block: { _ in
							time = (Date.ms - startTime)
						})
					}, end: end, showTimes: {
						guard timer == nil else { end(); return }
						showTimes.toggle()
					}))
					.onTapGesture {
						end()
					}
			if startMenu {
				VStack(spacing: 50) {
					Text("1 round").onTapGesture { start(withRounds: 1) }
					Text("3 rounds").onTapGesture { start(withRounds: 3) }
					Text("5 rounds").onTapGesture { start(withRounds: 5) }
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
					let sortedTimes = times.sorted()
					ForEach(0..<10, id: \.self) { i in
						if sortedTimes.count > i {
							HStack {
								Text(timeString(sortedTimes[i]))
								Text("X")
									.onTapGesture {
										if let badI = times.firstIndex(of: sortedTimes[i]) {
											times.remove(at: badI)
											UserDefaults.standard.set(times, forKey: "times")
										}
									}
							}
						} else {
							Text("xx")
						}
					}
				}
				.frame(minWidth: 240, minHeight: 240)
				.background(Rectangle().foregroundColor(.black))
			}
		}
		.ignoresSafeArea()
		.foregroundColor(.white)
		.background(Rectangle().foregroundColor(.black))
    }
	
	static func allTimes() -> [Int] {
		UserDefaults.standard.array(forKey: "times") as? [Int] ?? []
	}
	
	func start(withRounds rounds: Int?) {
		startMenu = false
		totalRounds = rounds
		roundsRemaining = rounds
	}
	
	func end() {
		guard timer != nil else { return }
		timer?.invalidate()
		timer = nil
		time = (Date.ms - startTime)
		times.append(time)
		UserDefaults.standard.set(times, forKey: "times")
		startTime = 0
		if let prevRounds = roundsRemaining {
			roundsRemaining = prevRounds - 1
			if roundsRemaining == 0 {
				finishedRounds = true
				Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false, block: { _ in
					self.endMenu = true
				})
			}
		}
	}
	
	var startGesture: some Gesture {
		RotationGesture(minimumAngleDelta: .zero)
			.onChanged { _ in
				ready = true
			}
			.onEnded { _ in
				ready = false
				startTime = Date.ms
				timer?.invalidate()
				timer = Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true, block: { _ in
					time = (Date.ms - startTime)
				})
			}
	}
	
	func timeString(_ n: Int) -> String {
		String(format: "%01d.%02d", n/1000, (n/10) % 100)
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
