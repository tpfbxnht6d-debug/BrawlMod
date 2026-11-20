import UIKit

final class AimbotManager {
    static let shared = AimbotManager()

    enum TargetMode: Int { case closest = 0, lowHP = 1, auto = 2 }

    var strength: Float = 50
    var targetMode: TargetMode = .auto
    private(set) var enabled = false
    private var lastTargetId: UUID?

    private init() {}

    func setEnabled(_ v: Bool) {
        enabled = v
        if !v { lastTargetId = nil }
    }

    func update() {
        guard enabled else { return }
        let player = EntityTracker.shared.localPlayer
        let enemies = EntityTracker.shared.enemies
        guard let p = player, !enemies.isEmpty else { return }
        guard let target = pickTarget(enemies: enemies, from: p.position) else { return }
        lastTargetId = target.id
        applyAim(from: p, to: target)
    }

    private func pickTarget(enemies: [Entity], from origin: CGPoint) -> Entity? {
        switch targetMode {
        case .closest:
            return enemies.min(by: { d2($0.position, origin) < d2($1.position, origin) })
        case .lowHP:
            return enemies.min(by: { $0.hp < $1.hp })
        case .auto:
            return enemies.min(by: {
                let s0 = Double(d2($0.position, origin)) + Double($0.hp) * 1000
                let s1 = Double(d2($1.position, origin)) + Double($1.hp) * 1000
                return s0 < s1
            })
        }
    }

    private func applyAim(from player: Entity, to target: Entity) {
        let dx = target.position.x - player.position.x
        let dy = target.position.y - player.position.y
        let angle = atan2(dy, dx)
        let amount = CGFloat(strength / 100.0)
        AimSteering.shared.nudge(angle: angle, weight: amount)
    }

    private func d2(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = a.x - b.x, dy = a.y - b.y
        return dx * dx + dy * dy
    }
}

final class AimSteering {
    static let shared = AimSteering()
    private(set) var currentAngle: CGFloat = 0
    private var active = false

    func nudge(angle: CGFloat, weight: CGFloat) {
        if !active {
            currentAngle = angle
            active = true
            return
        }
        let delta = shortestAngleDelta(from: currentAngle, to: angle)
        currentAngle += delta * max(0.05, min(1, weight))
    }

    func reset() { active = false }

    private func shortestAngleDelta(from a: CGFloat, to b: CGFloat) -> CGFloat {
        var d = b - a
        while d > .pi { d -= 2 * .pi }
        while d < -.pi { d += 2 * .pi }
        return d
    }
}
