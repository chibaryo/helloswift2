//
//  TermsWebViewScreen.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/09.
//

import Foundation
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let loadUrl: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: loadUrl)
        uiView.load(request)
    }
}

struct TermsWebViewScreen: View {
    var body: some View {
        WebView(loadUrl: URL(string: "https://chibaryo.github.io/anpi_report_ios/terms/")!)
    }
}
