//
//  ConfettiView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-26.
//

import SwiftUI

extension View {
    func confettiOverlay(_ emoji: String, emitWhen condition: Binding<Bool>) -> some View {
        self.overlay(ConfettiView(emoji: emoji, shouldEmit: condition))
    }
}

struct ConfettiView: View {
    let emoji: String
    @Binding var shouldEmit: Bool
    
    var body: some View {
        ConfettiViewImpl(emoji: emoji, shouldEmit: $shouldEmit)
            .edgesIgnoringSafeArea(.all)
            .allowsHitTesting(false)
    }
}

private let kAnimationLayerKey = "com.nshipster.animationLayer"

fileprivate struct ConfettiViewImpl: UIViewRepresentable {
    let emoji: String
    @Binding var shouldEmit: Bool
    
    func makeUIView(context: UIViewRepresentableContext<ConfettiViewImpl>) -> ConfettiUIView {
        return ConfettiUIView()
    }
    
    func updateUIView(_ uiView: ConfettiUIView, context: Context) {
        if shouldEmit {
            shouldEmit.toggle()
            uiView.emit(with: [emoji])
        }
    }
}

/// A view that emits confetti.
fileprivate final class ConfettiUIView: UIView {
    init() {
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        isUserInteractionEnabled = false
    }

    // MARK: -

    /**
     Emits the provided confetti content for a specified duration.

     - Parameters:
        - contents: The contents to be emitted as confetti.
        - duration: The amount of time in seconds to emit confetti before fading out;
                    3.0 seconds by default.
    */
    public func emit(with contents: [String], for duration: TimeInterval = 3.0) {
        let layer = Layer()
        layer.configure(with: contents)
        layer.frame = self.bounds
        layer.needsDisplayOnBoundsChange = true
        self.layer.addSublayer(layer)

        guard duration.isFinite else { return }

        let animation = CAKeyframeAnimation(keyPath: #keyPath(CAEmitterLayer.birthRate))
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        animation.fillMode = .forwards
        animation.values = [1, 0, 0]
        animation.keyTimes = [0, 0.5, 1]
        animation.isRemovedOnCompletion = false

        layer.beginTime = CACurrentMediaTime()
        layer.birthRate = 1.0

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            let transition = CATransition()
            transition.delegate = self
            transition.type = .fade
            transition.duration = 1
            transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
            transition.setValue(layer, forKey: kAnimationLayerKey)
            transition.isRemovedOnCompletion = false

            layer.add(transition, forKey: nil)

            layer.opacity = 0
        }
        layer.add(animation, forKey: nil)
        CATransaction.commit()
    }

    // MARK: UIView

    override public func willMove(toSuperview newSuperview: UIView?) {
        guard let superview = newSuperview else { return }
        frame = superview.bounds
        isUserInteractionEnabled = false
    }

    // MARK: -
    
    private final class Layer: CAEmitterLayer {
        func configure(with contents: [String]) {
            self.emitterCells = contents.map { content in
                let cell = CAEmitterCell()

                cell.birthRate = 50.0
                cell.lifetime = 10.0
                cell.velocity = CGFloat(cell.birthRate * cell.lifetime)
                cell.velocityRange = cell.velocity / 2
                cell.emissionLongitude = .pi
                cell.emissionRange = .pi / 4
                cell.spinRange = .pi * 8
                cell.scaleRange = 0.25
                cell.scale = 1.0 - cell.scaleRange
                cell.contents = content.image.cgImage

                return cell
            }
        }

        // MARK: CALayer

        override func layoutSublayers() {
            super.layoutSublayers()

            emitterMode = .outline
            emitterShape = .line
            emitterSize = CGSize(width: frame.size.width, height: 1.0)
            emitterPosition = CGPoint(x: frame.size.width / 2.0, y: 0)
        }
    }
}

// MARK: - CAAnimationDelegate

extension ConfettiUIView: CAAnimationDelegate {
    public func animationDidStop(_ animation: CAAnimation, finished flag: Bool) {
        if let layer = animation.value(forKey: kAnimationLayerKey) as? CALayer {
            layer.removeAllAnimations()
            layer.removeFromSuperlayer()
        }
    }
}

// MARK: -

fileprivate extension String {
    var image: UIImage {
        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16.0)
        ]

        return NSAttributedString(string: self, attributes: defaultAttributes).image()
    }
}

fileprivate extension NSAttributedString {
    func image() -> UIImage {
        UIGraphicsImageRenderer(size: size()).image { _ in
            self.draw(at: .zero)
        }
    }
}

struct Test: View {
    @State var shouldEmit: Bool = false

    var body: some View {
        VStack {
            ConfettiView(emoji: "🎉", shouldEmit: $shouldEmit).edgesIgnoringSafeArea(.all)
            
            Button {
                shouldEmit = true
            } label: {
                Text("Click")
            }
        }
    }
}

struct ConfettiView_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
