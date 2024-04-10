//
//  UpdateTemplateButton.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/10.
//

import Foundation
import SwiftUI
/*
struct UpdateTemplateButton: View {
    @State private var presentEditAlert: Bool = false
    @State private var inputNotiTitle: String = ""
    @State private var inputNotiBody: String = ""
    @State private var currentDocId: String = ""
    @State var user: UserModel?
    @State var notitemplate: NotiTemplateModel?

    var body: some View {
        Button(action: {
            self.currentDocId = e.id!
            self.inputNotiTitle = e.notiTitle
            self.inputNotiBody = e.notiBody
            presentEditAlert = true
        }){
            VStack {
                Image(systemName: "square.and.pencil")
            }
        }
        .alert("テンプレート登録", isPresented: $presentEditAlert) {
            TextField("タイトル", text: $inputNotiTitle)
            TextField("本文", text: $inputNotiBody)

            Button("保存", action: {
                Task {
                    do {
                        //presentEditAlert = false
                        let doc = NotiTemplateModel(
                            notiTitle: inputNotiTitle,
                            notiBody: inputNotiBody
                        )
                        try NotiTemplateViewModel.updateNotiTemplate(currentDocId, document: doc)
                        // Clear form
                        self.inputNotiTitle = ""
                        self.inputNotiBody = ""
                    }
                }
            })
            Button("キャンセル", action: {})
        } message: {
            Text("保存するテンプレートを登録してください")
        }

    }
}
*/
