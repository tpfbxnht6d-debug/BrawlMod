import UIKit

final class AutoShootManager {
    static let shared = AutoShootManager()

    var fov: Float = 45
    private(set) var enabled = false
    private var lastShot: CFTimeInterval = 0
    private let attackCooldown: CFTimeInterval = 0.35

    private init() {}

    func setEnabled(_ v: Bool) { enabled = v }

    func update() {
        guard enabled else { return }
        guard let player = EntityTracker.shared.localPlayer else { return }
        let now = CACurrentMediaTime()
        if now - lastShot < attackCooldown { return }

        let fovRad = CGFloat(fov) * .pi / 180.0
        let aim = AimSteering.shared.currentAngle
        let enemies = EntityTracker.shared.enemies

        for e in enemies {
            let dx = e.position.x - player.position.x
            let dy = e.position.y - player.position.y
            let ang = atan2(dy, dx)
            var delta = ang - aim
            while delta > .pi { delta -= 2 * .pi }
            while delta < -.pi { delta += 2 * .pi }
            if abs(delta) > fovRad / 2 { continue }

            let evx = e.velocity.x
            let evy = e.velocity.y
            if hypot(evx, evy) > 0.01 {
                let towardX = -dx
                let towardY = -dy
                let dot = evx * towardX + evy * towardY
                if dot <= 0 { continue }
            }
            fire(from: player.position, toward: e.position)
            lastShot = now
            return
        }
    }

    private func fire(from a: CGPoint, toward b: CGPoint) {
        let dx = b.x - a.x
        let dy = b.y - a.y
        let len = max(1, hypot(dx, dy))
        let dir = CGVector(dx: dx / len, dy: dy / len)
        TouchSynth.shared.swipe(from: a, direction: dir, length: 90, in: 0.1)
    }
}
