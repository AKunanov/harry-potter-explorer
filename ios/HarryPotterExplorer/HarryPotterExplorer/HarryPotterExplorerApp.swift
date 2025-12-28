//
//  HarryPotterExplorerApp.swift
//  HarryPotterExplorer
//
//  Created by Арслан Кунанов on 27.12.2025.
//

import Lottie
import SwiftUI

@main
struct HarryPotterExplorerApp: App {
    init() {
        _ = LottieAnimation.named("launch")
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

private struct RootView: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            ContentView()
            if showSplash {
                SplashOverlay {
                    withAnimation(.easeOut(duration: 0.25)) {
                        showSplash = false
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }
}

private struct SplashOverlay: View {
    let onFinished: () -> Void
    private let animationSize: CGFloat = CGFloat(220.0)
    @State private var didFinish = false

    private var animationName: String {
        if LottieAnimation.named("launch") != nil {
            return "launch"
        }
        return "magic"
    }

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            LottieView(animationName: animationName, loopMode: .playOnce) {
                finishOnce()
            }
            .frame(width: animationSize, height: animationSize)
        }
        .onAppear {
            guard let animation = LottieAnimation.named(animationName) else {
                finishOnce()
                return
            }
            scheduleFallbackFinish(duration: animation.duration)
        }
    }

    private func scheduleFallbackFinish(duration: TimeInterval) {
        guard !didFinish else { return }
        Task {
            let nanoseconds = UInt64(max(duration, 0.1) * 1_000_000_000)
            try? await Task.sleep(nanoseconds: nanoseconds)
            await MainActor.run {
                finishOnce()
            }
        }
    }

    private func finishOnce() {
        guard !didFinish else { return }
        didFinish = true
        onFinished()
    }
}
