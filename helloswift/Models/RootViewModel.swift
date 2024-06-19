import SwiftUI
import Combine

class RootViewModel: ObservableObject {
    // 選択しているタブを保持するための変数
    @Published var selection = 1
    @Published var isActiveFirstPostEnqueteView = false

    var cancellable: AnyCancellable?
    
    init() {
        // プッシュ通知選択時に通知を受け取る
        cancellable = NotificationCenter.default
            .publisher(for: Notification.Name("didReceiveRemoteNotification"))
            .sink { _ in
                // 「ホーム」タブを表示する
                self.selection = 1
            }
    }
}
