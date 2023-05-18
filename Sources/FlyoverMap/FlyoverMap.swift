import MapKit
import SwiftUI
import Combine

// MARK: - FlyoverMap

extension FlyoverPlaybackSequence {
    public struct Point {
        let coordinate: CLLocationCoordinate2D
        /// The Flyover Configuration
        let configuration: Flyover.Configuration

        public init(coordinate: CLLocationCoordinate2D, configuration: Flyover.Configuration) {
            self.coordinate = coordinate
            self.configuration = configuration
        }
    }

    public static func singular(coordinate: CLLocationCoordinate2D, configuration: Flyover.Configuration) -> Self {
        .init(points: [
            .init(coordinate: coordinate, configuration: configuration)
        ])
    }
}

/// A FlyoverMap
public struct FlyoverMap {
    
    // MARK: Properties

    /// Bool value if Flyover is started
    private let isStarted: Bool
    
    /// The MapType
    private let mapType: MKMapType

    /// An object which controls playback e.g. switching between coordinates
    @ObservedObject private var player: FlyoverSequencePlayer

    /// A sequence of locations to be played by 'player: FlyoverSequencePlayer'
    private let sequence: FlyoverPlaybackSequence
    
    /// A closure to update the underlying FlyoverMapView
    private let updateMapView: ((FlyoverMapView) -> Void)?

    /// A closure to notify when player goes to the next item
    private var playerIndexChanged: ((Int) -> Void)?

    
    // MARK: Initializer
    
    /// Creates a new instance of `FlyoverMap`
    /// - Parameters:
    ///   - isStarted: Bool value if Flyover is started. Default value `true`
    ///   - coordinate: The Coordinate
    ///   - configuration: The Flyover Configuration. Default value `.default`
    ///   - mapView: The MapType. Default value `.standard`
    ///   - updateMapView: A closure to update the underlying FlyoverMapView. Default value `nil`
    public init(
        isStarted: Bool = true,
        coordinate: CLLocationCoordinate2D,
        configuration: Flyover.Configuration = .default,
        mapType: MKMapType = .standard,
        updateMapView: ((FlyoverMapView) -> Void)? = nil
    ) {
        self.isStarted = isStarted
        self.sequence = .singular(coordinate: coordinate, configuration: configuration)
        self.player = .init(sequence: sequence, isPlaying: isStarted)
        self.mapType = mapType
        self.updateMapView = updateMapView
    }


    public init(
        isStarted: Bool = true,
        sequence: FlyoverPlaybackSequence,
        playerIndex: Int = 0,
        mapType: MKMapType = .standard,
        updateMapView: ((FlyoverMapView) -> Void)? = nil,
        playerIndexChanged: ((Int) -> Void)? = nil
    ) {
        self.isStarted = isStarted
        self.sequence = sequence
        self.player = .init(sequence: sequence, isPlaying: isStarted)
        self.mapType = mapType
        self.updateMapView = updateMapView
        self.playerIndexChanged = playerIndexChanged

        self.player.index = playerIndex

        player.$index.sink {
            playerIndexChanged?($0)
        }.store(in: &player.bag)
    }
    
}

// MARK: - Convenience Initializer

public extension FlyoverMap {
    
    /// Creates a new instance of `FlyoverMap`
    /// - Parameters:
    ///   - isStarted: Bool value if Flyover is started. Default value `true`
    ///   - latitude: The latitude.
    ///   - longitude: The longitude.
    ///   - configuration: The Flyover Configuration. Default value `.default`
    ///   - mapView: The MapType. Default value `.standard`
    ///   - updateMapView: A closure to update the underlying FlyoverMapView. Default value `nil`
    init(
        isStarted: Bool = true,
        latitude: CLLocationDegrees,
        longitude: CLLocationDegrees,
        configuration: Flyover.Configuration = .default,
        mapType: MKMapType = .standard,
        updateMapView: ((FlyoverMapView) -> Void)? = nil
    ) {
        self.init(
            isStarted: isStarted,
            coordinate: .init(
                latitude: latitude,
                longitude: longitude
            ),
            configuration: configuration,
            mapType: mapType,
            updateMapView: updateMapView
        )
    }
    
}

// MARK: - UIViewRepresentable

extension FlyoverMap: UIViewRepresentable {
    
    /// Make MKMapView
    /// - Parameter context: The Context
    public func makeUIView(
        context: Context
    ) -> FlyoverMapView {
        .init()
    }
    
    /// Update MKMapView
    /// - Parameters:
    ///   - flyoverMapView: The FlyoverMapView
    ///   - context: The Context
    public func updateUIView(
        _ flyoverMapView: FlyoverMapView,
        context: Context
    ) {
        flyoverMapView.mapType = self.mapType
        // Update map view if needed
        self.updateMapView?(flyoverMapView)
        // Check if is started
        if self.isStarted {
            // Start Flyover
            flyoverMapView.startFlyover(
                at: self.player.currentPoint.coordinate,
                configuration: self.player.currentPoint.configuration
            )
        } else {
            // Stop Flyover
            flyoverMapView.stopFlyover()
        }
    }
    
}
