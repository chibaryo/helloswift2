//
//  TermsWebViewScreen.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/09.
//

import Foundation
import SwiftUI
import WebKit

struct PrivacyPolicyWebViewScreen: View {
    var body: some View {
        WebView(loadUrl: URL(string: "https://chibaryo.github.io/anpi_report_ios/privacy/")!)
    }
}
