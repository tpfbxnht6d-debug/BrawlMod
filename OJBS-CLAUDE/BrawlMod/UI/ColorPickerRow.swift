import UIKit

final class ColorPickerRow: UIView {
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let swatch = UIButton(type: .system)
    private let onChange: (UIColor) -> Void
    private var currentColor: UIColor

    init(icon: String, title: String, initial: UIColor, onChange: @escaping (UIColor) -> Void) {
        self.onChange = onChange
        self.currentColor = initial
        super.init(frame: .zero)
        backgroundColor = UIColor.white.withAlphaComponent(0.04)
        layer.cornerRadius = 10

        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit

        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)

        swatch.layer.cornerRadius = 12
        swatch.layer.borderWidth = 1
        swatch.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        swatch.backgroundColor = initial
        swatch.addTarget(self, action: #selector(open), for: .touchUpInside)

        [iconView, titleLabel, swatch].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 40),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            swatch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            swatch.centerYAnchor.constraint(equalTo: centerYAnchor),
            swatch.widthAnchor.constraint(equalToConstant: 24),
            swatch.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    @objc private func open() {
        let colors: [UIColor] = [
            .systemRed, .systemOrange, .systemYellow, .systemGreen,
            .systemTeal, .systemBlue, .systemIndigo, .systemPurple,
            .systemPink, .white, .black
        ]
        let sheet = UIAlertController(title: "Glow Color", message: nil, preferredStyle: .actionSheet)
        for c in colors {
            let a = UIAlertAction(title: colorName(c), style: .default) { [weak self] _ in
                self?.pick(c)
            }
            sheet.addAction(a)
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let pop = sheet.popoverPresentationController {
            pop.sourceView = swatch
            pop.sourceRect = swatch.bounds
        }
        OverlayWindowManager.shared.ensureVisible()
        topMostVC()?.present(sheet, animated: true)
    }

    private func pick(_ c: UIColor) {
        currentColor = c
        swatch.backgroundColor = c
        onChange(c)
    }

    private func colorName(_ c: UIColor) -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        c.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r*255), Int(g*255), Int(b*255))
    }

    private func topMostVC() -> UIViewController? {
        var vc = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
            .first
        while let p = vc?.presentedViewController { vc = p }
        return vc
    }
}
