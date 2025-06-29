//
//  ncmDumpApp.swift
//  ncmDump
//
//  Created by DannielYu on 6/28/25.
//

import SwiftUI

@main
struct ncmdump_GUIApp: App {
    @State private var showAbout = false
    @State private var showHelp = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button("关于") { showAbout = true }
                            Button("帮助") { showHelp = true }
                        } label: {
                            Label("更多", systemImage: "ellipsis.circle")
                        }
                    }
                }
                .sheet(isPresented: $showAbout) {
                    AboutView()
                }
                .sheet(isPresented: $showHelp) {
                    HelpView()
                }
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("关于 ncmdump GUI") {
                    showAbout = true
                }
            }
            CommandGroup(replacing: .help) {
                Button("ncmdump GUI 帮助") {
                    showHelp = true
                }
            }
        }
    }
}
