import UIKit

final class ESPRenderer {
    static let shared = ESPRenderer()
    private weak var layer: CAShapeLayer?
    private var labelViews: [UILabel] = []
    private var healthLayers: [CAShapeLayer] = []

    private init() {}

    func bind(layer: CAShapeLayer) { self.layer = layer }

    func render() {
        guard let layer = layer, let host = layer.superlayer?.delegate as? UIView else { return }
        let state = OverlayWindowManager.shared.state
        let path = UIBezierPath()
        resetLabels()
        resetHealthBars()

        let enemies = EntityTracker.shared.enemies
        let player = EntityTracker.shared.localPlayer?.position ?? host.center
        let maxR = CGFloat(state.espRange)

        for e in enemies {
            let d = hypot(e.position.x - player.x, e.position.y - player.y)
            if d > maxR { continue }
            let rect = CGRect(x: e.position.x - e.size.width / 2,
                              y: e.position.y - e.size.height / 2,
                              width: e.size.width,
                              height: e.size.height)
            if state.espBox {
                path.append(UIBezierPath(rect: rect))
            }
            if state.espName {
                let lbl = dequeueLabel()
                lbl.text = e.name
                lbl.textColor = e.teamColor
                lbl.sizeToFit()
                lbl.center = CGPoint(x: rect.midX, y: rect.minY - 10)
                host.addSubview(lbl)
            }
            if state.espHealth {
                drawHealth(at: rect, pct: CGFloat(max(0, min(1, e.hp / max(1, e.maxHP)))), in: host)
            }
        }
        layer.path = path.cgPath
    }

    func clear() {
        layer?.path = nil
        resetLabels()
        resetHealthBars()
    }

    private func dequeueLabel() -> UILabel {
        let l = UILabel()
        l.font = .systemFont(ofSize: 10, weight: .bold)
        l.textAlignment = .center
        labelViews.append(l)
        return l
    }

    private func resetLabels() {
        labelViews.forEach { $0.removeFromSuperview() }
        labelViews.removeAll()
    }

    private func drawHealth(at rect: CGRect, pct: CGFloat, in host: UIView) {
        let barH: CGFloat = 3
        let back = CAShapeLayer()
        back.frame = CGRect(x: rect.minX, y: rect.maxY + 2, width: rect.width, height: barH)
        back.backgroundColor = UIColor.black.withAlphaComponent(0.6).cgColor
        back.cornerRadius = 1.5
        let fill = CAShapeLayer()
        fill.frame = CGRect(x: 0, y: 0, width: rect.width * pct, height: barH)
        fill.cornerRadius = 1.5
        fill.backgroundColor = pct > 0.5
            ? UIColor.systemGreen.cgColor
            : (pct > 0.25 ? UIColor.systemYellow.cgColor : UIColor.systemRed.cgColor)
        back.addSublayer(fill)
        host.layer.addSublayer(back)
        healthLayers.append(back)
    }

    private func resetHealthBars() {
        healthLayers.forEach { $0.removeFromSuperlayer() }
        healthLayers.removeAll()
    }
}
