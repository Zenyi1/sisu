import Foundation
import SwiftData

enum LSSign: Int, Codable {
    case negative = -1
    case positive = 1
}

@Model
final class LSEvent {
    var timestamp: Date
    var signRaw: Int
    var weight: Double
    var note: String

    var sign: LSSign { LSSign(rawValue: signRaw) ?? .positive }
    var signedWeight: Double { Double(sign.rawValue) * weight }

    init(timestamp: Date = Date(), sign: LSSign, weight: Double, note: String) {
        self.timestamp = timestamp
        self.signRaw = sign.rawValue
        self.weight = weight
        self.note = note
    }
}
