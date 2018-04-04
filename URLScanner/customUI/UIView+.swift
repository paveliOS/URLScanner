import UIKit

extension UIView {
    func shake(count: Float = 3, for duration: TimeInterval = 0.15, withTranslation translation: CGFloat = 5) {
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.repeatCount = count
        animation.duration = duration / TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: -translation, y: center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: translation, y: center.y))
        layer.add(animation, forKey: "shake")
    }
}
