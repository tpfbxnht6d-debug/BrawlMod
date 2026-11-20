import UIKit

final class SkeletonESPRenderer {
    static let shared = SkeletonESPRenderer()
    private weak var layer: CAShapeLayer?

    private init() {}

    func bind(layer: CAShapeLayer) { self.layer = layer }

    func render() {
        guard let layer = layer else { return }
        let state = OverlayWindowManager.shared.state
        let path = UIBezierPath()

        for e in EntityTracker.shared.enemies {
            let joints = jointsFor(entity: e)
            for pair in boneConnections {
                guard pair.0 < joints.count, pair.1 < joints.count else { continue }
                path.move(to: joints[pair.0])
                path.addLine(to: joints[pair.1])
            }
            for j in joints {
                let dot = UIBezierPath(ovalIn: CGRect(x: j.x - 1.5, y: j.y - 1.5, width: 3, height: 3))
                path.append(dot)
            }
        }
        layer.path = path.cgPath
        layer.opacity = state.skeletonOpacity / 100.0
    }

    func clear() { layer?.path = nil }

    private let boneConnections: [(Int, Int)] = [
        (0, 1), (1, 2), (2, 3), (1, 4), (4, 5), (5, 6),
        (1, 7), (7, 8), (8, 9), (7, 10), (10, 11), (11, 12)
    ]

    private func jointsFor(entity e: Entity) -> [CGPoint] {
        let c = e.position
        let w = e.size.width
        let h = e.size.height
        return [
            CGPoint(x: c.x, y: c.y - h * 0.45),
            CGPoint(x: c.x, y: c.y - h * 0.2),
            CGPoint(x: c.x - w * 0.25, y: c.y - h * 0.1),
            CGPoint(x: c.x - w * 0.35, y: c.y + h * 0.1),
            CGPoint(x: c.x + w * 0.25, y: c.y - h * 0.1),
            CGPoint(x: c.x + w * 0.35, y: c.y + h * 0.1),
            CGPoint(x: c.x, y: c.y + h * 0.1),
            CGPoint(x: c.x - w * 0.15, y: c.y + h * 0.25),
            CGPoint(x: c.x - w * 0.2, y: c.y + h * 0.45),
            CGPoint(x: c.x - w * 0.2, y: c.y + h * 0.5),
            CGPoint(x: c.x + w * 0.15, y: c.y + h * 0.25),
            CGPoint(x: c.x + w * 0.2, y: c.y + h * 0.45),
            CGPoint(x: c.x + w * 0.2, y: c.y + h * 0.5)
        ]
    }
}
