import UIKit

final class SegmentRow: UIView {
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let segmented: UISegmentedControl
    private let onChange: (Int) -> Void

    init(icon: String, title: String, options: [String], initial: Int, onChange: @escaping (Int) -> Void) {
        self.onChange = onChange
        segmented = UISegmentedControl(items: options)
        super.init(frame: .zero)
        backgroundColor = UIColor.white.withAlphaComponent(0.04)
        layer.cornerRadius = 10

        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit

        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)

        segmented.selectedSegmentIndex = initial
        segmented.selectedSegmentTintColor = .systemGreen
        segmented.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segmented.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        segmented.addTarget(self, action: #selector(changed), for: .valueChanged)

        [iconView, titleLabel, segmented].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 72),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            segmented.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            segmented.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            segmented.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            segmented.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    @objc private func changed() {
        HapticFeedback.light()
        onChange(segmented.selectedSegmentIndex)
    }
}
