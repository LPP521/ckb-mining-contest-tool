//
//  MiningManager.swift
//  mining-contest-tool
//
//  Created by 翟泉 on 2019/6/11.
//

import Foundation

class MiningManager {
    private(set) var minerProcess = [Process]()
    private(set) var ckbProcess: Process?
    private(set) var key: Key!

    let directory: URL
    let output: URL
    let workshopFolder: String
    let minerSavePath: URL

    init(directory: URL) {
        self.directory = directory
        output = directory.appendingPathComponent("mining_log.txt")
        workshopFolder = "ckb-testnet"
        minerSavePath = directory.appendingPathComponent("keys.txt")
    }

    func run() {
        guard FileManager.default.fileExists(atPath: directory.appendingPathComponent("ckb").path) else {
            fatalError("error")
        }

        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: directory.appendingPathComponent(workshopFolder).path, isDirectory: &isDirectory) || !isDirectory.boolValue {
            Process.launch(for: "./ckb init -C ckb-testnet --spec testnet", directory: directory).waitUntilExit()
        }

        setupMiner()
        runCKB()
        runMiner()

        DispatchQueue.global().async {
            self.checkMiningOutput()
        }
    }

    func stop() {
        stopMiner()
        stopCKB()
        try? FileManager.default.removeItem(at: self.output)
    }

    func checkMiningOutput() {
        Thread.sleep(forTimeInterval: 4)

        /// Read standard output
        if let output = try? String(contentsOf: output, encoding: .utf8) {
            if output.contains("found seal:") {
                print("success")
                recordMiner()
                stop()
                run()
                return
            }
        }

        DispatchQueue.global().async {
            self.checkMiningOutput()
        }
    }
}

/// Config
extension MiningManager {
    func setupMiner(miner: Key = Key.random()) {
        let config = directory.appendingPathComponent(workshopFolder).appendingPathComponent("ckb.toml")
        guard let text = try? String(contentsOfFile: config.path, encoding: .utf8) else {
            fatalError("error-2")
        }
        self.key = miner
        print(key.encode())

        var replace = false
        var lines = text.components(separatedBy: "\n")
        for (idx, item) in lines.enumerated() {
            if item.hasPrefix("[block_assembler]") {
                lines.removeSubrange(idx+1..<lines.count)
                lines.append("code_hash = \"\(miner.codeHash)\"")
                lines.append("args = [\"\(miner.publicKeyHash)\"]")
                replace = true
                break
            }
        }

        if !replace {
            lines.append("[block_assembler]")
            lines.append("code_hash = \"\(miner.codeHash)\"")
            lines.append("args = [\"\(miner.publicKeyHash)\"]")
        }

        try? lines.reduce("") { $0 + $1 + "\n" }.write(toFile: config.path, atomically: true, encoding: .utf8)
    }
}

/// Run CKB
extension MiningManager {
    func runCKB() {
        let shell = "../ckb run >> \(directory.appendingPathComponent("ckb_log.txt").path)"
        ckbProcess = Process.launch(for: shell, directory: directory.appendingPathComponent(workshopFolder))

        Thread.sleep(forTimeInterval: 4)
    }

    func stopCKB() {
        ckbProcess?.terminate()
        ckbProcess?.waitUntilExit()
        ckbProcess = nil

        Thread.sleep(forTimeInterval: 4)
    }

    func runMiner() {
        let count = 2
        for _ in 0..<count {
            let shell = "../ckb miner >> \(output.path)"
            let process = Process.launch(for: shell, directory: directory.appendingPathComponent(workshopFolder))
            minerProcess.append(process)
        }
    }

    func stopMiner() {
        minerProcess.forEach {
            $0.terminate()
            $0.waitUntilExit()
        }
        minerProcess.removeAll()

        Thread.sleep(forTimeInterval: 4)
    }
}

extension MiningManager {
    func recordMiner() {
        let text = key.encode()
        if !FileManager.default.fileExists(atPath: minerSavePath.path) {
            FileManager.default.createFile(atPath: minerSavePath.path, contents: nil, attributes: nil)
        }
        guard let handler = try? FileHandle(forWritingTo: minerSavePath) else { return }
        handler.seekToEndOfFile()
        handler.write(text.data(using: .utf8)!)
        handler.write("\n".data(using: .utf8)!)
    }
}
