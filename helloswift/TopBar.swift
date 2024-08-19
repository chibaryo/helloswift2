//
//  TopBar.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/08.
//

import Foundation
import SwiftUI

struct TopBar: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Text("安否確認アプリ").font(.system(size: 20)).fontWeight(.semibold).foregroundColor(colorScheme == .dark ? .black : .white).frame(maxWidth: .infinity, alignment: .center)
                Spacer()
/*                Button(action: {
                }) {
                    Image(systemName: "plus").font(.headline).foregroundColor(.white)
                }*/
            }
        }.padding().background(colorScheme == .dark ? .purple : Color("Color"))
    }
}
