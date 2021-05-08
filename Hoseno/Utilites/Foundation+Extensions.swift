//
//  Foundation+Extensions.swift
//  Hoseno
//
//  Created by Chien Pham on 5/8/21.
//

import Foundation

extension Double {
    var stockPrice: String {
        let price = self > 1000 ? self / 1000 : self
        let numberFormatter = NumberFormatter()
        numberFormatter.groupingSeparator = ","
        numberFormatter.groupingSize = 3
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.decimalSeparator = "."
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 2
        return numberFormatter.string(from: price as NSNumber)!
    }
}

extension Array where Element: Comparable {
    func isAscending() -> Bool {
        return zip(self, self.dropFirst()).allSatisfy(<=)
    }

    func isDescending() -> Bool {
        return zip(self, self.dropFirst()).allSatisfy(>=)
    }
}

extension String {
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}

class Utilites {
    static func parseNumber(str: String?) -> Int? {
        guard let string = str else { return nil }
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf.number(from: string)?.intValue
    }
}
