import UIKit

final class OverlayWindowManager {
    static let shared = OverlayWindowManager()

    private var overlayWindow: PassthroughWindow?
    private let root = OverlayRootViewController()
    private var displayLink: CADisplayLink?

    let state = ModState()

    private init() {}

    func install(in scene: UIWindowScene? = nil) {
        guard overlayWindow == nil else { return }
        let w: PassthroughWindow
        if let s = scene {
            w = PassthroughWindow(windowScene: s)
        } else {
            w = PassthroughWindow(frame: UIScreen.main.bounds)
        }
        w.windowLevel = UIWindow.Level.alert + 1
        w.backgroundColor = .clear
        w.isHidden = false
        w.rootViewController = root
        overlayWindow = w
        root.loadViewIfNeeded()
        startFrameLoop()
    }

    func ensureVisible() {
        overlayWindow?.isHidden = false
    }

    func pause() {
        displayLink?.isPaused = true
    }

    func resume() {
        displayLink?.isPaused = false
    }

    private func startFrameLoop() {
        let dl = CADisplayLink(target: self, selector: #selector(tick(_:)))
        if #available(iOS 15.0, *) {
            dl.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 120, preferred: 120)
        } else {
            dl.preferredFramesPerSecond = 60
        }
        dl.add(to: .main, forMode: .common)
        displayLink = dl
    }

    @objc private func tick(_ link: CADisplayLink) {
        let dt = link.targetTimestamp - link.timestamp
        FPSMeter.shared.record(dt: dt)
        EntityTracker.shared.scan()
        if state.esp { ESPRenderer.shared.render() } else { ESPRenderer.shared.clear() }
        if state.skeleton { SkeletonESPRenderer.shared.render() } else { SkeletonESPRenderer.shared.clear() }
        if state.glow { GlowSkinManager.shared.apply() } else { GlowSkinManager.shared.clear() }
        if state.aimbot { AimbotManager.shared.update() }
        if state.autoDodge { AutoDodgeManager.shared.update() }
        if state.autoShoot { AutoShootManager.shared.update() }
        root.overlayContainer.fps.update()
    }
}

final class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hit = super.hitTest(point, with: event) else { return nil }
        return hit is PassthroughContainer ? nil : hit
    }
}

final class PassthroughContainer: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        return hit === self ? nil : hit
    }
}

final class OverlayRootViewController: UIViewController {
    let overlayContainer = OverlayContainerView()

    override func loadView() {
        view = PassthroughContainer()
        view.backgroundColor = .clear
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(overlayContainer)
        overlayContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlayContainer.topAnchor.constraint(equalTo: view.topAnchor),
            overlayContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override var prefersStatusBarHidden: Bool { true }
}

final class OverlayContainerView: PassthroughContainer {
    let button = FloatingButton()
    let fps = FPSOverlayView()
    let espLayer = CAShapeLayer()
    let skeletonLayer = CAShapeLayer()
    private var menu: ModMenuViewController?

    override init(frame: CGRect) {
        super.init(frame: frame)
        espLayer.frame = bounds
        espLayer.fillColor = nil
        espLayer.lineWidth = 1.5
        espLayer.strokeColor = UIColor.systemGreen.cgColor
        layer.addSublayer(espLayer)

        skeletonLayer.frame = bounds
        skeletonLayer.fillColor = nil
        skeletonLayer.lineWidth = 1.2
        skeletonLayer.strokeColor = UIColor.white.withAlphaComponent(0.8).cgColor
        layer.addSublayer(skeletonLayer)

        addSubview(fps)
        fps.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fps.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            fps.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -8)
        ])

        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 12),
            button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -12),
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
        button.onTap = { [weak self] in self?.toggleMenu() }

        ESPRenderer.shared.bind(layer: espLayer)
        SkeletonESPRenderer.shared.bind(layer: skeletonLayer)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        espLayer.frame = bounds
        skeletonLayer.frame = bounds
    }

    private func toggleMenu() {
        HapticFeedback.light()
        if let m = menu {
            m.dismissAnimated { [weak self, weak m] in
                m?.view.removeFromSuperview()
                m?.removeFromParent()
                self?.menu = nil
            }
            return
        }
        let m = ModMenuViewController()
        addSubview(m.view)
        m.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            m.view.centerXAnchor.constraint(equalTo: centerXAnchor),
            m.view.centerYAnchor.constraint(equalTo: centerYAnchor),
            m.view.widthAnchor.constraint(equalToConstant: 320),
            m.view.heightAnchor.constraint(equalToConstant: 520)
        ])
        m.presentAnimated()
        menu = m
    }
}

final class ModState {
    var aimbot = false
    var aimbotStrength: Float = 50
    var aimbotTargetMode: Int = 2
    var glow = false
    var glowColor: UIColor = .systemRed
    var glowIntensity: Float = 5
    var esp = false
    var espBox = true
    var espName = true
    var espHealth = true
    var espRange: Float = 1200
    var skeleton = false
    var skeletonOpacity: Float = 80
    var autoDodge = false
    var dodgeReaction: Float = 100
    var autoShoot = false
    var autoShootFOV: Float = 45
    var fpsVisible = true
    var selectedSkin: String?
}
