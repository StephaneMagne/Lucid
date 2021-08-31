//
//  StringUtils.swift
//  LucidCodeGenCore
//
//  Created by Théophane Rupin on 3/20/19.
//

import Foundation
import Meta

public extension String {
    
    enum Configuration {

        fileprivate(set) static var _lexicon = [String: String]()
        public static func setLexicon(_ lexicon: [String]) {
            _lexicon = [:]
            for word in lexicon {
                _lexicon[word.lowercased()] = word
            }
        }
        
        public static var entitySuffix = ""
    }
    
    func camelCased(separators: String = "_", ignoreLexicon: Bool = false) -> String {
        return components(separatedBy: CharacterSet(charactersIn: separators))
            .reduce(into: String()) { string, word in
                if ignoreLexicon == false, let wordFromLexicon = Configuration._lexicon[word.lowercased()] {
                    string += wordFromLexicon
                } else {
                    string += word.capitalized
                }
            }
            .trimmingCharacters(in: CharacterSet(charactersIn: separators))
    }

    private static let snakeCasedRegex: NSRegularExpression = {
        let pattern = "([a-z0-9])([A-Z])"
        do {
            return try NSRegularExpression(pattern: pattern, options: [])
        } catch {
            fatalError("Could not create regex from pattern: \(pattern): \(error)")
        }
    }()

    var snakeCased: String {
        let range = NSRange(location: 0, length: count)
        return String
            .snakeCasedRegex
            .stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2")
            .lowercased()
    }

    func variableCased(ignoreLexicon: Bool = false) -> String {
        return split(separator: ".").map { string in
            if let wordFromLexicon = Configuration._lexicon[string.lowercased()] {
                return ignoreLexicon ? string.lowercased() : wordFromLexicon
            }
            var prefix = string.prefix { String($0) == String($0).uppercased() }
            if prefix.count > 1 && prefix.count < count {
                prefix.removeLast()
            }
            return String(prefix.lowercased() + suffix(count - prefix.count))
        }.joined(separator: ".")
    }
    
    var pluralName: String {
        if let wordFromLexicon = Configuration._lexicon[lowercased()] {
            return wordFromLexicon + "s"
        }

        let suffixMap: [(String, String)] = [
            ("y", "ies"),
            ("ed", "ed"),
            ("o", "o"),
            ("s", "s"),
        ]
        
        return suffixMap
            .first { hasSuffix($0.0) }
            .flatMap { dropLast($0.0.count) + $0.1 } ?? self + "s"
    }
    
    func suffixedName() -> String {
        if isArray {
            return "[\(arrayElementType())\(String.Configuration.entitySuffix)]"
        }
        return self + String.Configuration.entitySuffix
    }
    
    var isArray: Bool {
        return hasPrefix("[") && hasSuffix("]")
    }

    var isDictionary: Bool {
        return hasPrefix("{") && hasSuffix("}") && contains(":")
    }

    func arrayElementType() -> String {
        guard isArray else { return self }
        var string = self
        string.removeLast()
        string.removeFirst()
        guard string.isArray == false, string.isDictionary == false else {
            fatalError(CodeGenError.unsupportedType(self).description)
        }
        return string
    }

    func dictionaryElementTypes() -> (key: String, value: String)? {
        guard isDictionary else { return nil }
        var string = self
        string.removeLast()
        string.removeFirst()
        let items = string.split(separator: ":").map { String($0) }
        guard items.count == 2 else {
            fatalError(CodeGenError.unsupportedType(self).description)
        }
        guard items[0].isArray == false, items[0].isDictionary == false,
              items[1].isArray == false, items[1].isDictionary == false else {
            fatalError(CodeGenError.unsupportedType(self).description)
        }
        return (key: items[0], value: items[1])
    }

    var reference: Reference {
        return .named(variableCased())
    }
}
