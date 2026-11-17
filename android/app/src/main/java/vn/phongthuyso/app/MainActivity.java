package vn.phongthuyso.app;

import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.ContentValues;
import android.content.Context;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.webkit.JavascriptInterface;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;

public class MainActivity extends Activity {
    private WebView web;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        web = new WebView(this);
        setContentView(web);
        WebSettings s = web.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);          // lưu mật khẩu sử dụng (localStorage)
        s.setDatabaseEnabled(true);
        s.setAllowFileAccess(true);
        s.setLoadWithOverviewMode(true);
        s.setUseWideViewPort(true);
        s.setTextZoom(100);
        web.setWebViewClient(new WebViewClient());
        web.setWebChromeClient(new WebChromeClient());
        web.addJavascriptInterface(new Bridge(this), "AndroidBridge");
        if (savedInstanceState != null) web.restoreState(savedInstanceState);
        else web.loadUrl("file:///android_asset/index.html");
    }

    @Override
    protected void onSaveInstanceState(Bundle out) { super.onSaveInstanceState(out); web.saveState(out); }

    @Override
    public void onBackPressed() { if (web.canGoBack()) web.goBack(); else super.onBackPressed(); }

    public class Bridge {
        private final Context ctx;
        Bridge(Context c) { ctx = c; }

        /** Lưu báo cáo Word (.doc) vào thư mục Download */
        @JavascriptInterface
        public String saveDoc(String name, String content) {
            try {
                byte[] data = content.getBytes(StandardCharsets.UTF_8);
                if (Build.VERSION.SDK_INT >= 29) {
                    ContentValues v = new ContentValues();
                    v.put(MediaStore.Downloads.DISPLAY_NAME, name);
                    v.put(MediaStore.Downloads.MIME_TYPE, "application/msword");
                    v.put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS);
                    Uri uri = ctx.getContentResolver().insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, v);
                    if (uri == null) throw new Exception("Không tạo được file");
                    try (OutputStream os = ctx.getContentResolver().openOutputStream(uri)) { os.write(data); }
                } else {
                    File dir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
                    if (!dir.exists()) dir.mkdirs();
                    File f = new File(dir, name);
                    if (Build.VERSION.SDK_INT >= 23 && checkSelfPermission(android.Manifest.permission.WRITE_EXTERNAL_STORAGE) != android.content.pm.PackageManager.PERMISSION_GRANTED) {
                        requestPermissions(new String[]{android.Manifest.permission.WRITE_EXTERNAL_STORAGE}, 1);
                        File own = new File(ctx.getExternalFilesDir(null), name);
                        try (FileOutputStream os = new FileOutputStream(own)) { os.write(data); }
                        return "Đã lưu " + own.getAbsolutePath();
                    }
                    try (FileOutputStream os = new FileOutputStream(f)) { os.write(data); }
                }
                final String msg = "Đã lưu " + name + " vào thư mục Download";
                runOnUiThread(() -> Toast.makeText(ctx, msg, Toast.LENGTH_LONG).show());
                return msg;
            } catch (Exception e) {
                return "Không lưu được file: " + e.getMessage();
            }
        }

        /** Sao chép báo cáo (HTML + chữ) để dán vào Word / WPS */
        @JavascriptInterface
        public void copyHtml(String html, String text) {
            runOnUiThread(() -> {
                ClipboardManager cm = (ClipboardManager) ctx.getSystemService(Context.CLIPBOARD_SERVICE);
                cm.setPrimaryClip(ClipData.newHtmlText("Bao cao", text, html));
                Toast.makeText(ctx, "Đã sao chép báo cáo", Toast.LENGTH_SHORT).show();
            });
        }
    }
}
