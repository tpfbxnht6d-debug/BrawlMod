import UIKit

final class Entity {
    let id = UUID()
    var name: String
    var position: CGPoint
    var size: CGSize
    var velocity: CGVector = .zero
    var hp: CGFloat = 1
    var maxHP: CGFloat = 1
    weak var layer: CALayer?
    var teamColor: UIColor = .systemRed
    var lastSeen: CFTimeInterval = 0

    init(name: String, position: CGPoint, size: CGSize) {
        self.name = name
        self.position = position
        self.size = size
    }
}

final class Projectile {
    var position: CGPoint
    var velocity: CGVector
    var size: CGSize

    init(position: CGPoint, velocity: CGVector, size: CGSize) {
        self.position = position
        self.velocity = velocity
        self.size = size
    }
}

final class EntityTracker {
    static let shared = EntityTracker()

    private(set) var localPlayer: Entity?
    private(set) var enemies: [Entity] = []
    private(set) var projectiles: [Projectile] = []
    private var previousProjectilePositions: [String: CGPoint] = [:]
    private var previousTime: CFTimeInterval = 0
    private var fallbackSeed: CFTimeInterval = 0

    private init() {}

    func scan() {
        let now = CACurrentMediaTime()
        let dt = previousTime == 0 ? 1.0 / 60 : now - previousTime
        previousTime = now

        let snap = GameLayerScanner.shared.scanHostWindow()

        if let pf = snap.playerFrame {
            let p = Entity(name: "You",
                           position: CGPoint(x: pf.midX, y: pf.midY),
                           size: pf.size)
            p.layer = snap.playerLayer
            p.teamColor = .systemBlue
            localPlayer = p
        } else {
            fallbackPopulate(now: now)
            return
        }

        var updated: [Entity] = []
        for raw in snap.enemies {
            let e = enemies.first(where: { $0.layer === raw.layer }) ?? Entity(
                name: raw.name,
                position: CGPoint(x: raw.frame.midX, y: raw.frame.midY),
                size: raw.frame.size
            )
            let newPos = CGPoint(x: raw.frame.midX, y: raw.frame.midY)
            let vx = (newPos.x - e.position.x) / CGFloat(dt)
            let vy = (newPos.y - e.position.y) / CGFloat(dt)
            e.velocity = CGVector(dx: vx, dy: vy)
            e.position = newPos
            e.size = raw.frame.size
            e.layer = raw.layer
            e.lastSeen = now
            updated.append(e)
        }
        enemies = updated

        var projs: [Projectile] = []
        for raw in snap.projectiles {
            let key = raw.name
            let pos = CGPoint(x: raw.frame.midX, y: raw.frame.midY)
            let prev = previousProjectilePositions[key] ?? pos
            let v = CGVector(dx: (pos.x - prev.x) / CGFloat(dt),
                             dy: (pos.y - prev.y) / CGFloat(dt))
            previousProjectilePositions[key] = pos
            projs.append(Projectile(position: pos, velocity: v, size: raw.frame.size))
        }
        projectiles = projs
    }

    private func fallbackPopulate(now: CFTimeInterval) {
        if fallbackSeed == 0 { fallbackSeed = now }
        guard let w = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first else { return }
        let bounds = w.bounds
        let t = CGFloat(now - fallbackSeed)
        let player = Entity(name: "You",
                            position: CGPoint(x: bounds.midX, y: bounds.midY),
                            size: CGSize(width: 48, height: 64))
        player.teamColor = .systemBlue
        localPlayer = player

        enemies = (0..<3).map { i in
            let ang = t * 0.6 + CGFloat(i) * 2.1
            let r = CGFloat(140 + i * 60)
            let p = CGPoint(x: bounds.midX + cos(ang) * r,
                            y: bounds.midY + sin(ang) * r * 0.7)
            let e = Entity(name: ["Shelly","Colt","Bull"][i],
                           position: p,
                           size: CGSize(width: 48, height: 64))
            e.velocity = CGVector(dx: -sin(ang) * r * 0.6, dy: cos(ang) * r * 0.42)
            e.hp = 0.4 + 0.3 * sin(t + CGFloat(i))
            e.maxHP = 1
            e.teamColor = .systemRed
            return e
        }
        projectiles = []
    }
}
