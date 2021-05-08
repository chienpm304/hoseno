//
//  SocketService.swift
//  Hoseno
//
//  Created by Chien Pham on 5/8/21.
//

import Foundation
import SocketIO

protocol SocketServiceDelegate: class {
    func didConnect()
    func didDisconnect()
    func didReceiveStock(stock: Stock)
}

enum SocketStockEvent: String {
    case stockInfo = "stockname_info"
    case stockName = "stockname"
}

class SocketService: NSObject {
    
    let manager = SocketManager(
        socketURL: URL(string: "http://localhost:8000")!,
//        socketURL: URL(string: "https://m.cophieu68.vn:6672")!,
        config: [
            .log(false),
            .compress,
        ]
    )
    
    weak var delegate: SocketServiceDelegate?
    var symbols = [String]() {
        didSet {
            emitSocket()
        }
    }
    
    var socket: SocketIOClient {
        manager.defaultSocket
    }

    var timer: Timer?

    private func setup() {
        socket.on(clientEvent: .connect) { [weak self] data, ack in
            guard let self = self else { return }
            self.delegate?.didConnect()
            self.timer = Timer.scheduledTimer(
                timeInterval: 10,
                target: self,
                selector: #selector(self.emitSocket),
                userInfo: nil,
                repeats: true)

        }
        
        socket.on(clientEvent: .disconnect) { [weak self] data, ack in
            guard let self = self else { return }
            self.delegate?.didDisconnect()
            self.timer?.invalidate()
            self.timer = nil
        }
        
        socket.on(SocketStockEvent.stockInfo.rawValue) { [weak self] data, ack in
//            print("XXX receive: \(data) \n -> ack:\(ack)")
            guard let self = self,
                  let stock = self.parse(data)
            else { return }
            self.delegate?.didReceiveStock(stock: stock)
        }
    }
    
    @objc func emitSocket() {
        guard symbols.isEmpty == false else { return }
        let data = symbols.joined(separator: "|")
        socket.emit(SocketStockEvent.stockName.rawValue, data)
        print("Emitted: \(data)")
    }
    
    func start() {
        setup()
        socket.connect()
    }
    
    func stop() {
        socket.disconnect()
        socket.removeAllHandlers()
    }
    
    private func parse(_ data: [Any]) -> Stock? {
        guard let info = (data.first as? String)?.components(separatedBy: "|"),
              info.isEmpty == false,
              info.count > 26,
              let symbol = info.first,
              let price = Double(info[7]),
              let ref = Double(info[26]),
              let volume = Utilites.parseNumber(str: info[8])
        else { return nil }
        return Stock(symbol: symbol, price: price, ref: ref, volume: volume)
    }
}
