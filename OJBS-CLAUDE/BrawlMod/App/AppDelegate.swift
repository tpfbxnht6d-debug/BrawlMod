import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let w = UIWindow(frame: UIScreen.main.bounds)
        w.rootViewController = HostViewController()
        w.backgroundColor = .black
        w.makeKeyAndVisible()
        window = w
        OverlayWindowManager.shared.install()
        return true
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let cfg = UISceneConfiguration(name: "Default", sessionRole: connectingSceneSession.role)
        cfg.delegateClass = SceneDelegate.self
        return cfg
    }
}

final class HostViewController: UIViewController {
    private let launchButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.05, green: 0.06, blue: 0.09, alpha: 1)

        titleLabel.text = "BrawlMod"
        titleLabel.font = .systemFont(ofSize: 44, weight: .heavy)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center

        subtitleLabel.text = "overlay engaged — tap Open bottom-left"
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.65)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        launchButton.setTitle("Launch Brawl Stars", for: .normal)
        launchButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        launchButton.setTitleColor(.white, for: .normal)
        launchButton.backgroundColor = UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1)
        launchButton.layer.cornerRadius = 14
        launchButton.addTarget(self, action: #selector(launchGame), for: .touchUpInside)

        [titleLabel, subtitleLabel, launchButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            launchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            launchButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            launchButton.widthAnchor.constraint(equalToConstant: 260),
            launchButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    @objc private func launchGame() {
        guard let url = URL(string: "brawlstars://") else { return }
        UIApplication.shared.open(url, options: [:]) { ok in
            if !ok, let store = URL(string: "https://apps.apple.com/app/brawl-stars/id1229016807") {
                UIApplication.shared.open(store)
            }
        }
    }
}
