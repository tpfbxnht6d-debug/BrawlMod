import UIKit

final class FloatingButton: UIControl {
    var onTap: (() -> Void)?
    private let label = UILabel()
    private var drag: CGPoint = .zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        layer.cornerRadius = 22
        layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        layer.borderWidth = 1
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 2)

        label.text = "Open"
        label.textColor = .white
        if let rounded = UIFont.systemFont(ofSize: 11, weight: .semibold).fontDescriptor
            .withDesign(.rounded) {
            label.font = UIFont(descriptor: rounded, size: 11)
        } else {
            label.font = .systemFont(ofSize: 11, weight: .semibold)
        }
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        UIView.animate(withDuration: 0.08) { self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92) }
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        UIView.animate(withDuration: 0.12) { self.transform = .identity }
        if let t = touch, bounds.insetBy(dx: -8, dy: -8).contains(t.location(in: self)) {
            onTap?()
        }
    }

    override func cancelTracking(with event: UIEvent?) {
        UIView.animate(withDuration: 0.12) { self.transform = .identity }
    }

    @objc private func handlePan(_ g: UIPanGestureRecognizer) {
        guard let parent = superview else { return }
        let t = g.translation(in: parent)
        switch g.state {
        case .began:
            drag = center
        case .changed:
            center = CGPoint(x: drag.x + t.x, y: drag.y + t.y)
        case .ended, .cancelled:
            let p = parent.safeAreaLayoutGuide.layoutFrame
            var c = center
            c.x = min(max(p.minX + 22, c.x), p.maxX - 22)
            c.y = min(max(p.minY + 22, c.y), p.maxY - 22)
            UIView.animate(withDuration: 0.2) { self.center = c }
        default: break
        }
    }
}
