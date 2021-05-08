//
//  OnboardViewModel.swift
//  Leaky
//
//  Created by Chien Pham on 5/4/21.
//

import Foundation
import SwiftUI
import SocketIO

enum UpdateStockAction {
    case add
    case remove
}

class OnboardViewModel: ObservableObject {
    
    let socket: SocketService = SocketService()
    
    @Published var updateIndice = [Int]()
    
    @Published var changeType: ChangeType = .percent
    
    @Published var stocks: [Stock] = [] {
        didSet {
            if socket.symbols.count != stocks.count {
                socket.symbols = stocks.map { $0.symbol }
            }
        }
    }
    
    @Published var sortType: StockSortType = .symbol {
        didSet {
            guard stocks.count > 1 else { return }
            var ascending = true
            if oldValue == sortType {
                switch sortType {
                case .symbol:
                    ascending = !stocks.map { $0.symbol }.isAscending()
                case .price:
                    ascending = !stocks.map { $0.price }.isAscending()
                case .change:
                    if changeType == .percent {
                        ascending = !stocks.map { $0.changePercent }.isAscending()
                    } else {
                        ascending = !stocks.map { $0.changePrice }.isAscending()
                    }
                }
            }
            
            stocks = stocks.sorted {
                switch sortType {
                case .symbol:
                    return ascending ? $0.symbol < $1.symbol : $0.symbol > $1.symbol
                case .price:
                    return ascending ? $0.price < $1.price : $0.price > $1.price
                case .change:
                    if changeType == .percent {
                        return ascending ? $0.changePercent < $1.changePercent : $0.changePercent > $1.changePercent
                    } else {
                        return ascending ? $0.changePrice < $1.changePrice : $0.changePrice > $1.changePrice
                    }
                }
            }
        }
    }
    
    func updateList(symbol: String, action: UpdateStockAction) {
        let symbol = symbol.lowercased()
        let isContained = stocks.contains(where: { $0.symbol == symbol })
        switch action {
        case .add:
            if isContained == false {
                stocks.append(.init(symbol: symbol, price: 0, ref: 0, volume: 0))
            }
        case .remove:
            if isContained {
                stocks.removeAll(where: { $0.symbol == symbol })
            }
        }
    }
    
    func toggleChangeType() {
        changeType.toggle()
    }
    
    func startFetchData() {
        // fetch local data
        stocks = [
            .init(symbol: "tpb", price: 0, ref: 0, volume: 0),
            .init(symbol: "tcb", price: 0, ref: 0, volume: 0),
            .init(symbol: "mwg", price: 0, ref: 0, volume: 0),
            .init(symbol: "vhc", price: 0, ref: 0, volume: 0),
            .init(symbol: "mbb", price: 0, ref: 0, volume: 0),
        ]
        
        // start socket for update
        socket.delegate = self
        socket.start()
    }
    
    func stopFetchData() {
        socket.stop()
        socket.delegate = nil
        socket.symbols = []
    }
}

extension OnboardViewModel: SocketServiceDelegate {
    func didConnect() {
        print("Socket CONNECTED!")
    }
    
    func didDisconnect() {
        print("Socket DISCONNECTED!")
    }
    
    func didReceiveStock(stock: Stock) {
        guard let index = stocks.firstIndex(where: { $0.symbol == stock.symbol}),
              stocks[index].price != stock.price || stocks[index].ref != stock.ref || stocks[index].volume != stock.volume
        else { return }
        updateIndice = [index]
        stocks[index] = stock
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            self.updateIndice = []
        }
    }
}

