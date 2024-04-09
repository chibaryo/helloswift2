//
//  ContentView.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/08.
//

import SwiftUI

struct ContentView: View {
    @State var str = "Hello, SwiftUI"
    
    @State var platformInfos: [DBPlatformInfoModel] = []
    @State var isLoading: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                List(platformInfos) { platformInfo in
                    HStack {
                        Text(platformInfo.systemName)
                        Spacer()
                    }
                }
            }
        }
        .onAppear(perform: {
            fetch()
        })
        VStack {
            HStack {
                Rectangle()
                    .foregroundColor(.purple)
                    .frame(height: 50)
            }
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            VStack {
                Text("AAA")
                Text("BBB")
                Text("CCC")
            }
            HStack {
                ZStack {
                    Rectangle()
                        .foregroundColor(.white)
                        .frame(height: 200)
                    Image("20231203-95-scaled")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .shadow(radius: 10)
                        .cornerRadius(10.0)
                        .padding()
                }
            }
            HStack {
                ZStack {
                    Rectangle()
                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/.opacity(0.3))
                        .frame(width: 100, height: 100)
                    Image(systemName: "house")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                ZStack {
                    Rectangle()
                        .foregroundColor(.purple.opacity(0.3))
                        .frame(width: 100, height: 100)
                    Image(systemName: "person")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                ZStack {
                    Rectangle()
                        .foregroundColor(.green.opacity(0.3))
                        .frame(width: 100, height: 100)
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }
            Text(str) // str
            Button {
                str = "Bonjour!"
                print("Pressed!")
            } label: {
                Text(str)
            }
        }
        .padding()
        
    }

    private func fetch () {
        Task {
            do {
                isLoading.toggle()
                platformInfos = try await APIClient.fetchPlatformInfo()
                isLoading.toggle()
                
                debugPrint(platformInfos)
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
    }

}


#Preview {
    ContentView()
}
