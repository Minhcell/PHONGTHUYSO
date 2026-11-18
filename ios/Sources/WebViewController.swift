import UIKit
import WebKit

/// Hiển thị app (www/index.html) offline trong WKWebView.
/// Cung cấp window.AndroidBridge giống bản Android để lưu file Word và sao chép báo cáo.
class WebViewController: UIViewController, WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate {
    private var web: WKWebView!

    override func loadView() {
        let uc = WKUserContentController()
        let bridge = """
        window.AndroidBridge = {
          saveDoc: function (name, content) {
            window.webkit.messageHandlers.saveDoc.postMessage({ name: name, content: content });
            return "Đã tạo file " + name + " – chọn nơi lưu (Tệp, Zalo, Mail…)";
          },
          copyHtml: function (html, text) {
            window.webkit.messageHandlers.copyHtml.postMessage({ html: html, text: text });
          }
        };
        """
        uc.addUserScript(WKUserScript(source: bridge, injectionTime: .atDocumentStart, forMainFrameOnly: true))
        uc.add(self, name: "saveDoc")
        uc.add(self, name: "copyHtml")

        let cfg = WKWebViewConfiguration()
        cfg.userContentController = uc
        cfg.websiteDataStore = WKWebsiteDataStore.default() // lưu mật khẩu sử dụng (localStorage) lâu dài

        web = WKWebView(frame: .zero, configuration: cfg)
        web.uiDelegate = self
        web.navigationDelegate = self
        web.allowsBackForwardNavigationGestures = false
        web.scrollView.contentInsetAdjustmentBehavior = .automatic
        view = web
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "www") {
            web.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }

    // MARK: - Cầu nối JS → iOS
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any] else { return }
        if message.name == "saveDoc" {
            let name = (body["name"] as? String) ?? "BaoCao.doc"
            let content = (body["content"] as? String) ?? ""
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
            do {
                try content.data(using: .utf8)?.write(to: url, options: .atomic)
                let share = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                if let pop = share.popoverPresentationController { // iPad
                    pop.sourceView = view
                    pop.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
                    pop.permittedArrowDirections = []
                }
                present(share, animated: true)
            } catch {
                alert("Không lưu được file: \(error.localizedDescription)")
            }
        } else if message.name == "copyHtml" {
            let html = (body["html"] as? String) ?? ""
            let text = (body["text"] as? String) ?? ""
            UIPasteboard.general.items = [["public.html": html, "public.utf8-plain-text": text]]
            alert("Đã sao chép báo cáo. Mở Word/WPS và dán.")
        }
    }

    // MARK: - Hộp thoại JavaScript
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let a = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
        present(a, animated: true)
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let a = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "Hủy", style: .cancel) { _ in completionHandler(false) })
        a.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler(true) })
        present(a, animated: true)
    }

    // Liên kết ngoài mở bằng Safari
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let u = navigationAction.request.url, let s = u.scheme, s == "http" || s == "https" {
            UIApplication.shared.open(u)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    private func alert(_ msg: String) {
        let a = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}
