//
//  AboutView.swift
//  ncmDump
//
//  Created by DannielYu on 6/28/25.
//


import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
            
            Text("ncmdump GUI")
                .font(.title)
            
            Text("版本 1.0")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("为 ncmdump 命令行工具提供的图形界面")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Button("关闭") {
                dismiss()
            }
            .keyboardShortcut(.defaultAction)
        }
        .padding()
        .frame(width: 300, height: 300)
    }
}