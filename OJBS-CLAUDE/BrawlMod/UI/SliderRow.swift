import UIKit

final class SliderRow: UIView {
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let slider = UISlider()
    private let onChange: (Float) -> Void

    init(icon: String, title: String, range: ClosedRange<Float>, initial: Float, onChange: @escaping (Float) -> Void) {
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

        valueLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        valueLabel.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        valueLabel.textAlignment = .right

        slider.minimumValue = range.lowerBound
        slider.maximumValue = range.upperBound
        slider.value = initial
        slider.minimumTrackTintColor = .systemGreen
        slider.addTarget(self, action: #selector(changed), for: .valueChanged)

        [iconView, titleLabel, valueLabel, slider].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 56),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            valueLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            slider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])
        updateLabel()
    }

    required init?(coder: NSCoder) { fatalError() }

    @objc private func changed() {
        updateLabel()
        onChange(slider.value)
    }

    private func updateLabel() {
        valueLabel.text = String(format: "%.0f", slider.value)
    }
}
