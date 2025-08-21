open class ThrowableCheck: CheckProtocol {
    open var status: CheckStatus = .notLaunchedYet
    open var debugInformation: String = ""
    open var name: String?

    public func performCheck() async -> CheckStatus {
        status = .inProgress

        do {
            try await performThrowableCheck()

        } catch {
            debugInformation = error.localizedDescription
            status = .failed
        }
        return status
    }
    
    open func performThrowableCheck() async throws {
        fatalError("add implementation")
    }

}
