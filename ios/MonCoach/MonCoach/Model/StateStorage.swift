import Foundation
import MonCoachKit

/// Reads and writes the app's state as a single JSON file.
///
/// One file rather than a database: the whole state is a few hundred
/// kilobytes at worst, it is trivially exportable, and a corrupt read costs
/// the athlete nothing more than an onboarding they can redo.
struct StateStorage {

    let url: URL

    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    static func applicationSupport(fileName: String = "mon-coach.json") -> StateStorage {
        let base = (try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )) ?? URL.temporaryDirectory
        return StateStorage(url: base.appending(path: fileName))
    }

    func load() -> PersistedState {
        guard let data = try? Data(contentsOf: url) else { return .empty }
        do {
            return try Self.decoder.decode(PersistedState.self, from: data)
        } catch {
            // A state file the current build cannot read is moved aside rather
            // than deleted: it may still be recoverable by hand, and silently
            // destroying someone's training history is unforgivable.
            let backup = url.deletingPathExtension().appendingPathExtension("corrupt.json")
            try? FileManager.default.removeItem(at: backup)
            try? FileManager.default.moveItem(at: url, to: backup)
            return .empty
        }
    }

    func save(_ state: PersistedState) throws {
        let data = try Self.encoder.encode(state)
        // Atomic: a crash mid-write leaves the previous state intact.
        try data.write(to: url, options: [.atomic])
    }
}
