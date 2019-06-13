//
//  Process.swift
//  CKB
//
//  Created by 翟泉 on 2019/6/13.
//

import Foundation

extension Process {
    @discardableResult
    public static func launch(for shell: String, directory: URL? = nil) -> Process {
        let process = Process()
        if let directory = directory {
            process.currentDirectoryPath = directory.path
        }
        process.launchPath = "/bin/sh"
        process.arguments = ["-c", shell]
        process.launch()
        return process
    }
}
