//
//  Extensions.swift
//  URL Shortener
//
//  Created by Ivan Ivanušić on 24/10/2020.
//

import Foundation

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    func deletingSufix(_ sufix: String) -> String {
        guard self.hasSuffix(sufix) else { return self }
        return String(self.dropLast(sufix.count))
    }
    
    func capitalizingFirstLetter() -> String {
        return self.prefix(1).capitalized + self.dropFirst()
    }
}
