//
//  Key.swift
//  mining-contest-tool
//
//  Created by 翟泉 on 2019/6/11.
//

import Foundation
import CKB

struct Key {
    let privateKey: String
    let address: String
    let codeHash: String
    let publicKeyHash: String
}

extension Key {
    static func random() -> Key {
        let privateKey = "0x" + generatePrivateKey()
        let publicKey = Utils.privateToPublic(privateKey)
        let address = AddressGenerator(network: .testnet).address(for: publicKey)
        let publicKeyHash = "0x" + AddressGenerator(network: .testnet).hash(for: Data(hex: publicKey)).toHexString()
        return Key(
            privateKey: privateKey,
            address: address,
            codeHash: "0x9e3b3557f11b2b3532ce352bfe8017e9fd11d154c4c7f9b7aaaa1e621b539a08",
            publicKeyHash: publicKeyHash
        )
    }
}

extension Key {
    public static func generatePrivateKey() -> String {
        var data = Data(repeating: 0, count: 32)
        #if os(OSX)
        data.withUnsafeMutableBytes({ _ = SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress! ) })
        #else
        for idx in 0..<32 {
            data[idx] = UInt8.random(in: UInt8.min...UInt8.max)
        }
        #endif
        return data.toHexString()
    }
}

extension Key {
    func encode() -> String {
        return "\(privateKey) \(address) \(codeHash) \(publicKeyHash)"
    }

    static func decode(for string: String) -> Key? {
        let items = string.components(separatedBy: " ")
        guard items.count == 4 else { return nil }
        return Key(privateKey: items[0], address: items[1], codeHash: items[2], publicKeyHash: items[3])
    }
}
