import Foundation

print("Hello, world!")

guard let CKB_DIR = ProcessInfo.processInfo.environment[""] else {
    print("Error: No environment parameter \"CKB_DIR\".")
    exit(-1)
}

print("CKB_DIR: \(CKB_DIR)")

var isDirectory: ObjCBool = false
guard FileManager.default.fileExists(atPath: CKB_DIR, isDirectory: &isDirectory) && isDirectory.boolValue else {
    print("Error: Invalid environment parameter \"CKB_DIR\".")
    exit(-1)
}

let manager = MiningManager(directory: URL(fileURLWithPath: CKB_DIR, isDirectory: true))
manager.run()

while true {
    print("Enter 'q' to exit:")
    let keyboard = FileHandle.standardInput
    let inputData = keyboard.availableData
    let strData = String(data: inputData, encoding: String.Encoding.utf8)!
    let input = strData.trimmingCharacters(in: CharacterSet.newlines)
    if input.hasPrefix("q") || input.hasPrefix("Q") {
        manager.stop()
        exit(0)
    }
}

//Thread.sleep(until: .distantFuture)
