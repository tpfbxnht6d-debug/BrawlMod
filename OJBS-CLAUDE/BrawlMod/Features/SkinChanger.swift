import UIKit

struct SkinEntry {
    let brawler: String
    let skin: String
    let thumbnail: String
}

final class SkinChanger {
    static let shared = SkinChanger()
    private(set) var catalog: [SkinEntry] = []
    private var activeAtlas: [String: UIImage] = [:]

    private init() {
        catalog = SkinChanger.defaultCatalog()
    }

    func apply(name: String) {
        guard let entry = catalog.first(where: { "\($0.brawler)/\($0.skin)" == name }) else { return }
        let image = loadThumbnail(entry.thumbnail) ?? UIImage()
        activeAtlas[entry.brawler] = image
        TextureSwap.shared.swap(brawler: entry.brawler, skin: entry.skin, image: image)
    }

    func loadThumbnail(_ named: String) -> UIImage? {
        if let img = UIImage(named: named) { return img }
        return SkinChanger.generatePlaceholder(label: named)
    }

    static func generatePlaceholder(label: String) -> UIImage {
        let size = CGSize(width: 96, height: 96)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let hue = CGFloat(abs(label.hashValue) % 1000) / 1000.0
            UIColor(hue: hue, saturation: 0.55, brightness: 0.85, alpha: 1).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            let letter = String(label.prefix(1)).uppercased()
            let attr: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 40, weight: .heavy)
            ]
            let s = NSAttributedString(string: letter, attributes: attr)
            let r = s.size()
            s.draw(at: CGPoint(x: (size.width - r.width) / 2, y: (size.height - r.height) / 2))
        }
    }

    static func defaultCatalog() -> [SkinEntry] {
        let brawlers = ["Shelly", "Colt", "Bull", "Jessie", "Nita", "Dynamike",
                        "ElPrimo", "Mortis", "Spike", "Crow", "Leon", "Sandy",
                        "Amber", "Edgar", "Byron", "Belle", "Buzz", "Griff"]
        var out: [SkinEntry] = []
        for b in brawlers {
            let skins = ["Default", "Pirate", "Ranger", "Mecha", "True Silver", "True Gold"]
            for s in skins {
                out.append(SkinEntry(brawler: b, skin: s, thumbnail: "\(b)_\(s)"))
            }
        }
        return out
    }
}

final class TextureSwap {
    static let shared = TextureSwap()
    private var mapping: [String: UIImage] = [:]

    func swap(brawler: String, skin: String, image: UIImage) {
        mapping["\(brawler)"] = image
        for e in EntityTracker.shared.enemies where e.name == brawler {
            e.layer?.contents = image.cgImage
        }
    }

    func textureFor(brawler: String) -> UIImage? { mapping[brawler] }
}

final class SkinChangerView: UIView {
    private let onPick: (String) -> Void
    private let collection: UICollectionView
    private let heightConstraint: NSLayoutConstraint
    private var items: [SkinEntry] = SkinChanger.shared.catalog
    private var selected: IndexPath?

    init(onPick: @escaping (String) -> Void) {
        self.onPick = onPick
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 72, height: 92)
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = 6
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 6, left: 2, bottom: 6, right: 2)
        collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        heightConstraint = NSLayoutConstraint()
        super.init(frame: .zero)
        collection.backgroundColor = .clear
        collection.register(SkinCell.self, forCellWithReuseIdentifier: "c")
        collection.dataSource = self
        collection.delegate = self
        collection.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collection)
        let h = collection.heightAnchor.constraint(equalToConstant: 220)
        NSLayoutConstraint.activate([
            collection.topAnchor.constraint(equalTo: topAnchor),
            collection.leadingAnchor.constraint(equalTo: leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: trailingAnchor),
            collection.bottomAnchor.constraint(equalTo: bottomAnchor),
            h
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}

extension SkinChangerView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int { items.count }
    func collectionView(_ cv: UICollectionView, cellForItemAt ip: IndexPath) -> UICollectionViewCell {
        let c = cv.dequeueReusableCell(withReuseIdentifier: "c", for: ip) as! SkinCell
        c.configure(items[ip.item], selected: selected == ip)
        return c
    }
    func collectionView(_ cv: UICollectionView, didSelectItemAt ip: IndexPath) {
        selected = ip
        cv.reloadData()
        let e = items[ip.item]
        onPick("\(e.brawler)/\(e.skin)")
    }
}

final class SkinCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor

        label.font = .systemFont(ofSize: 9, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2

        [imageView, label].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 68),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 2),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(_ entry: SkinEntry, selected: Bool) {
        imageView.image = SkinChanger.shared.loadThumbnail(entry.thumbnail)
        label.text = "\(entry.brawler)\n\(entry.skin)"
        imageView.layer.borderColor = selected
            ? UIColor.systemYellow.cgColor
            : UIColor.white.withAlphaComponent(0.1).cgColor
        imageView.layer.borderWidth = selected ? 2 : 1
    }
}
