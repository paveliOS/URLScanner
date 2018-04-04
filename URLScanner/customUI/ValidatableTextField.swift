import UIKit

class ValidatableField: UITextField {
    
    private var regExp: String?
    private var valid: Bool
    
    required init?(coder aDecoder: NSCoder) {
        valid = true
        super.init(coder: aDecoder)
        addTarget(self, action: #selector(textFieldIsEditing(_:)), for: .editingChanged)
    }
    
    func validate() {
        if let regExp = self.regExp {
            valid = matchesFound(pattern: regExp, in: self.text!)
        }
    }
    
    @objc private func textFieldIsEditing(_ textField: UITextField) {
        validate()
    }
    
    private func matchesFound(pattern: String, in string: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let matches = regex.matches(in: string, options: [], range: NSMakeRange(0, string.count))
            return !matches.isEmpty
        } catch let error as NSError {
            NSLog("Failed to initialize regular expression with error: \(error.description)")
            return false
        }
    }
    
}

extension ValidatableField {
    
    var isValid: Bool {
        validate()
        return valid
    }
    
    final func setRegularExpression(_ regExp: String) {
        self.regExp = regExp
    }
    
}

