import SwiftUI

public struct ConfettiParticle: Identifiable {
    public let id = UUID()
    public let color: Color
    public let size: CGFloat
    public let initialX: CGFloat
    public let targetX: CGFloat
    public let speed: Double
    public let spin: Double
    public let shape: Int // 0: rectangle, 1: circle, 2: capsule
}

public struct ConfettiView: View {
    @Binding var isActive: Bool
    @State private var particles: [ConfettiParticle] = []
    @State private var fallProgress: CGFloat = 0.0
    
    private let colors: [Color] = [.red, .green, .blue, .orange, .purple, .pink, .yellow, .mint, .cyan]
    
    public init(isActive: Binding<Bool>) {
        self._isActive = isActive
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                if isActive {
                    ForEach(particles) { p in
                        Group {
                            if p.shape == 0 {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(p.color)
                                    .frame(width: p.size, height: p.size * 0.6)
                            } else if p.shape == 1 {
                                Circle()
                                    .fill(p.color)
                                    .frame(width: p.size * 0.8, height: p.size * 0.8)
                            } else {
                                Capsule()
                                    .fill(p.color)
                                    .frame(width: p.size * 1.2, height: p.size * 0.4)
                            }
                        }
                        .rotationEffect(.degrees(fallProgress * p.spin))
                        .rotation3DEffect(.degrees(fallProgress * p.spin * 1.5), axis: (x: 1, y: 1, z: 0))
                        .position(
                            x: p.initialX + (p.targetX - p.initialX) * fallProgress,
                            y: -20 + (geo.size.height + 60) * fallProgress
                        )
                        .opacity(fallProgress < 0.8 ? 1.0 : Double((1.0 - fallProgress) * 5.0))
                    }
                }
            }
            .onAppear {
                generateParticles(in: geo.size)
            }
            .onChange(of: isActive) { active in
                if active {
                    generateParticles(in: geo.size)
                    fallProgress = 0.0
                    withAnimation(.easeOut(duration: 3.2)) {
                        fallProgress = 1.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
                        isActive = false
                        fallProgress = 0.0
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
    
    private func generateParticles(in size: CGSize) {
        var list: [ConfettiParticle] = []
        let width = size.width > 0 ? size.width : 400
        for _ in 0..<75 {
            let startX = CGFloat.random(in: 0...width)
            let drift = CGFloat.random(in: -80...80)
            let particle = ConfettiParticle(
                color: colors.randomElement() ?? .accentColor,
                size: CGFloat.random(in: 8...16),
                initialX: startX,
                targetX: max(10, min(width - 10, startX + drift)),
                speed: Double.random(in: 2.0...3.5),
                spin: Double.random(in: 360...1080),
                shape: Int.random(in: 0...2)
            )
            list.append(particle)
        }
        self.particles = list
    }
}
