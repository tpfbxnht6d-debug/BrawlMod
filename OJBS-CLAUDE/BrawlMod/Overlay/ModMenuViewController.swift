import UIKit

final class ModMenuViewController: UIViewController {
    private let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let scroll = UIScrollView()
    private let stack = UIStackView()
    private let state = OverlayWindowManager.shared.state

    override func loadView() {
        view = PassthroughContainerSolid()
        view.backgroundColor = .clear
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        blur.layer.cornerRadius = 18
        blur.layer.masksToBounds = true
        blur.layer.borderWidth = 1
        blur.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        blur.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blur)
        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: view.topAnchor),
            blur.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blur.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let header = buildHeader()
        header.translatesAutoresizingMaskIntoConstraints = false
        blur.contentView.addSubview(header)

        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        blur.contentView.addSubview(scroll)

        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: blur.contentView.topAnchor),
            header.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 54),

            scroll.topAnchor.constraint(equalTo: header.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: blur.contentView.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -16),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -28)
        ])

        buildSections()
    }

    private func buildHeader() -> UIView {
        let v = UIView()
        let title = UILabel()
        title.text = "BrawlMod"
        title.textColor = .white
        title.font = .systemFont(ofSize: 20, weight: .bold)
        let tag = UILabel()
        tag.text = "v1.0"
        tag.textColor = UIColor.white.withAlphaComponent(0.55)
        tag.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        let divider = UIView()
        divider.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        [title, tag, divider].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            v.addSubview($0)
        }
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 16),
            title.centerYAnchor.constraint(equalTo: v.centerYAnchor, constant: -2),
            tag.leadingAnchor.constraint(equalTo: title.trailingAnchor, constant: 8),
            tag.firstBaselineAnchor.constraint(equalTo: title.firstBaselineAnchor),
            divider.leadingAnchor.constraint(equalTo: v.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: v.trailingAnchor),
            divider.bottomAnchor.constraint(equalTo: v.bottomAnchor),
            divider.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        return v
    }

    private func buildSections() {
        addSection("Aim")
        stack.addArrangedSubview(ToggleRow(icon: "scope", title: "Aimbot", initial: state.aimbot) { [weak self] in
            self?.state.aimbot = $0
            AimbotManager.shared.setEnabled($0)
        })
        stack.addArrangedSubview(SliderRow(icon: "slider.horizontal.3", title: "Strength",
                                           range: 1...100, initial: state.aimbotStrength) { [weak self] in
            self?.state.aimbotStrength = $0
            AimbotManager.shared.strength = $0
        })
        stack.addArrangedSubview(SegmentRow(icon: "target", title: "Target",
                                            options: ["Closest", "Low HP", "Auto"],
                                            initial: state.aimbotTargetMode) { [weak self] in
            self?.state.aimbotTargetMode = $0
            AimbotManager.shared.targetMode = AimbotManager.TargetMode(rawValue: $0) ?? .auto
        })

        addSection("Visual")
        stack.addArrangedSubview(ToggleRow(icon: "sparkles", title: "Glow Skin", initial: state.glow) { [weak self] in
            self?.state.glow = $0
        })
        stack.addArrangedSubview(ColorPickerRow(icon: "paintpalette", title: "Glow Color",
                                                initial: state.glowColor) { [weak self] in
            self?.state.glowColor = $0
        })
        stack.addArrangedSubview(SliderRow(icon: "flame", title: "Intensity",
                                           range: 1...10, initial: state.glowIntensity) { [weak self] in
            self?.state.glowIntensity = $0
        })

        addSection("ESP")
        stack.addArrangedSubview(ToggleRow(icon: "eye", title: "ESP", initial: state.esp) { [weak self] in
            self?.state.esp = $0
        })
        stack.addArrangedSubview(ToggleRow(icon: "square.dashed", title: "Box", initial: state.espBox) { [weak self] in
            self?.state.espBox = $0
        })
        stack.addArrangedSubview(ToggleRow(icon: "character.textbox", title: "Name", initial: state.espName) { [weak self] in
            self?.state.espName = $0
        })
        stack.addArrangedSubview(ToggleRow(icon: "heart.text.square", title: "Health Bar", initial: state.espHealth) { [weak self] in
            self?.state.espHealth = $0
        })
        stack.addArrangedSubview(SliderRow(icon: "ruler", title: "Range",
                                           range: 100...2000, initial: state.espRange) { [weak self] in
            self?.state.espRange = $0
        })

        addSection("Skeleton")
        stack.addArrangedSubview(ToggleRow(icon: "figure.walk", title: "Skeleton ESP", initial: state.skeleton) { [weak self] in
            self?.state.skeleton = $0
        })
        stack.addArrangedSubview(SliderRow(icon: "circle.lefthalf.filled", title: "Opacity",
                                           range: 0...100, initial: state.skeletonOpacity) { [weak self] in
            self?.state.skeletonOpacity = $0
        })

        addSection("Combat")
        stack.addArrangedSubview(ToggleRow(icon: "bolt.shield", title: "Auto Dodge", initial: state.autoDodge) { [weak self] in
            self?.state.autoDodge = $0
            AutoDodgeManager.shared.setEnabled($0)
        })
        stack.addArrangedSubview(SliderRow(icon: "stopwatch", title: "Reaction (ms)",
                                           range: 50...200, initial: state.dodgeReaction) { [weak self] in
            self?.state.dodgeReaction = $0
            AutoDodgeManager.shared.reactionMs = $0
        })
        stack.addArrangedSubview(ToggleRow(icon: "scope", title: "Auto Shoot", initial: state.autoShoot) { [weak self] in
            self?.state.autoShoot = $0
            AutoShootManager.shared.setEnabled($0)
        })
        stack.addArrangedSubview(SliderRow(icon: "circle.hexagongrid", title: "FOV",
                                           range: 10...90, initial: state.autoShootFOV) { [weak self] in
            self?.state.autoShootFOV = $0
            AutoShootManager.shared.fov = $0
        })

        addSection("Skin Changer")
        let picker = SkinChangerView(onPick: { [weak self] name in
            self?.state.selectedSkin = name
            SkinChanger.shared.apply(name: name)
            HapticFeedback.success()
        })
        stack.addArrangedSubview(picker)

        addSection("HUD")
        stack.addArrangedSubview(ToggleRow(icon: "speedometer", title: "FPS Counter", initial: state.fpsVisible) { [weak self] in
            self?.state.fpsVisible = $0
            FPSOverlayView.setGlobalVisible($0)
        })
    }

    private func addSection(_ title: String) {
        let lbl = UILabel()
        lbl.text = title.uppercased()
        lbl.textColor = UIColor.white.withAlphaComponent(0.5)
        lbl.font = .systemFont(ofSize: 11, weight: .bold)
        let wrap = UIView()
        wrap.addSubview(lbl)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lbl.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 4),
            lbl.topAnchor.constraint(equalTo: wrap.topAnchor, constant: 10),
            lbl.bottomAnchor.constraint(equalTo: wrap.bottomAnchor, constant: -4),
            lbl.trailingAnchor.constraint(equalTo: wrap.trailingAnchor)
        ])
        stack.addArrangedSubview(wrap)
    }

    func presentAnimated() {
        view.alpha = 0
        view.transform = CGAffineTransform(translationX: 0, y: 40)
        UIView.animate(withDuration: 0.35, delay: 0,
                       usingSpringWithDamping: 0.85, initialSpringVelocity: 0.4,
                       options: [.curveEaseOut], animations: {
            self.view.alpha = 1
            self.view.transform = .identity
        })
    }

    func dismissAnimated(_ done: @escaping () -> Void) {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 0
            self.view.transform = CGAffineTransform(translationX: 0, y: 40)
        }, completion: { _ in done() })
    }
}

final class PassthroughContainerSolid: UIView {}
