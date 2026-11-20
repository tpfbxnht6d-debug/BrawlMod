import UIKit

final class GlowSkinManager {
    static let shared = GlowSkinManager()
    private var tagged: NSHashTable<CALayer> = NSHashTable.weakObjects()

    private init() {}

    func apply() {
        let state = OverlayWindowManager.shared.state
        let color = state.glowColor
        let radius = CGFloat(4 + (state.glowIntensity - 1) * (36.0 / 9.0))

        for e in EntityTracker.shared.enemies {
            guard let layer = e.layer else { continue }
            layer.shadowColor = color.cgColor
            layer.shadowOpacity = 1
            layer.shadowRadius = radius
            layer.shadowOffset = .zero
            layer.masksToBounds = false
            tagged.add(layer)
        }
    }

    func clear() {
        for layer in tagged.allObjects {
            layer.shadowOpacity = 0
            layer.shadowRadius = 0
        }
        tagged.removeAllObjects()
    }
}
