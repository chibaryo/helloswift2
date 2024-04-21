//
//  PaginationTest.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/21.
//

import SwiftUI

struct PaginationTest: View {
    private var a: [Int] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33]
    @State private var totalItems: Double = 0
    private var step:Double = 5
    @State private var totalPages: Int = 0
    @State private var currentPage: Int = 1
    //
    @State private var startFrom: Int = 0
    @State private var endAt: Int = 0
    //
    @State private var limitedArray: [Int] = []
    
    var body: some View {
        VStack {
            Text("\(self.limitedArray)")
            HStack {
                Button(action: {
                    if (self.currentPage > 1) {
                        self.currentPage -= 1
                        print("decremented: currentPage = \(self.currentPage)")
                        
                        calcPagination()
                    }
                }) {
                    Text("Prev")
                }
                .buttonStyle(.borderless)
                Button(action: {
                    if (self.currentPage < self.totalPages) {
                        self.currentPage += 1
                        print("incremented.")
                        
                        calcPagination()
                    }
                }) {
                    Text("Next")
                }
                .buttonStyle(.borderless)
            }
        }
        .onAppear(perform: {
            self.totalItems = Double(a.count)
            self.totalPages = Int(ceil(self.totalItems / step))
            //            print("totalItems: \()")
            //            print("double val: \(Double(self.totalItems / step))")
            print("totalPages: \(self.totalPages)")
            //
            calcPagination()
        })
        
    }
    private func calcPagination () {
        self.startFrom = Int(step) * (self.currentPage - 1) + 1
        if (totalPages == currentPage) {
            self.endAt = Int(totalItems)
        } else {
            self.endAt = self.currentPage * Int(step)
        }
       
        print("startFrom: \(self.startFrom)")
        print("endAt: \(self.endAt)")
        self.limitedArray = Array(a[(self.startFrom - 1)..<self.endAt])
        print("limitedArray: \(self.limitedArray)")
    }
}

/*#Preview {
    PaginationTest()
}*/
