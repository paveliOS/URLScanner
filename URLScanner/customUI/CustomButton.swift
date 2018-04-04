import UIKit

class CustomButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isExclusiveTouch = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isExclusiveTouch = true
    }
    
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            backgroundColor = newValue ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2) : #colorLiteral(red: 0.5490196078, green: 0.5333333333, blue: 1, alpha: 1)
            super.isHighlighted = newValue
        }
    }
    
}

