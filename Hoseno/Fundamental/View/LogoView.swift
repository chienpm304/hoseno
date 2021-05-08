//
//  LogoView.swift
//  Hoseno
//
//  Created by Chien Pham on 5/8/21.
//

import SwiftUI

struct LogoView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer()
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 60)
                .padding(.trailing, 8)
            Text(Constants.productName)
                .font(.system(size: 35))
                .fontWeight(.regular)
            Spacer()
        }
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView()
    }
}
