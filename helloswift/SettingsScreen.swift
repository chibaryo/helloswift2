//
//  AppHomeScreen.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/08.
//

//import Foundation
import SwiftUI

struct Country: Identifiable, Hashable {
    var tagname: String
    var desc: String
    var symbol: String
    var id: String { self.tagname }
}

struct SettingsScreen: View {
    var viewModel: AuthViewModel
//    @AppStorage("isDarkModeEnabled") var isDarkModeEnabled = false
    @AppStorage(wrappedValue: 0, "appearanceMode") var appearanceMode
    //@State var isDarkModeEnabled: Bool = false
    @State var isPresented: Bool = false
    @State private var selectedLanguage: String = ""

    let countries: [Country] = [
        Country(tagname: "japanese", desc: "日本語", symbol: "🇯🇵"),
        Country(tagname: "chinese", desc: "中国語", symbol: "🇨🇳"),
        Country(tagname: "korean", desc: "韓国語", symbol: "🇰🇷"),
        Country(tagname: "english", desc: "英語", symbol: "🇺🇸"),
    ]
    
    var body: some View {
        VStack {
            TopBar()
            NavigationStack {
                    Form {
                        Group {
                            HStack {
                                Spacer()
                                VStack {
                                    Image(systemName: "person")
                                        .resizable()
                                        .frame(width: 30, height: 30, alignment: .center)
                                    Text("User Taro").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                    Text("Email: \(String(describing: viewModel.email!))").font(.subheadline).foregroundColor(.gray)
                                    Spacer()
                                    NavigationLink {
                                        ProfileEditView(viewModel: viewModel)
                                    } label: {
                                        HStack {
                                            Spacer()
                                            Button(action: {}){
                                                Text("プロフィールを編集する")
                                                    .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: .infinity)
                                                    .font(.system(size: 18))
                                                    .padding()
                                            }
                                            Spacer()
                                        }
                                        //                                        Text("プロフィールを編集する")
//                                            .font(.system(size: 18))
//                                            .padding()
                                    }
                                }
                            }
                        }


                        Section(
                            header: Group {
                                if selectedLanguage == "japanese" {
                                    Text("一般")
                                } else if selectedLanguage == "chinese" {
                                    Text("通用")
                                } else if selectedLanguage == "korean" {
                                    Text("일반")
                                } else if selectedLanguage == "english" {
                                    Text("General")
                                }
                            },
                            content: {
                            Section {
                                Picker("カラーテーマ", selection: $appearanceMode) {
                                    Text("システム標準")
                                        .tag(0)
                                    Text("ダークモード")
                                        .tag(1)
                                    Text("ライトモード")
                                        .tag(2)
                                }
                                .pickerStyle(.automatic)
                            }
                            NavigationLink{
                                ToggleNotiGenre()
                            } label: {
                                HStack {
                                    Image(systemName: "bell")
                                    Text("通知設定")
                                }
                            }
                            HStack {
                                Image(systemName: "globe")
                                Picker("言語", selection: $selectedLanguage) {
                                    ForEach(countries) { country in
                                        Text("\(country.symbol) \(country.desc)").tag(country.tagname)
                                    }
                                }
                                .pickerStyle(.automatic)
                            }
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("ログアウト")
                            }
                            .onTapGesture {
                                viewModel.signOut()
                            }
                        })

                        Section(header: Text("利用規約"), content: {
                            NavigationLink {
                                TermsWebViewScreen()
                            } label: {
                                HStack {
                                    Image(systemName: "doc.plaintext")
                                    Text("利用規約")
                                }
                            }
                            NavigationLink {
                                PrivacyPolicyWebViewScreen()
                            } label: {
                                HStack {
                                    Image(systemName: "character.book.closed.hi")
                                    Text("プライバシーポリシー")
                                }
                            }
                        })

                    }

            }

            /* Text("Your uid: \(String(describing: viewModel.uid!))")
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
            Spacer() */
        }
    }
}
