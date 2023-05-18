//
//  FlyoverSequencePlayer.swift
//  
//
//  Created by Константин on 17.05.2023.
//

import Foundation
import Combine

public struct FlyoverPlaybackSequence {
    public let points: [Point]

    public init(points: [FlyoverPlaybackSequence.Point]) {
        self.points = points
    }
}

final class FlyoverSequencePlayer: ObservableObject {
    @Published var index: Int = 0
    let sequence: FlyoverPlaybackSequence

    private var timer: Timer.TimerPublisher?
    var bag = Set<AnyCancellable>()

    var currentPoint: FlyoverPlaybackSequence.Point {
        sequence.points[index]
    }

    init(sequence: FlyoverPlaybackSequence, isPlaying: Bool) {
        self.sequence = sequence
        if isPlaying {
            restart()
        }
    }

    func restart() {
        timer?.connect().cancel()
        guard currentPoint.configuration.playbackDuration > 0 else { return }
        timer = Timer.publish(every: currentPoint.configuration.playbackDuration, on: .main, in: .common)
        timer?
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink { date in
                self.index = (self.index + 1) % self.sequence.points.count
                self.restart()
            }.store(in: &bag)

    }

    func pause() {
        timer?.connect().cancel()
    }

}
