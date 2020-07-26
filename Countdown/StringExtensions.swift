//
//  StringExtensions.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-25.
//

import Foundation
import NaturalLanguage

extension String {
    /// Extracts the substrings of this string which match any of the specified `partsOfSpeech`
    ///
    /// For example,
    ///
    ///     let string = "John's anniversary in Greece"
    ///     let filtered = string.filter(by: [.noun, .placeName]) // ["anniversary", "Greece"]
    ///
    /// - Parameter partsOfSpeech: an array of `NLTags` specifying which parts of speech should be extracted
    ///
    /// - Returns: An array of `Substring`s which match any of the specified parts of speech
    func filter(by partsOfSpeech: [NLTag]) -> [Substring] {
        let tagger = NLTagger(tagSchemes: [.nameTypeOrLexicalClass])
        tagger.string = self
        
        let tags = tagger.tags(
            in: self.startIndex ..< self.endIndex,
            unit: .word,
            scheme: .nameTypeOrLexicalClass,
            options: [.omitPunctuation, .omitWhitespace, .omitOther]
        )
        
        let filtered = tags.filter { (tag, _) in
            if let tag = tag {
                return partsOfSpeech.contains(tag)
            }
            return false
        }
        
        return filtered.map { (_, range) in self[range] }
    }
}
