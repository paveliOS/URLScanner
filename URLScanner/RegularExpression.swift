enum RegularExpression: String {
    case urlValidation = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
    static func getForLengthValidation(min: Int, max: Int) -> String {
        return String(format: "^.{%d,%d}$", min, max)
    }
    
    static func getForNumberValidation(length: Int, optional: Bool) -> String {
        return optional ? String(format: "^([1-9]\\d{0,%d})?$", length - 1) : String(format: "^[1-9]\\d{0,%d}$", length - 1)
    }
}
