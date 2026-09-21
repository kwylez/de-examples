import SwiftUI
import UIKit
import Playgrounds

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        SOSAnimationView()
            .padding()
    }
}

/// Shows the SOS drawing animation with a button to replay it from the start.
struct SOSAnimationView: View {
    @State private var runID = 0

    var body: some View {
        VStack(spacing: 48) {
            SOSDrawSequence()
                .id(runID)
            Button("Replay", systemImage: "arrow.clockwise") {
                runID += 1
            }
            .buttonStyle(.bordered)
        }
    }
}

/// Writes each letter of "SOS" one at a time, tracing a single continuous
/// handwritten stroke per letter. Letters are sized from the `largeTitle`
/// text style so they scale with Dynamic Type.
struct SOSDrawSequence: View {
    @State private var isDrawn = false

    var body: some View {
        HStack(spacing: 12) {
            SOSLetterView(letter: .s, drawDelay: 0.0, isDrawn: isDrawn)
            SOSLetterView(letter: .o, drawDelay: 0.9, isDrawn: isDrawn)
            SOSLetterView(letter: .s, drawDelay: 1.8, isDrawn: isDrawn)
        }
        .onAppear { isDrawn = true }
    }
}

struct SOSLetterView: View {
    let letter: SOSLetterShape
    let drawDelay: Double
    let isDrawn: Bool

    var body: some View {
        letter
            .trim(from: 0, to: isDrawn ? 1 : 0)
            .stroke(.red, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round, lineJoin: .round))
            .frame(width: letterSize.width, height: letterSize.height)
            .animation(.easeInOut(duration: 0.8).delay(drawDelay), value: isDrawn)
    }

    /// Letter height matches the cap height of the `largeTitle` text style.
    private var capHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .largeTitle).capHeight
    }

    private var letterSize: CGSize {
        let widthRatio: CGFloat = letter == .o ? 0.95 : 0.78
        return CGSize(width: capHeight * widthRatio, height: capHeight)
    }

    private var strokeWidth: CGFloat {
        capHeight * 0.16
    }
}

/// A single-stroke, handwriting-style letterform. Each case is one
/// continuous centerline path, so trimming it draws the whole letter
/// in a single stroke — start to finish — like writing by hand.
enum SOSLetterShape: Shape {
    case s
    case o

    func path(in rect: CGRect) -> Path {
        switch self {
        case .s: sPath(in: rect)
        case .o: oPath(in: rect)
        }
    }

    /// Starts at the top-right, sweeps over the top bowl, crosses the
    /// center, and finishes around the bottom bowl at the lower-left.
    private func sPath(in rect: CGRect) -> Path {
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * rect.width, y: rect.minY + y * rect.height)
        }
        var path = Path()
        path.move(to: point(0.80, 0.18))
        path.addCurve(to: point(0.50, 0.50),
                      control1: point(0.62, -0.10),
                      control2: point(0.06, 0.24))
        path.addCurve(to: point(0.20, 0.82),
                      control1: point(0.94, 0.76),
                      control2: point(0.38, 1.10))
        return path
    }

    /// One full circular sweep starting from the top, the way an "O" is
    /// usually written by hand.
    private func oPath(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: min(rect.width, rect.height) / 2 * 0.9,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(270),
                    clockwise: true)
        return path
    }
}

#Preview {
    ContentView()
}

#Playground {
    _ = 1 + 2
}
