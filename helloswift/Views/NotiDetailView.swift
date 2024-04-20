//
//  NotiDetailView.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/16.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct NotiDetailView: View {
    var viewModel: AuthViewModel
    var notificationId: String
    @State private var answeredCount: Double = 0
    @State private var totalUsers: Double = 0
    @State private var answeredUsers: [String] = []
    @State private var unAnsweredUsers: [String] = []

    @State var isLoading: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                            // Legend labels
                            LegendItem(label: "回答済みユーザ: \(Int(answeredCount)) 名", color: .blue)
                Text(answeredUsers.joined(separator: ", "))
                LegendItem(label: "未回答ユーザ: \(Int(totalUsers - answeredCount)) 名", color: .red)
                Text(unAnsweredUsers.joined(separator: ", "))
                        }
                        .padding(.leading, 10)
            PieView(answeredCount: answeredCount, totalUsers: totalUsers)
                .frame(width: 200, height: 200)
                .task {
                    do {
                        totalUsers = try await Firestore.firestore()
                            .collection("users")
                            .count
                            .getAggregation(source: .server)
                            .count
                            .doubleValue

                        answeredCount = try await Firestore.firestore()
                            .collection("reports")
                            .whereField("notificationId", isEqualTo: notificationId)
                            .count
                            .getAggregation(source: .server)
                            .count
                            .doubleValue
                        
                        let querySnapshots = try await Firestore.firestore()
                            .collection("reports")
                            .whereField("notificationId", isEqualTo: notificationId)
                            .getDocuments()
                        // Extract uids from the query snapshot
                        let answered = querySnapshots.documents.compactMap { $0.get("uid") as? String }

                        // Now, query "users" with given uids
                        // Query the "users" collection with the uids from answeredUsers
                        let userQuerySnapshot = try await Firestore.firestore()
                            .collection("users")
                            .whereField("uid", in: answered)
                            .getDocuments()

                        // Extract user data from the query snapshot
                        answeredUsers = userQuerySnapshot.documents.compactMap { (document: DocumentSnapshot) -> String? in
                            // Parse user data from the document
                            // Assuming your user document contains a field called "username"
                            guard let username = document.get("name") as? String else {
                                return nil // Skip this document if username is missing
                            }
                            
                            return username
                        }
                        
                        print("Users who answered: \(answeredUsers)")

                        // Query all documents from the "users" collection
                        let allUsersQuerySnapshot = try await Firestore.firestore()
                            .collection("users")
                            .getDocuments()

                        // Extract all uids from the query snapshot
                        let allUids = allUsersQuerySnapshot.documents.compactMap { document in
                            return document.get("uid") as? String
                        }
                        // Filter out the uids that are present in answeredUsers
/*                        let unansweredUids = allUids.filter { uid in
                            !answeredUsers.contains(uid)
                        } */
                        let unansweredUids: [String] = allUids.filter{ !answered.contains($0) }
                        print("unansweredUids: \(unansweredUids)")

                        // Query the "users" collection with the filtered uids
                        let unansweredUsersQuerySnapshot = try await Firestore.firestore()
                            .collection("users")
                            .whereField("uid", in: unansweredUids)
                            .getDocuments()

                        // Extract user data from the query snapshot
                        unAnsweredUsers = unansweredUsersQuerySnapshot.documents.compactMap { (document: DocumentSnapshot) -> String? in
                            // Parse user data from the document
                            // Assuming your user document contains a field called "username"
                            guard let username = document.get("name") as? String else {
                                return nil // Skip this document if username is missing
                            }
                            return username
                        }
                        
                        print("unAnsweredUsers: \(unAnsweredUsers)")

                    } catch {
                        print("error: \(error)")
                    }
                }
                .onAppear {
                    // Additional logic on appear if needed
                }

        }
    }
}

struct PieView: View {
    var answeredCount: Double
    var totalUsers: Double
    
    var body: some View {
        Canvas { context, size in
            let slices: [(Double, Color)] = [
                (answeredCount, .blue),
                (totalUsers - answeredCount, .red)
            ]
            
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

// LegendItem view to display a legend item with label and color
struct LegendItem: View {
    var label: String
    var color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
        }
        .padding(.vertical, 4)
    }
}
