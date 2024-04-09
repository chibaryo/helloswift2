//
//  HomeView.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/08.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct HomeView: View {
    //@State var selection = 1
    @AppStorage(wrappedValue: 1, "pageSelection") var pageSelection
    @State var isActive: Bool = false
    var viewModel: AuthViewModel

    var body: some View {
        TabView(selection: $pageSelection) {
            AppHomeScreen()
                .tabItem {
                    Label("ホーム", systemImage: "house")
                }
                .tag(1)
            SettingsScreen(viewModel: viewModel)
                .tabItem {
                    Label("設定", systemImage: "person.crop.circle")
                }
                .tag(2)
        }
        /* NavigationStack {
            VStack {
                Text("Your uid: \(String(describing: viewModel.uid!))")
                    .navigationBarBackButtonHidden(true)
                Button(action: {
                    viewModel.signOut()
                }, label: {
                    Text("ログアウト")
                        .frame(maxWidth: .infinity)
                })
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .padding()
            }
        } */
    }
}
