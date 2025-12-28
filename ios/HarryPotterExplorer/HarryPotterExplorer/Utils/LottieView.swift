import Lottie
import SwiftUI

struct LottieView: UIViewRepresentable {
    let animationName: String
    var loopMode: LottieLoopMode = .playOnce
    var onFinished: (() -> Void)?

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let animationView = LottieAnimationView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.animation = LottieAnimation.named(animationName)
        animationView.loopMode = loopMode
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundColor = .clear
        animationView.clipsToBounds = true

        container.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        context.coordinator.animationView = animationView
        context.coordinator.lastAnimationName = animationName
        context.coordinator.lastLoopMode = loopMode

        play(animationView)
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let animationView = context.coordinator.animationView else {
            return
        }
        if context.coordinator.lastAnimationName != animationName {
            animationView.animation = LottieAnimation.named(animationName)
            animationView.currentProgress = 0
            context.coordinator.lastAnimationName = animationName
        }
        if context.coordinator.lastLoopMode != loopMode {
            animationView.loopMode = loopMode
            context.coordinator.lastLoopMode = loopMode
        }
        if !animationView.isAnimationPlaying {
            play(animationView)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        var animationView: LottieAnimationView?
        var lastAnimationName: String?
        var lastLoopMode: LottieLoopMode?
    }

    private func play(_ animationView: LottieAnimationView) {
        animationView.play { completed in
            if completed {
                DispatchQueue.main.async {
                    onFinished?()
                }
            }
        }
    }
}
