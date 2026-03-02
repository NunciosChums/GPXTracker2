import UIKit

/// Simple progress HUD using UIVisualEffectView and UIActivityIndicatorView.
final class ProgressHUD {
  static let shared = ProgressHUD()
  private init() {}

  private weak var hudView: UIView?

  static func show() {
    shared.show()
  }

  static func hide() {
    shared.hide()
  }

  private func show() {
    guard hudView == nil,
          let window = UIApplication.shared.connectedScenes
          .compactMap({ $0 as? UIWindowScene })
          .flatMap({ $0.windows })
          .first(where: { $0.isKeyWindow })
    else { return }

    // Blurred background frame
    let blurEffect = UIBlurEffect(style: .systemMaterial)
    let container = UIVisualEffectView(effect: blurEffect)
    container.frame = CGRect(x: 0, y: 0, width: 88, height: 88)
    container.layer.cornerRadius = 16
    container.layer.masksToBounds = true
    container.center = window.center

    // Spinner
    let spinner = UIActivityIndicatorView(style: .large)
    spinner.center = CGPoint(x: container.bounds.midX, y: container.bounds.midY)
    spinner.startAnimating()
    container.contentView.addSubview(spinner)

    // Dim background
    let backdrop = UIView(frame: window.bounds)
    backdrop.backgroundColor = UIColor.black.withAlphaComponent(0.15)
    backdrop.addSubview(container)

    window.addSubview(backdrop)
    hudView = backdrop

    // Fade in
    backdrop.alpha = 0
    UIView.animate(withDuration: 0.2) {
      backdrop.alpha = 1
    }
  }

  private func hide() {
    guard let view = hudView else { return }
    UIView.animate(withDuration: 0.2, animations: {
      view.alpha = 0
    }, completion: { _ in
      view.removeFromSuperview()
    })
    hudView = nil
  }
}
