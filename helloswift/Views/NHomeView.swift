import SwiftUI

struct NHomeView: View {
    @EnvironmentObject var firstPostEnqueteViewModel: FirstPostEnqueteViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text("nav list")
/*                NavigationLink(
                    destination: FirstPostEnquete(),
                    isActive: .constant(firstPostEnqueteViewModel.isActiveFirstPostEnqueteView),
                    label: {
                        EmptyView()
                    }
                )
*/
                Text("Home")
            }
            .navigationTitle("HOME")
        }
    }
}
