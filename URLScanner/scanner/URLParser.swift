import Foundation

protocol URLParserProtocol: class {
    func matches(of pattern: String, in string: String, onlyUnique: Bool) throws -> [String]
}

final class URLParser {}

extension URLParser: URLParserProtocol {
    
    func matches(of pattern: String, in string: String, onlyUnique: Bool) throws -> [String] {
        let regExp = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let results = regExp.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        let matches = results.map {
            String(string[Range($0.range, in: string)!])
        }
        return onlyUnique ? Array(Set(matches)) : matches
    }
}
