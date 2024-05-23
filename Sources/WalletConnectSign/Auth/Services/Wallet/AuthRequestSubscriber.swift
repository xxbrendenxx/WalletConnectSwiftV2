import Foundation
import Combine

class AuthRequestSubscriber {
    private let networkingInteractor: NetworkInteracting
    private let logger: ConsoleLogging
    private let kms: KeyManagementServiceProtocol
    private var publishers = [AnyCancellable]()
    private let walletErrorResponder: WalletErrorResponder
    private let pairingRegisterer: PairingRegisterer
    private let verifyClient: VerifyClientProtocol
    private let verifyContextStore: CodableStore<VerifyContext>
    private let pairingStore: WCPairingStorage

    var onRequest: (((request: AuthenticationRequest, context: VerifyContext?)) -> Void)?
    
    init(
        networkingInteractor: NetworkInteracting,
        logger: ConsoleLogging,
        kms: KeyManagementServiceProtocol,
        walletErrorResponder: WalletErrorResponder,
        pairingRegisterer: PairingRegisterer,
        verifyClient: VerifyClientProtocol,
        verifyContextStore: CodableStore<VerifyContext>,
        pairingStore: WCPairingStorage
    ) {
        self.networkingInteractor = networkingInteractor
        self.logger = logger
        self.kms = kms
        self.walletErrorResponder = walletErrorResponder
        self.pairingRegisterer = pairingRegisterer
        self.verifyClient = verifyClient
        self.verifyContextStore = verifyContextStore
        self.pairingStore = pairingStore
        subscribeForRequest()
    }

    private func subscribeForRequest() {
        pairingRegisterer.register(method: SessionAuthenticatedProtocolMethod.responseApprove())
            .sink { [unowned self] (payload: RequestSubscriptionPayload<SessionAuthenticateRequestParams>) in

                guard !payload.request.isExpired() else {
                    return respondError(payload: payload, reason: .sessionRequestExpired)
                }
                
                if var pairing = pairingStore.getPairing(forTopic: payload.topic) {
                    pairing.receivedRequest()
                    pairingStore.setPairing(pairing)
                }
                logger.debug("AuthRequestSubscriber: Received request")

                pairingRegisterer.setReceived(pairingTopic: payload.topic)

                let request = AuthenticationRequest(id: payload.id, topic: payload.topic, payload: payload.request.authPayload, requester: payload.request.requester.metadata)

                Task(priority: .high) {
                    let assertionId = payload.decryptedPayload.sha256().toHexString()
                    do {
                        let response = try await verifyClient.verifyOrigin(assertionId: assertionId)
                        let verifyContext = verifyClient.createVerifyContext(origin: response.origin, domain: payload.request.authPayload.domain, isScam: response.isScam)
                        verifyContextStore.set(verifyContext, forKey: request.id.string)
                        onRequest?((request, verifyContext))
                    } catch {
                        let verifyContext = verifyClient.createVerifyContext(origin: nil, domain: payload.request.authPayload.domain, isScam: nil)
                        verifyContextStore.set(verifyContext, forKey: request.id.string)
                        onRequest?((request, verifyContext))
                        return
                    }
                }
            }.store(in: &publishers)
    }

    func respondError(payload: SubscriptionPayload, reason: SignReasonCode) {
        Task(priority: .high) {
            do {
                try await networkingInteractor.respondError(
                    topic: payload.topic,
                    requestId: payload.id,
                    protocolMethod: SessionAuthenticatedProtocolMethod.responseApprove(),
                    reason: reason
                )
            } catch {
                logger.error("Respond Error failed with: \(error.localizedDescription)")
            }
        }
    }
}
