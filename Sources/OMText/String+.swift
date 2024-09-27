//
//  File.swift
//  
//
//  Created by John Knowles on 9/27/24.
//

import Foundation


extension String {
//    func regex(pattern: String) -> [String] {
//
//        guard !pattern.isEmpty,
//              let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
//        else { return [] }
//
//        return regex
//                .matches(in: self, options: [], range: NSRange(location: 0, length: count))
////                .map {  String(self.) }
//
//    }
}

public extension String {
    public var numberOfWords: Int {
        var count = 0
        let range = startIndex..<endIndex
        enumerateSubstrings(in: range, options: [.byWords, .substringNotRequired, .localized], { _, _, _, _ -> () in
            count += 1
        })
        return count
    }
    
    public var firstLineRange: NSRange? {
        let nsText = self as NSString
        let range = nsText.paragraphRange(for: .init(location: 0, length: 0))
        return range

    }
    
    public func prefixedString(prefix: Character, at index: Int) -> NSRange? {
        let string = self as NSString
        
        let textLength = string.length
        let preRange = 0...index
        let postRange = index..<textLength


        var foundPrefix = false
        var preIndex: Int? = nil
        var postIndex: Int? = nil
        var range: NSRange? = nil

        for i in preRange {
            let idx = index - i
            print(idx, textLength)
            guard idx >= 0 && idx < textLength else { continue }
            preIndex = idx
            let u16char =  string.character(at: idx)
            if let scalar = UnicodeScalar(u16char) {
                let character = Character(scalar)
                if i > 0, character.isWhitespace {
                    break
                } else if character == prefix {
                    foundPrefix = true
                    break
                }
            }
        }
        
        if foundPrefix {
            for idx in postRange {
                guard idx >= 0 && idx < textLength else { continue }
                postIndex = idx
                let u16char =  string.character(at: idx)
                if let scalar = UnicodeScalar(u16char) {
                    let character = Character(scalar)
                    if idx > 0, character.isWhitespace {
                        break
                    } else if character.isPunctuation {
                        if character == "#" {
                            break
                        }
                    }
                }
            }
        }
        if let preIndex, let postIndex {
            range = .init(location: preIndex, length: postIndex - preIndex)
        }
        
        return range
    }
}


extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}

public extension NSAttributedString {
    public func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width,
                                    height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect,
                                       options: .usesLineFragmentOrigin,
                                       context: nil)
        
        return ceil(boundingBox.height)
    }
    
    public func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude,
                                    height: height)
        let boundingBox = boundingRect(with: constraintRect,
                                       options: .usesLineFragmentOrigin,
                                       context: nil)
        
        return ceil(boundingBox.width)
    }
}




extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

#if os(iOS)
import UIKit
extension String {
    
    /// Generates a `UIImage` instance from this string using a specified
    /// attributes and size.
    ///
    /// - Parameters:
    ///     - attributes: to draw this string with. Default is `nil`.
    ///     - size: of the image to return.
    /// - Returns: a `UIImage` instance from this string using a specified
    /// attributes and size, or `nil` if the operation fails.
    ///
    func image(withAttributes attributes: [NSAttributedString.Key: Any]? = nil,
               size: CGSize? = nil) -> UIImage? {
        let size = size ?? (self as NSString).size(withAttributes: attributes)
        return UIGraphicsImageRenderer(size: size).image { _ in
            (self as NSString).draw(in: CGRect(origin: .zero, size: size),
                                    withAttributes: attributes)
        }
    }
    
}
#endif

