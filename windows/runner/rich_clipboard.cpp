#include "rich_clipboard.h"

#include <flutter/standard_method_codec.h>

#include <cstring>
#include <string>
#include <vector>

namespace {

// Confie un bloc mémoire au presse-papier (qui en devient propriétaire).
bool SetClipboardBytes(UINT format, const void* data, size_t size) {
  HGLOBAL memory = GlobalAlloc(GMEM_MOVEABLE, size);
  if (!memory) {
    return false;
  }
  void* target = GlobalLock(memory);
  if (!target) {
    GlobalFree(memory);
    return false;
  }
  std::memcpy(target, data, size);
  GlobalUnlock(memory);
  if (!SetClipboardData(format, memory)) {
    GlobalFree(memory);
    return false;
  }
  return true;
}

std::wstring Utf8ToWide(const std::string& text) {
  if (text.empty()) {
    return std::wstring();
  }
  const int length = MultiByteToWideChar(CP_UTF8, 0, text.data(),
                                         static_cast<int>(text.size()), nullptr, 0);
  std::wstring wide(length, L'\0');
  MultiByteToWideChar(CP_UTF8, 0, text.data(), static_cast<int>(text.size()),
                      wide.data(), length);
  return wide;
}

}  // namespace

std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
CreateRichClipboardChannel(flutter::BinaryMessenger* messenger, HWND window) {
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      messenger, "elan/clipboard", &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
      [window](const flutter::MethodCall<flutter::EncodableValue>& call,
               std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() != "setRich") {
          result->NotImplemented();
          return;
        }
        const auto* args = std::get_if<flutter::EncodableMap>(call.arguments());
        if (!args) {
          result->Error("ARGUMENT", "Arguments manquants");
          return;
        }
        const auto html_entry = args->find(flutter::EncodableValue("html"));
        const auto text_entry = args->find(flutter::EncodableValue("text"));
        if (html_entry == args->end() || text_entry == args->end()) {
          result->Error("ARGUMENT", "html et text sont attendus");
          return;
        }
        const auto* html = std::get_if<std::vector<uint8_t>>(&html_entry->second);
        const auto* text = std::get_if<std::string>(&text_entry->second);
        if (!html || !text) {
          result->Error("ARGUMENT", "Types inattendus");
          return;
        }

        // CF_HTML : octets UTF-8 terminés par un zéro ; texte brut : UTF-16 terminé par un zéro.
        std::vector<uint8_t> html_bytes(*html);
        html_bytes.push_back(0);
        const std::wstring wide = Utf8ToWide(*text);

        if (!OpenClipboard(window)) {
          result->Error("CLIPBOARD", "Presse-papier occupé");
          return;
        }
        EmptyClipboard();
        const UINT html_format = RegisterClipboardFormatW(L"HTML Format");
        const bool ok =
            SetClipboardBytes(html_format, html_bytes.data(), html_bytes.size()) &&
            SetClipboardBytes(CF_UNICODETEXT, wide.c_str(),
                              (wide.size() + 1) * sizeof(wchar_t));
        CloseClipboard();

        if (ok) {
          result->Success();
        } else {
          result->Error("CLIPBOARD", "Copie impossible");
        }
      });
  return channel;
}
