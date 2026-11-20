import UIKit

final class ToggleRow: UIView {
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let toggle = UISwitch()
    private let onChange: (Bool) -> Void

    init(icon: String, title: String, initial: Bool, onChange: @escaping (Bool) -> Void) {
        self.onChange = onChange
        super.init(frame: .zero)
        backgroundColor = UIColor.white.withAlphaComponent(0.04)
        layer.cornerRadius = 10

        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit

        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)

        toggle.isOn = initial
        toggle.onTintColor = .systemGreen
        toggle.addTarget(self, action: #selector(flip), for: .valueChanged)

        [iconView, titleLabel, toggle].forEach {
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
            toggle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            toggle.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        toggle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }

    required init?(coder: NSCoder) { fatalError() }

    @objc private func flip() {
        HapticFeedback.light()
        onChange(toggle.isOn)
    }
}
