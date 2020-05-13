public indirect enum Expression: Hashable {
    case variable(name: String)
    case tag(name: String, attributes: [String:Expression] = [:], body: [Expression] = [])
}

extension String {
    public func parse() throws -> Expression {
        var remainder = self[...]
        return try remainder.parse()
    }
}

extension Substring {
    mutating func remove(prefix: String) -> Bool {
        guard hasPrefix(prefix) else { return false }
        removeFirst(prefix.count)
        return true
    }
    
    mutating func skipWS() {
        while first?.isWhitespace == true {
            removeFirst()
        }
    }
    
    mutating func parse() throws -> Expression {
        if remove(prefix: "{") {
            skipWS()
            let name = try parseIdentifier()
            skipWS()
            guard remove(prefix: "}") else {
                fatalError()
            }
            return .variable(name: name)
        } else if remove(prefix: "<") {
            let name = try parseTagName()
            guard remove(prefix: ">") else { fatalError() }
            let closingTag = "</\(name)>"
            var body: [Expression] = []
            while !remove(prefix: closingTag)  {
                body.append(try parse())
            }
            return .tag(name: name, body: body)
        } else {
            fatalError("Unexpected token")
        }
    }
    
    mutating func remove(while cond: (Element) -> Bool) -> SubSequence {
        var current = startIndex
        while current < endIndex, cond(self[current]) {
            formIndex(after: &current)
        }
        let result = self[startIndex..<current]
        self = self[current...]
        return result
    }

    mutating func parseTagName() throws -> String {
        let result = remove(while: { $0.isTagName })
        guard !result.isEmpty else { fatalError() }
        return String(result)
    }

    mutating func parseIdentifier() throws -> String {
        let result = remove(while: { $0.isIdentifier })
        guard !result.isEmpty else { fatalError() }
        return String(result)
    }
}

extension Character {
    var isIdentifier: Bool {
        isLetter
    }

    var isTagName: Bool {
        isLetter
    }
}
