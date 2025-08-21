import AsyncDNSResolver

final public class DNSResolverCheck: ThrowableCheck {
    let hostname: String

    public enum DNSError: Error {
        case emptyARecords
    }

    public init(hostname: String) {
        self.hostname = hostname
    }

    public override func performThrowableCheck() async throws {
        let resolver = try AsyncDNSResolver()

        // Run a query
        let aRecords = try await resolver.queryA(name: "apple.com")

        if aRecords.isEmpty {
            throw DNSError.emptyARecords
        }

        debugInformation = aRecords.map(\.address.address).joined(separator: "\n")
    }
}

