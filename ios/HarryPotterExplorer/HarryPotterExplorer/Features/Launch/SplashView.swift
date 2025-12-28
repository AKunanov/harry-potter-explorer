import Lottie
import SwiftUI

struct SplashView: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            LottieView(animationName: "magic", loopMode: .playOnce) {
                withAnimation(.easeOut(duration: 0.25)) {
                    isPresented = false
                }
            }
            .frame(width: 220, height: 220)
        }
    }
}
