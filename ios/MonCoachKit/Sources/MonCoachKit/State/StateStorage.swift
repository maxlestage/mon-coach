import Foundation

/// Reads and writes the app's state as a single JSON file.
///
/// One file rather than a database: the whole state is a few hundred
/// kilobytes at worst, it is trivially exportable, and a corrupt read costs
/// the athlete nothing more than an onboarding they can redo.
public struct StateStorage: Sendable {

    public let url: URL

    public init(url: URL) { self.url = url }

    public static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        DateCoding.apply(to: encoder)
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    public static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        DateCoding.apply(to: decoder)
        return decoder
    }()

    public static func applicationSupport(fileName: String = "mon-coach.json") -> StateStorage {
        let base = (try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )) ?? URL.temporaryDirectory
        return StateStorage(url: base.appending(path: fileName))
    }

    public func load() -> PersistedState {
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

    public func save(_ state: PersistedState) throws {
        let data = try Self.encoder.encode(state)
        // Atomic: a crash mid-write leaves the previous state intact.
        try data.write(to: url, options: [.atomic])
    }
}
