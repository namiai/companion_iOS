// Copyright (c) nami.ai

import SwiftUI

// MARK: - PongView

public struct PongView: View {
    public var body: some View {
        ZStack {
            GeometryReader { geo in
                // ball
                Circle()
                    .foregroundColor(Color(hex: 0xFF5958))
                    .frame(width: Self.ballRadius * 2, height: Self.ballRadius * 2, alignment: .center)
                    // if animation finishes too early there is visible glitch when the ball stops for a second and continues later
                    // adding 10 ms to the animation duration smoothes it out
                    .animation(.linear(duration: Double(Self.tickSpeed + 0.01)))
                    .position(CGPoint(x: ballCoords.x * geo.size.width, y: ballCoords.y * geo.size.height))
                    .onReceive(timer) { _ in
                        updateBallCoords(geo: geo)
                    }
                // stick
                RoundedRectangle(cornerRadius: 3.0)
                    .frame(width: Self.stickWidth, height: 10, alignment: .center)
                    .position(CGPoint(x: stickCoords.x * geo.size.width, y: stickCoords.y * geo.size.height))
                    .gesture(DragGesture().onChanged { value in
                        if lastGameReset.timeIntervalSinceNow < -Self.controlStickInitialDelay {
                            stickCoords.x = clampStickXToAreaBounds(value: value.location.x / geo.size.width, geo: geo)
                            userRequestedGameControl = true
                        }
                    })
                    .animation(.linear(duration: Double(Self.tickSpeed + 0.01)))
                    .onReceive(timer) { _ in
                        if !userRequestedGameControl {
                            updateStickCoords(geo: geo)
                        }
                    }
            }
        }
        .padding(EdgeInsets(top: 0, leading: 16, bottom: 32, trailing: 16))
    }

    @State private var ballCoords: CGPoint = Self.startBallCoords
    @State private var stickCoords: CGPoint = Self.startStickCoords
    @State private var velocity: CGPoint = Self.startVelocity
    @State private var userRequestedGameControl: Bool = false
    @State private var lastGameReset = Date()
    let timer = Timer.publish(every: TimeInterval(Self.tickSpeed), on: .main, in: .common).autoconnect()

    private static let startBallCoords = CGPoint(x: 0.0, y: 0.3)
    private static let startStickCoords = CGPoint(x: 0.0, y: 1.0)
    private static let startVelocity = CGPoint(x: 0.006, y: 0.012)

    private static let ballRadius: CGFloat = 8.0
    private static let tickSpeed: CGFloat = 1 / 60
    private static let stickWidth: CGFloat = 90.0
    private static let controlStickInitialDelay = 2.0

    func updateBallCoords(geo: GeometryProxy) {
        // try to update values by adding velocity to the current coords
        var newX = ballCoords.x + velocity.x
        var newY = ballCoords.y + velocity.y

        // check if we're touching the bottom and the ball is within the stick bounds
        if newY >= 1 {
            let ballIsOutLeft = ballCoords.x < (stickCoords.x - Self.stickWidth / geo.size.width / 2)
            let ballIsOutRight = ballCoords.x > (stickCoords.x + Self.stickWidth / geo.size.width / 2)
            if ballIsOutLeft || ballIsOutRight {
                // if it's not -> restart the game
                resetGame(geo: geo)
                return
            }
        }

        // if we are touching the walls -> just reflect the ball
        if newX >= 1 || newX <= 0 {
            velocity.x = -velocity.x
        }
        if newY >= 1 || newY <= 0 {
            velocity.y = -velocity.y
        }
        // when ball is touching the bottom, speed (both horizontal and vertical) should be
        // changed according to the position of the stick:
        // if the ball touched the stick right in the middle -> do the perfect reflection
        // otherwise -> calculate the addition by figuring out the position of the ball touchdown
        if newY >= 1 {
            let notInTheMiddleAddition = (ballCoords.x - stickCoords.x) / 3
            velocity.x += notInTheMiddleAddition
            velocity.x = abs(velocity.x).clamp(0.003, 0.01) * (velocity.x > 0 ? 1 : -1)
        }
        // clamp the values of the ball position, we don't want it getting
        // out of the borders
        newY = newY.clamp(0, 1)
        newX = newX.clamp(0, 1)

        ballCoords = CGPoint(x: newX, y: newY)
    }

    private func updateStickCoords(geo: GeometryProxy) {
        // in auto mode stick follows the ball, but it's width is larger than the ball's
        // so if we just copy the x value -> we will overflow the screen border
        // let's limit it a tiny bit
        stickCoords = CGPoint(x: clampStickXToAreaBounds(value: ballCoords.x, geo: geo), y: 1.0 + Self.ballRadius / geo.size.height)
    }

    private func clampStickXToAreaBounds(value: CGFloat, geo: GeometryProxy) -> CGFloat {
        value.clamp(Self.stickWidth / geo.size.width / 2.0, (geo.size.width - Self.stickWidth / 2) / geo.size.width)
    }

    private func resetGame(geo: GeometryProxy) {
        ballCoords = Self.startBallCoords
        updateStickCoords(geo: geo)
        velocity = Self.startVelocity
        userRequestedGameControl = false
        lastGameReset = Date()
    }
}

extension Comparable {
    func clamp(_ floor: Self, _ ceil: Self) -> Self {
        min(max(self, floor), ceil)
    }
}

// MARK: - PongView_Previews

struct PongView_Previews: PreviewProvider {
    static var previews: some View {
        PongView()
    }
}
