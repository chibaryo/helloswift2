//
//  StaticTable.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/21.
//

import SwiftUI

struct StaticTable: View {
    @State var notiTemplates: [NotiTemplateModel] = []
    @State var isLoading: Bool = false

    var body: some View {
        Table (notiTemplates) {
            TableColumn("title") { template in
                Text(template.notiTitle)
            }
            TableColumn("body") { template in
                Text(template.notiTitle)
            }
        }
/*        VStack {
        }*/
        .onAppear(perform: {
            fetch()
        })
    }
    private func fetch () {
        Task {
            do {
                isLoading.toggle()
                notiTemplates = try await NotiTemplateViewModel.fetchNotiTemplates()
                isLoading.toggle()
                
//                debugPrint(notifications)
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
    }
}

#Preview {
    StaticTable()
}
