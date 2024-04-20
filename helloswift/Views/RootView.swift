//
//  RootView.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/17.
//

import Foundation
import SwiftUI
import SlidingTabView

struct RootView: View {
    @State private var tabIndex: Int = 0
    @StateObject var viewModel = AuthViewModel()

    var body: some View {
        VStack {
            SlidingTabView(
                selection: $tabIndex,
                tabs:
                            [
                                "ログイン",
                                "サインアップ"
                            ],
                animation: .easeInOut
            )
            Spacer()
            if tabIndex == 0 {
                LoginView(viewModel: viewModel)
            } else if tabIndex == 1 {
                SignupView(viewModel: viewModel)
            }
        }
    }
}
