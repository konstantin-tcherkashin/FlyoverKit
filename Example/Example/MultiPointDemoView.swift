import FlyoverKit
import MapKit
import SwiftUI

struct MultiPointDemoView {
    /// Bool value whether Flyover is currently started or stopped
    @State
    private var isStarted = true

    /// The location
    @State
    private var points: [FlyoverPlaybackSequence.Point]

    /// The map type
    @State
    private var mapType: MKMapType = .hybridFlyover
}

// MARK: - View

extension MultiPointDemoView: View {

    /// The content and behavior of the view.
    var body: some View {
        ZStack {
            FlyoverMap(
                isStarted: isStarted,
                sequence: .init(points: points),
                mapType: mapType
            )
            .ignoresSafeArea()
            self.statusBarOverlay
        }
    }
}

// MARK: - StatusBar Overlay

private extension MultiPointDemoView {

    /// A statusbar overlay View
    var statusBarOverlay: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.clear)
                .background(.regularMaterial)
                .frame(height: geometry.safeAreaInsets.top)
                .ignoresSafeArea()
        }
    }

}
