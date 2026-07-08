public extension Analytics {
    typealias Parameters = [String: Value]

    enum Value: Equatable, Sendable {
        case string(String)
        case int(Int)
        case double(Double)
        case bool(Bool)
    }
}

extension Analytics.Parameters {
    func withReserved(_ reserved: Self) -> Self {
        merging(reserved) { _, reserved in reserved }
    }

    func withContext(_ context: Self) -> Self {
        context.merging(self) { _, value in value }
    }

    func prefixed(_ prefix: String) -> Self {
        reduce(into: Self()) { result, entry in
            result["\(prefix).\(entry.key)"] = entry.value
        }
    }
}
