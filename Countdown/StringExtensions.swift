//
//  StringExtensions.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-25.
//

import Foundation
import NaturalLanguage

extension String {
    func filter(by partsOfSpeech: [NLTag]) -> [Substring] {
        let tagger = NLTagger(tagSchemes: [.nameTypeOrLexicalClass])
        tagger.string = self
        
        let tags = tagger.tags(
            in: self.startIndex ..< self.endIndex,
            unit: .word,
            scheme: .nameTypeOrLexicalClass,
            options: [.omitPunctuation, .omitWhitespace, .omitOther]
        )
        
        return tags
            .filter { (tag, _) in
                tag.map { partsOfSpeech.contains($0) } ?? false
            }
            .map { (_, range) in self[range] }
    }
}
