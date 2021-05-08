//
//  OnboardView.swift
//  Hoseno
//
//  Created by Chien Pham on 5/4/21.
//

import SwiftUI

enum StockSortType {
    case symbol
    case price
    case change
}

enum ChangeType {
    case percent
    case value
    
    mutating func toggle() {
        if self == .percent {
            self = .value
        } else {
            self = .percent
        }
    }
}

struct OnboardView: View {
    @ObservedObject var viewModel: OnboardViewModel
    @State var symbol: String = ""
    
    var body: some View {
        VStack {
            LogoView()
                .frame(height: 60)
                .padding(.vertical)
//            Image("bg")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(height: 60)
//                .padding(.vertical)
            
            // MARK: Search Box
            HStack {
                TextField("Symbol", text: $symbol) { _ in
                } onCommit: {
                    addSymbol()
                }
                .frame(width: 215)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Add") {
                    addSymbol()
                }
                .frame(width: 60)
            }
            .overlay(
                VStack {
                    if symbol.isEmpty == false {
                        ScrollView(.vertical, showsIndicators: true, content: {
                            ForEach(
                                Constants.stockList.filter {
                                    $0.containsIgnoringCase(find: symbol) || symbol.containsIgnoringCase(find: $0)
                                }, id: \.self) { text in
                                HStack {
                                    Text(text.uppercased())
                                        .fontWeight(.medium)
                                        .padding(.vertical, 4)
                                        .frame(width: 190)
                                        .background(Color.white)
                                }
                                .onTapGesture(perform: {
                                    symbol = text
                                    addSymbol()
                                })
                            }
                        })
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white)
                        )
                    }
                }
                .frame(minHeight: 100)
                .offset(x: 1, y: 30)
                ,alignment: .topLeading
            )
            .zIndex(1)
            
            // MARK: Header
            HStack {
                Text("Sym").frame(width: 60).onTapGesture { viewModel.sortType = .symbol }
                Text("Match").frame(width: 60).onTapGesture { viewModel.sortType = .price }
                HStack(spacing: 2) {
                    Text("ᐊ").onTapGesture {
                        viewModel.toggleChangeType()
                    }
                    Text(viewModel.changeType == .percent ? " % " : "+/-")
                    Text("ᐅ").onTapGesture {
                        viewModel.toggleChangeType()
                    }
                }.frame(width: 60)
                .onTapGesture { viewModel.sortType = .change }
                Text("Volume")
                    .frame(width: 80, alignment: .trailing)
                    .padding(.trailing, 10)
                    .onTapGesture { viewModel.sortType = .price }
            }
            .padding(.vertical, 4)
            .foregroundColor(.white)
            .background(Color.black)
        
            // MARK: Stock list
            ForEach(viewModel.stocks.indices, id: \.self) { index in
                let stock = viewModel.stocks[index]
                let isUpdate = viewModel.updateIndice.contains(index)
                let bgColor = Color.black.opacity(index % 2 == 0 ? 0.7 : 0.9)
                HStack {
                    Text(stock.symbol.uppercased())
                        .fontWeight(.medium)
                        .frame(width: 60)
                    Text(stock.price.stockPrice)
                        .frame(width: 60)
                    Text(stock.changeString(viewModel.changeType == .percent))
                        .frame(width: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .padding(.horizontal, 4)
                                .padding(.vertical, -2)
                                .foregroundColor(isUpdate ? stock.color.opacity(0.8) : .clear)
                                .animation(.easeIn(duration: 0.2))
                        )
                    Text("\(stock.volume)")
                        .frame(width: 80, alignment: .trailing)
                        .padding(.trailing, 10)
                }
                .foregroundColor(stock.color)
                .padding(.vertical, 4)
                .background(bgColor)
            }
            
            HStack {
                Button(action: {
                    pin.toggle()
                    let ns = NotificationCenter.default
                    ns.post(.init(name: Notification.Name(rawValue: pin ? "pin" : "unpin")))
                }, label: {
                    Text(pin ? "Unpin" : "Pin")
                })
                Spacer()
                Text("Made by Chien Pham")
                    .italic()
                    .font(.system(size: 10))
                    .frame(alignment: .trailing)
            }
            .padding(.top, -5)
        }
        
        .onAppear(perform: {
            viewModel.startFetchData()
        })
        .padding(4)
    }
    @State var pin = true
    
    private func addSymbol() {
        guard symbol.isEmpty == false,
              Constants.stockList.contains(symbol)
        else { return }
        viewModel.updateList(symbol: symbol, action: .add)
        symbol = ""
    }
}

struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardView(viewModel: .init())
    }
}
