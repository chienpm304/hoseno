//
//  Stock.swift
//  Hoseno
//
//  Created by Chien Pham on 5/8/21.
//

import SwiftUI

enum Exchange: String {
    case hsx = "HOSE"
    case hnx = "HNX"
    case upcom = "UPCOM"
}

struct Stock {
    let symbol: String
    let price: Double
    let exchange: Exchange = .hsx
    let ref: Double
    let volume: Int
}

extension Stock {
    var changePrice: Double {
        price - ref
    }
    
    var changePercent: Double {
        guard ref != 0 else { return 0}
        return (price - ref) / ref * 100
    }
    
    func changeString(_ isPercent: Bool = true) -> String {
        return isPercent
            ? "\(changePercent.stockPrice)%"
            : changePrice.stockPrice
    }
    
    var color: Color {
        changePrice == 0
            ? .yellow
            : changePrice > 0 ? .green : .red
    }
}
