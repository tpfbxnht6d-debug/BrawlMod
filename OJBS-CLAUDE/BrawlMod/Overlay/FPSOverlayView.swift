import UIKit

final class FPSMeter {
    static let shared = FPSMeter()
    private(set) var fps: Double = 0
    private var samples: [Double] = []
    private let maxSamples = 30
    private init() {}

    func record(dt: CFTimeInterval) {
        guard dt > 0 else { return }
        let hz = 1.0 / dt
        samples.append(hz)
        if samples.count > maxSamples { samples.removeFirst(samples.count - maxSamples) }
        fps = samples.reduce(0, +) / Double(samples.count)
    }
}

final class FPSOverlayView: UIView {
    static weak var current: FPSOverlayView?
    private let label = UILabel()
    private var lastUpdate: CFTimeInterval = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        FPSOverlayView.current = self
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        layer.cornerRadius = 10
        label.textColor = .white
        label.font = .monospacedSystemFont(ofSize: 11, weight: .semibold)
        label.textAlignment = .center
        label.text = "-- fps"
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func update() {
        let now = CACurrentMediaTime()
        if now - lastUpdate < 0.5 { return }
        lastUpdate = now
        label.text = String(format: "%.0f fps", FPSMeter.shared.fps)
    }

    static func setGlobalVisible(_ v: Bool) {
        current?.isHidden = !v
    }
}
