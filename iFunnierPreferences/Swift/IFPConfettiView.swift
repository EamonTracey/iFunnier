import UIKit
import QuartzCore

public class IFPConfettiView: UIView {

    private var emitter: CAEmitterLayer!
    public var colors: [UIColor]!
    private var active: Bool!

    private var confettiImage: UIImage {
        let url = URL(fileURLWithPath: "/Library/PreferenceBundles/iFunnierPreferences.bundle/confetti.png")
        let data = try! Data(contentsOf: url)
        return UIImage(data: data)!
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    func setup() {
        colors = [UIColor(red:0.95, green:0.40, blue:0.27, alpha:1.0),
            UIColor(red:1.00, green:0.78, blue:0.36, alpha:1.0),
            UIColor(red:0.48, green:0.78, blue:0.64, alpha:1.0),
            UIColor(red:0.30, green:0.76, blue:0.85, alpha:1.0),
            UIColor(red:0.58, green:0.39, blue:0.55, alpha:1.0)]
        active = false
    }

    @objc public func startConfetti() {
        emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: frame.size.width / 2.0, y: 0)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: frame.size.width, height: 1)

        var cells = [CAEmitterCell]()
        for color in colors {
            cells.append(confettiWithColor(color: color))
        }

        emitter.emitterCells = cells
        layer.addSublayer(emitter)
        active = true
    }

    @objc public func stopConfetti() {
        emitter?.birthRate = 0
        active = false
    }

    func confettiWithColor(color: UIColor) -> CAEmitterCell {
        let confetti = CAEmitterCell()
        confetti.birthRate = 6.0
        confetti.lifetime = 14.0
        confetti.lifetimeRange = 0
        confetti.color = color.cgColor
        confetti.velocity = CGFloat(350.0)
        confetti.velocityRange = CGFloat(80.0)
        confetti.emissionLongitude = CGFloat(Double.pi)
        confetti.emissionRange = CGFloat(Double.pi)
        confetti.spin = CGFloat(3.5)
        confetti.spinRange = CGFloat(4.0)
        confetti.scaleRange = CGFloat(1)
        confetti.scaleSpeed = CGFloat(-0.1)
        confetti.contents = confettiImage.cgImage
        return confetti
    }

    @objc public func isActive() -> Bool {
    	return self.active
    }

}