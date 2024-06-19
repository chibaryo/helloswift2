//
//  UserAdminScreen.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/05/15.
//

import SwiftUI

struct UserAdminScreen: View {
    var viewModel: AuthViewModel
    @State private var allUsers: [UserModel] = []
    @State private var osakaUsers: [UserModel] = []
    @State private var nagoyaUsers: [UserModel] = []
    @State private var tokyoUsers: [UserModel] = []

    var body: some View {
        VStack {
/*            HStack {
                Text("アドレス")
                Text("役職")
                Text("部署")
            } */
            Text("大阪")
            List {
                ForEach(osakaUsers) { user in
                    HStack {
                        Text(user.email)
                            .frame(width: 48, alignment: .leading)
                        Text(user.jobLevel)
                            .frame(width: 48, alignment: .leading)
                        Text(user.department)
                            .frame(width: 48, alignment: .leading)
                    }
                }
            }
            Text("名古屋")
            List {
                ForEach(nagoyaUsers) { user in
                    HStack {
                        Text(user.email)
                            .frame(width: 48, alignment: .leading)
                        Text(user.jobLevel)
                            .frame(width: 48, alignment: .leading)
                        Text(user.department)
                            .frame(width: 48, alignment: .leading)
                    }
                }
            }
            Text("東京")
            List {
                ForEach(tokyoUsers) { user in
                    HStack {
                        Text(user.email)
                            .frame(width: 48, alignment: .leading)
                        Text(user.jobLevel)
                            .frame(width: 48, alignment: .leading)
                        Text(user.department)
                            .frame(width: 48, alignment: .leading)
                    }
                }
            }
            //
/*            List {
                ForEach(allUsers, id: \.self.uid) { e in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(e.name)
                            Text(e.email)
                            Text(e.uid)
                            Text("\(e.isAdmin)")
                        }
                        .padding(.bottom, 1)
                    }
                }
            } */
        }
        .onAppear(perform: {
            fetchUsers()
        })
    }

    private func fetchUsers (){
        Task {
            do {
                print("Hewse")
                allUsers = try await UserViewModel.fetchUsers()
                osakaUsers = try await UserViewModel.fetchUsersByLocation(officeLocation: "大阪")
                nagoyaUsers = try await UserViewModel.fetchUsersByLocation(officeLocation: "名古屋")
                tokyoUsers = try await UserViewModel.fetchUsersByLocation(officeLocation: "東京")
            }
        }
    }
}

/*
#Preview {
    UserAdminScreen()
}
*/
