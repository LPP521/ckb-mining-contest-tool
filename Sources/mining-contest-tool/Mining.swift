//
//  Mining.swift
//  mining-contest-tool
//
//  Created by 翟泉 on 2019/6/11.
//

import Foundation

class Mining {
    let process = Process()

    init() {

    }

    func run() {
        process.currentDirectoryPath = "/Users/tekisen/Downloads/ckb_v0.12.0_darwin_amd64/ckb-testnet"
        process.launchPath = "/bin/sh"
        process.arguments = ["-c", "../ckb miner"]
        process.standardOutput = Pipe()
    }

    func check() -> Bool {

        return false
    }

    func readStandardOutput() -> String? {
        if let pipe = process.standardOutput as? Pipe {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let string = String(data: data, encoding: .ascii) {
                print(string)
                return string
            }
        }
        return nil
    }
}
