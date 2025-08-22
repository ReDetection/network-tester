open class ThrowableCheck: CheckProtocol {
    open var status: CheckStatus = .notLaunchedYet
    public var debugInformation: String { debugBreadcrumbs.joined(separator: "\n")}
    open var debugBreadcrumbs: [String] = []

    open var name: String?

    public func performCheck() async -> CheckStatus {
        status = .inProgress

        do {
            try await performThrowableCheck()

        } catch {
            debugBreadcrumbs.append(error.localizedDescription)
            status = .failed
        }
        return status
    }
    
    open func performThrowableCheck() async throws {
        fatalError("add implementation")
    }

}
