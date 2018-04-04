import Foundation

enum URLScanError: Error {
    case load
    case parse
    
    var description: String {
        switch self {
        case .load:
            return "Failed to load"
        case .parse:
            return "Failed to parse"
        }
    }
}
