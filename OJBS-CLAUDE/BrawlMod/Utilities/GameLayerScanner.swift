import UIKit

final class GameLayerScanner {
    static let shared = GameLayerScanner()

    private let enemyNamePatterns = [
        "enemy", "opponent", "brawler_red", "team_red", "hostile"
    ]
    private let playerNamePatterns = [
        "player_self", "localplayer", "own_brawler", "team_blue_self"
    ]
    private let projectilePatterns = [
        "projectile", "bullet", "shot_enemy", "shell"
    ]

    func scanHostWindow() -> SceneSnapshot {
        var snap = SceneSnapshot()
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene }).first else { return snap }
        for w in scene.windows where !(w is PassthroughWindow) {
            walk(view: w, into: &snap, parentOrigin: .zero)
        }
        return snap
    }

    private func walk(view: UIView, into snap: inout SceneSnapshot, parentOrigin: CGPoint) {
        let frame = view.convert(view.bounds, to: nil)
        inspectLayer(view.layer, frame: frame, name: view.accessibilityIdentifier ?? view.layer.name, into: &snap)
        for sub in view.subviews {
            walk(view: sub, into: &snap, parentOrigin: frame.origin)
        }
        if let host = view.layer.sublayers {
            for sl in host where sl !== view.layer {
                let r = view.layer.convert(sl.frame, to: nil)
                inspectLayer(sl, frame: r, name: sl.name, into: &snap)
            }
        }
    }

    private func inspectLayer(_ layer: CALayer, frame: CGRect, name: String?, into snap: inout SceneSnapshot) {
        guard let n = name?.lowercased() else { return }
        if playerNamePatterns.contains(where: n.contains) {
            snap.playerFrame = frame
            snap.playerLayer = layer
        } else if enemyNamePatterns.contains(where: n.contains) {
            snap.enemies.append(RawEntity(layer: layer, frame: frame, name: extractBrawlerName(from: n)))
        } else if projectilePatterns.contains(where: n.contains) {
            snap.projectiles.append(RawProjectile(frame: frame, name: n))
        }
    }

    private func extractBrawlerName(from n: String) -> String {
        for b in ["shelly", "colt", "bull", "jessie", "nita", "dynamike",
                  "elprimo", "mortis", "spike", "crow", "leon", "sandy",
                  "amber", "edgar", "byron", "belle", "buzz", "griff"] {
            if n.contains(b) { return b.capitalized }
        }
        return "Enemy"
    }
}

struct SceneSnapshot {
    var playerFrame: CGRect?
    var playerLayer: CALayer?
    var enemies: [RawEntity] = []
    var projectiles: [RawProjectile] = []
}

struct RawEntity {
    let layer: CALayer
    let frame: CGRect
    let name: String
}

struct RawProjectile {
    let frame: CGRect
    let name: String
}
