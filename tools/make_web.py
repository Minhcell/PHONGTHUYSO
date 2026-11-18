"""Tạo bản web offline (PWA) từ app/index.html vào thư mục dist-web/. Dùng trong GitHub Actions."""
import os, re, shutil, sys
ver = sys.argv[1] if len(sys.argv) > 1 else "dev"
src = open("app/index.html", encoding="utf-8").read()
head = """<link rel="manifest" href="manifest.webmanifest">
<meta name="theme-color" content="#9e1b1b">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="default">
<meta name="apple-mobile-web-app-title" content="Phong Thủy Số">
<link rel="apple-touch-icon" href="icons/apple-touch-icon.png">
"""
reg = """<script>if ("serviceWorker" in navigator && /^https?:$/.test(location.protocol)) { window.addEventListener("load", () => navigator.serviceWorker.register("sw.js").catch(()=>{})); }</script>
"""
assert "</head>" in src and "</body>" in src
out = src.replace("</head>", head + "</head>", 1)
i = out.rfind("</body>"); out = out[:i] + reg + out[i:]
if os.path.exists("dist-web"): shutil.rmtree("dist-web")
shutil.copytree("web", "dist-web")
open("dist-web/index.html", "w", encoding="utf-8").write(out)
sw = open("dist-web/sw.js", encoding="utf-8").read().replace("__VERSION__", ver)
open("dist-web/sw.js", "w", encoding="utf-8").write(sw)
print("OK dist-web", ver)
