import UIKit

final class AutoDodgeManager {
    static let shared = AutoDodgeManager()

    var reactionMs: Float = 100
    private(set) var enabled = false
    private var lastDodge: CFTimeInterval = 0

    private init() {}

    func setEnabled(_ v: Bool) { enabled = v }

    func update() {
        guard enabled else { return }
        guard let player = EntityTracker.shared.localPlayer else { return }
        let now = CACurrentMediaTime()
        if now - lastDodge < 0.25 { return }

        let projectiles = EntityTracker.shared.projectiles
        let reactionSec = Double(reactionMs) / 1000.0

        for p in projectiles {
            let dx = player.position.x - p.position.x
            let dy = player.position.y - p.position.y
            let vLen = hypot(p.velocity.x, p.velocity.y)
            if vLen < 0.001 { continue }
            let vx = p.velocity.x / vLen
            let vy = p.velocity.y / vLen
            let t = dx * vx + dy * vy
            if t <= 0 { continue }

            let perpDist = abs(dx * vy - dy * vx)
            let hitbox = max(player.size.width, player.size.height) * 0.5
            if perpDist > hitbox { continue }

            let distToPlayer = hypot(dx, dy)
            let eta = Double(distToPlayer / vLen)
            if eta > reactionSec { continue }

            let perpAngle = atan2(vy, vx) + .pi / 2
            TouchSynth.shared.swipe(
                from: player.position,
                direction: CGVector(dx: cos(perpAngle), dy: sin(perpAngle)),
                length: 120,
                in: 0.12
            )
            lastDodge = now
            HapticFeedback.light()
            return
        }
    }
}

final class TouchSynth {
    static let shared = TouchSynth()

    func swipe(from start: CGPoint, direction: CGVector, length: CGFloat, in duration: CFTimeInterval) {
        let end = CGPoint(x: start.x + direction.dx * length,
                          y: start.y + direction.dy * length)
        animateCursor(from: start, to: end, duration: duration)
    }

    func tap(at p: CGPoint) {
        animateCursor(from: p, to: p, duration: 0.08)
    }

    private func animateCursor(from a: CGPoint, to b: CGPoint, duration: CFTimeInterval) {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first else { return }
        let dot = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
        dot.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        dot.layer.cornerRadius = 9
        dot.center = a
        dot.isUserInteractionEnabled = false
        window.addSubview(dot)
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut], animations: {
            dot.center = b
            dot.alpha = 0
        }, completion: { _ in dot.removeFromSuperview() })
    }
}
