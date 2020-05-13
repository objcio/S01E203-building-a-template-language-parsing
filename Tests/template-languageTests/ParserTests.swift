import XCTest
import template_language

final class ParserTests: XCTestCase {
    
    func testVariable() throws {
        for input in ["{ foo }", "{foo}"] {
            XCTAssertEqual(try input.parse(), .variable(name: "foo"))
        }
    }
    
    func testTag() throws {
        let input = "<p></p>"
        XCTAssertEqual(try input.parse(), .tag(name: "p"))
    }

    func testTagBody() throws {
        let input = "<p><span>{ foo }</span><div></div></p>"
        XCTAssertEqual(try input.parse(), .tag(name: "p", body: [
            .tag(name: "span", body: [
                .variable(name: "foo")
            ]),
            .tag(name: "div")
        ]))
    }

    // TODO: test that identifier is not an empty string
    
    func _testSyntax() {
        _ = """
        <head><title>{ title }</title></head>
        <body>
            <ul>
                { for post in posts }
                    { if post.published }
                        <li><a href={post.url}>{ post.title }</a></li>
                    { end }
                { end }
            </ul>
        </body>
        """
    }
}
