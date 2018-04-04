import XCTest
@testable import URLScanner

class URLScannerParserTests: XCTestCase {
    
    let parser: URLParserProtocol = URLParser()
    var htmlString: String!
    
    override func setUp() {
        super.setUp()
        let bundle = Bundle(for: URLScannerParserTests.self)
        let htmlURL = bundle.url(forResource: "wiki", withExtension: "htm")!
        htmlString = try! String(contentsOf: htmlURL)
    }
    
    func testURLParserTextParsing() {
        let matches = try! parser.matches(of: "man", in: htmlString, onlyUnique: true)
        XCTAssert(matches.count == 2)
    }
    
    func testURLParserURLParsing() {
        let matches = try! parser.matches(of: RegularExpression.urlValidation.rawValue, in: htmlString, onlyUnique: false)
        XCTAssert(matches.count == 127)
    }
    
}
