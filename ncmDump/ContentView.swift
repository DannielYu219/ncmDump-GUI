//
//  ContentView.swift
//  ncmDump
//
//  Created by DannielYu on 6/28/25.
//

import SwiftUI

struct ContentView: View {
    @State private var inputPath: String = ""
    @State private var outputPath: String = ""
    @State private var isRecursive: Bool = false
    @State private var isProcessing: Bool = false
    @State private var progress: Double = 0
    @State private var resultMessage: String = ""
    @State private var showResultAlert: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 标题
            Text("ncmdump GUI")
                .font(.largeTitle)
                .padding(.bottom, 20)
                .fontWeight(.thin)
            
            // 输入文件/文件夹选择
            VStack{
                HStack{
                    Text("输入")
                        .font(.title)
                        .fontWeight(.thin)
                Spacer()
                }
                HStack {
                    TextField("选择文件或文件夹", text: $inputPath)
                        .disabled(true)
                        .font(.title2)
                    
                    Button(action:{
                        selectInputFile()
                    }){
                        ZStack{
                            Text("选择文件")
                                .font(.title2)
                                .padding(.vertical,2)
                                .fontWeight(.thin)
                        }
                    }
                    
                    Button(action:{
                        selectInputFolder()
                    }){
                        ZStack{
                            Text("选择文件夹")
                                .font(.title2)
                                .padding(.vertical,2)
                                .fontWeight(.thin)
                        }
                    }
                }
            }
            
            // 递归处理选项
            if !inputPath.isEmpty && FileManager.default.isDirectory(atPath: inputPath) {
                Toggle("递归处理子文件夹", isOn: $isRecursive)
            }
            
            // 输出目录选择
            VStack{
                HStack{
                    Text("输入")
                        .font(.title)
                        .fontWeight(.thin)
                Spacer()
                }
                HStack {
                    TextField("输出文件夹（默认为输入文件夹）", text: $inputPath)
                        .disabled(true)
                        .font(.title2)
                    
                    Button(action:{
                        selectOutputFolder()
                    }){
                        ZStack{
                            Text("选择输出文件夹")
                                .font(.title2)
                                .padding(.vertical,2)
                                .fontWeight(.thin)
                        }
                    }
                    
                    Button(action:{
                        outputPath = inputPath
                    }){
                        ZStack{
                            Text("默认")
                                .font(.title2)
                                .padding(.vertical,2)
                                .fontWeight(.thin)
                        }
                    }
                }
            }
            
            // 执行按钮
            HStack {
                Spacer()
                
                if isProcessing {
                    ProgressView(value: progress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(width: 200)
                } else {
                    Button(action:{
                        executeCommand()
                    }){
                        ZStack{
                            Text("开始处理")
                                .font(.title2)
                                .padding(.vertical,2)
                        }
                    }
                    .disabled(inputPath.isEmpty)
                    .keyboardShortcut(.defaultAction)
                }
                
                Spacer()
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        .frame(minWidth: 500, minHeight: 300)
        .alert("处理结果", isPresented: $showResultAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(resultMessage)
        }
    }
    
    // 选择输入文件
    private func selectInputFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedFileTypes = ["ncm"] // 可根据需要添加其他类型
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                _ = url.startAccessingSecurityScopedResource()
                inputPath = url.path
                print("已选择输入文件: \(inputPath)")
            }
        }
    }
    
    // 选择输入文件夹
    private func selectInputFolder() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.resolvesAliases = true
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                _ = url.startAccessingSecurityScopedResource()
                inputPath = url.path
                print("已选择输入文件夹: \(inputPath)")
            }
        }
    }
    
    // 选择输出文件夹
    private func selectOutputFolder() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.prompt = "选择输出文件夹"
        panel.message = "请选择转换后文件的输出目录"
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                _ = url.startAccessingSecurityScopedResource()
                outputPath = url.path
                print("已选择输出文件夹: \(outputPath)")
            }
        }
    }
    
    private func executeCommand() {
        isProcessing = true
        progress = 0
        
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        
        // 获取 bundle 中的 ncmdump 路径
        guard let executablePath = Bundle.main.path(forResource: "ncmdump", ofType: nil) else {
            resultMessage = "错误: 找不到 ncmdump 可执行文件"
            showResultAlert = true
            isProcessing = false
            return
        }
        
        task.launchPath = executablePath
        
        // 构建命令参数
        var arguments = [String]()
        
        if FileManager.default.isDirectory(atPath: inputPath) {
            arguments.append(contentsOf: ["-d", inputPath])
            if isRecursive {
                arguments.append("-r")
            }
        } else {
            // 单个文件处理
            arguments.append(inputPath)
        }
        
        if !outputPath.isEmpty {
            arguments.append(contentsOf: ["-o", outputPath])
        }
        
        task.arguments = arguments
        
        // 处理完成回调
        DispatchQueue.global().async {
            do {
                try task.run()
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""
                
                DispatchQueue.main.async {
                    isProcessing = false
                    progress = 1.0
                    resultMessage = output.isEmpty ? "处理完成" : output
                    showResultAlert = true
                    
                    // 释放安全作用域资源
                    if !self.inputPath.isEmpty {
                        URL(fileURLWithPath: self.inputPath).stopAccessingSecurityScopedResource()
                    }
                    if !self.outputPath.isEmpty {
                        URL(fileURLWithPath: self.outputPath).stopAccessingSecurityScopedResource()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    isProcessing = false
                    resultMessage = "处理失败: \(error.localizedDescription)"
                    showResultAlert = true
                }
            }
        }
    }
}

extension FileManager {
    func isDirectory(atPath path: String) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
}

#Preview {
    ContentView()
}
