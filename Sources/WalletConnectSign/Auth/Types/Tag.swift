import Foundation

enum Tag: Int {
    case unsupportedMethod = 0

    case pairingDelete = 1000
    case pairingDeleteResponse = 1001

    case pairingPing = 1002
    case pairingPingResponse = 1003

    case sessionPropose = 1100
    case sessionProposeResponseApprove = 1101
    case sessionProposeResponseReject = 1120
    case sessionProposeResponseAutoReject = 1121

    case sessionSettle = 1102
    case sessionSettleResponse = 1103

    case sessionUpdate = 1104
    case sessionUpdateResponse = 1105

    case sessionExtend = 1106
    case sessionExtendResponse = 1107

    case sessionRequest = 1108
    case sessionRequestResponse = 1109

    case sessionEvent = 1110
    case sessionEventResponse = 1111

    case sessionDelete = 1112
    case sessionDeleteResponse = 1113

    case sessionPing = 1114
    case sessionPingResponse = 1115

    case sessionAuthenticate = 1116
    case sessionAuthenticateResponseApprove = 1117
    case sessionAuthenticateResponseReject = 1118
    case sessionAuthenticateResponseAutoReject = 1119

    case chatInvite = 2000
    case chatInviteResponse = 2001

    case chatMessage = 2002
    case chatMessageResponse = 2003

    case chatLeave = 2004
    case chatLeaveResponse = 2005

    case chatPing = 2006
    case chatPingResponse = 2007

    case authRequest = 3000
    case authRequestResponse = 3001

    case notifySubscribe = 4000
    case notifySubscribeResponse = 4001

    case notifyMessage = 4002
    case notifyMessageResponse = 4003

    case notifyDelete = 4004
    case notifyDeleteResponse = 4005

    case notifyUpdate = 4008
    case notifyUpdateResponse = 4009

    case notifyWatchSubscriptions = 4010
    case notifyWatchSubscriptionsResponse = 4011

    case notifySubscriptionsChanged = 4012
    case notifySubscriptionsChangedResponse = 4013

    case notifyGetNotifications = 4014
    case notifyGetNotificationsResponse = 4015
}


extension RelayConfig {
    
    init(tag: Tag, prompt: Bool, ttl: Int) {
        self.init(tag: tag.rawValue, prompt: prompt, ttl: ttl)
    }
}
