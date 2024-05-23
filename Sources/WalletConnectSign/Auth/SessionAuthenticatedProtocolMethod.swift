import Foundation

struct SessionAuthenticatedProtocolMethod: ProtocolMethod {
    let method: String = "wc_sessionAuthenticate"

    let requestConfig = RelayConfig(
        tag: .sessionAuthenticate,
        prompt: true,
        ttl: 3600
    )

    let responseConfig: RelayConfig

    static let defaultTtl: TimeInterval = 3600
    
    private let ttl: Int
    
    private init(
        ttl: TimeInterval,
        responseTag: Tag
    ) {
        self.ttl = Int(ttl)
        self.responseConfig = RelayConfig(
            tag: responseTag,
            prompt: false,
            ttl: 3600
        )
    }
    
    static func responseApprove(ttl: TimeInterval = Self.defaultTtl) -> Self {
        Self(ttl: ttl, responseTag: .sessionAuthenticateResponseApprove)
    }
    
    static func responseReject(ttl: TimeInterval = Self.defaultTtl) -> Self {
        Self(ttl: ttl, responseTag: .sessionAuthenticateResponseReject)
    }
    
    static func responseAutoReject(ttl: TimeInterval = Self.defaultTtl) -> Self {
        Self(ttl: ttl, responseTag: .sessionAuthenticateResponseAutoReject)
    }
}
