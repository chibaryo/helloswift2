//
//  ReportAdminScreen.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/16.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ReportAdminScreen: View {
    var viewModel: AuthViewModel
    @State var slices: [(Double, Color)]
    
    @State var reports: [ReportModel] = []
    @State var isLoading: Bool = false
    // Firestore listener
    @State private var listener: ListenerRegistration?

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(reports, id: \.id) { e in
                        VStack(alignment: .leading) {
                            HStack {
                                if let createdAt = e.createdAt {
                                    Text("\(createdAt.dateValue(), format: .dateTime.month(.defaultDigits).day()) ")
                                } else {
//                                    Text("Date unknown: \(e.notiTitle)")
                                }
                                Spacer()
                            }
                        }
                    }
                }
        }
        .onAppear(perform: {
            fetch()
            listenForUpdates()
        })
        .onDisappear(perform: {
                    // Stop listening for updates when the view disappears
                    listener?.remove()
       })
    }

        Canvas { context, size in
            let total = slices.reduce(0) { $0 + $1.0 }
            context.translateBy(x: size.width * 0.5, y: size.height * 0.5)
            var pieContext = context
            pieContext.rotate(by: .degrees(-90))
            let radius = min(size.width, size.height) * 0.48
            var startAngle = Angle.zero
            for (value, color) in slices {
                let angle = Angle(degrees: 360 * (value / total))
                let endAngle = startAngle + angle
                let path = Path { p in
                    p.move(to: .zero)
                    p.addArc(center: .zero, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                    p.closeSubpath()
                }
                pieContext.fill(path, with: .color(color))
                
                startAngle = endAngle
            }
        }
        .aspectRatio(1, contentMode: .fit)

        .onAppear(perform: {
            fetch()
            //
            listenForUpdates()
        })
        .onDisappear(perform: {
                    // Stop listening for updates when the view disappears
                    listener?.remove()
       })
    }
    
    private func fetch () {
        Task {
            do {
                isLoading.toggle()
                reports = try await ReportViewModel.fetchReports()
                isLoading.toggle()
                
                debugPrint(reports)
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
    }

    private func listenForUpdates() {
            // Set up Firestore listener to observe changes in the collection
            listener = Firestore.firestore().collection("reports")
                .addSnapshotListener { snapshot, error in
                    guard let snapshot = snapshot else {
                        if let error = error {
                            print("Error fetching snapshots: \(error)")
                        }
                        return
                    }
                    
                    // Parse snapshot data into NotiTemplateModel objects
                    do {
                        let reports = try snapshot.documents.compactMap { try $0.data(as: ReportModel.self) }
                        self.reports = reports
                    } catch {
                        print("Error decoding snapshot: \(error)")
                    }
                }
        }
}

/*
struct PieChartView: View {
    let data: [(Double, Color)]
    
    var body: some View {
         Canvas { context, size in
            let total = slices.reduce(0) { $0 + $1.0 }
            context.translateBy(x: size.width * 0.5, y: size.height * 0.5)
            var pieContext = context
            pieContext.rotate(by: .degrees(-90))
            let radius = min(size.width, size.height) * 0.48
            var startAngle = Angle.zero
            for (value, color) in slices {
                let angle = Angle(degrees: 360 * (value / total))
                let endAngle = startAngle + angle
                let path = Path { p in
                    p.move(to: .zero)
                    p.addArc(center: .zero, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                    p.closeSubpath()
                }
                pieContext.fill(path, with: .color(color))
                startAngle = endAngle
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
*/
