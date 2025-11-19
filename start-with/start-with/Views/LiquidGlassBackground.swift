import SwiftUI

struct LiquidGlassBackground: View {
    var body: some View {
        ZStack {
            // ベースグラデーション背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.4),
                    Color(red: 0.2, green: 0.3, blue: 0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // 動的な光のエフェクト
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.3, green: 0.6, blue: 0.9).opacity(0.3),
                            Color(red: 0.5, green: 0.7, blue: 1.0).opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: -100, y: -150)
                .blur(radius: 60)

            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.4, blue: 0.8).opacity(0.2),
                            Color(red: 0.3, green: 0.5, blue: 0.9).opacity(0.1)
                        ]),
                        startPoint: .center,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: 150, y: 200)
                .blur(radius: 80)
        }
    }
}

struct LiquidGlassView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .background(Capsule().stroke(Color.white.opacity(0.2)))
            )
            .backdrop()
    }
}

extension View {
    func backdrop() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
                    .blur(radius: 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
            )
    }
}

#Preview {
    ZStack {
        LiquidGlassBackground()
        VStack {
            Text("Liquid Glass Effect")
                .font(.title)
                .foregroundColor(.white)
                .padding()
                .backdrop()
        }
    }
}
