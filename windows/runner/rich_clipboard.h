#ifndef RUNNER_RICH_CLIPBOARD_H_
#define RUNNER_RICH_CLIPBOARD_H_

#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <windows.h>

#include <memory>

// Canal "elan/clipboard" : copie un contenu à la fois en HTML (« HTML Format »,
// lu par Word, Excel, navigateurs) et en texte brut (CF_UNICODETEXT).
// Méthode "setRich" : { "html": octets CF_HTML (UTF-8), "text": texte brut }.
std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
CreateRichClipboardChannel(flutter::BinaryMessenger* messenger, HWND window);

#endif  // RUNNER_RICH_CLIPBOARD_H_
