//
//  FileColorSchemePickerView.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/09.
//

import Foundation
import SwiftUI


struct ColorSchemePickerView: View {
    @AppStorage(wrappedValue: 0, "appearanceMode") var appearanceMode
    
    var body: some View {
//        NavigationStack {
            Form {
                Section {
                    Picker("ColorScheme settings", selection: $appearanceMode) {
                        Text("システム標準")
                            .tag(0)
                        Text("ダークモード")
                            .tag(1)
                        Text("ライトモード")
                            .tag(2)
                    }
                    .pickerStyle(.automatic)
                }
            }
//        }
    }
}
