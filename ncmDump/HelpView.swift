//
//  HelpView.swift
//  ncmDump
//
//  Created by DannielYu on 6/28/25.
//


import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("ncmdump GUI 使用帮助")
                    .font(.title)
                    .padding(.bottom, 10)
                
                Group {
                    Text("1. 选择输入").font(.headline)
                    Text("可以选择单个文件或整个文件夹进行处理")
                    
                    Text("2. 输出设置").font(.headline)
                    Text("可选设置输出目录，留空则使用输入文件所在目录")
                    
                    Text("3. 递归处理").font(.headline)
                    Text("当选择文件夹时，可以启用递归处理子文件夹")
                    
                    Text("4. 命令行参数对应").font(.headline)
                    Text("-d, --directory: 选择文件夹时自动使用")
                    Text("-r, --recursive: 递归处理选项")
                    Text("-o, --output: 设置输出目录时使用")
                }
                
                Spacer()
                
                Button("关闭") {
                    dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 400, height: 400)
    }
}