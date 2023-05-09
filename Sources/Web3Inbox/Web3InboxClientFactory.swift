import Foundation
import WebKit

final class Web3InboxClientFactory {

    static func create(
        chatClient: ChatClient,
        pushClient: WalletPushClient,
        account: Account,
        config: [ConfigParam: Bool],
        onSign: @escaping SigningCallback
    ) -> Web3InboxClient {
        let url = buildUrl(account: account, config: config)
        let logger = ConsoleLogger(suffix: "📬")
        let chatWebviewSubscriber = WebViewRequestSubscriber(logger: logger)
        let pushWebviewSubscriber = WebViewRequestSubscriber(logger: logger)
        let webView = WebViewFactory(url: url, chatWebviewSubscriber: chatWebviewSubscriber, pushWebviewSubscriber: pushWebviewSubscriber).create()
        let chatWebViewProxy = WebViewProxy(webView: webView, scriptFormatter: ChatWebViewScriptFormatter())
        let pushWebViewProxy = WebViewProxy(webView: webView, scriptFormatter: PushWebViewScriptFormatter())

        let clientProxy = ChatClientProxy(client: chatClient, onSign: onSign)
        let clientSubscriber = ChatClientRequestSubscriber(chatClient: chatClient, logger: logger)

        let pushClientProxy = PushClientProxy(client: pushClient, onSign: onSign)
        let pushClientSubscriber = PushClientRequestSubscriber(client: pushClient, logger: logger)

        return Web3InboxClient(
            webView: webView,
            account: account,
            logger: ConsoleLogger(),
            chatClientProxy: clientProxy,
            clientSubscriber: clientSubscriber,
            chatWebviewProxy: chatWebViewProxy,
            pushWebviewProxy: pushWebViewProxy,
            chatWebviewSubscriber: chatWebviewSubscriber,
            pushWebviewSubscriber: pushWebviewSubscriber,
            pushClientProxy: pushClientProxy,
            pushClientSubscriber: pushClientSubscriber
        )
    }

    private static func buildUrl(account: Account, config: [ConfigParam: Bool]) -> URL {
        var urlComponents = URLComponents(string: "https://web3inbox-dev-hidden.vercel.app/")!
        let defaultQueryItems = [URLQueryItem(name: "chatProvider", value: "ios"), URLQueryItem(name: "pushProvider", value: "ios")]
        let accountQueryItem = URLQueryItem(name: "account", value: account.address)
        var queryItems = [URLQueryItem]()
        queryItems.append(accountQueryItem)
        queryItems.append(contentsOf: defaultQueryItems)

        for param in config.filter({ $0.value == false}) {
            queryItems.append(URLQueryItem(name: "\(param.key)", value: "false"))
        }
        urlComponents.queryItems = queryItems
        print(urlComponents.url!.absoluteString)
        return urlComponents.url!
    }
}
