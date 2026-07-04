#include "flutter_window.h"

#include <memory>
#include <optional>
#include <variant>
#include <vector>

#include "flutter/generated_plugin_registrant.h"
#include "desktop_multi_window/desktop_multi_window_plugin.h"
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

namespace {

std::vector<
    std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>>
    g_desktop_lyrics_channels;

bool ReadBoolArgument(const flutter::EncodableValue* argument,
                      bool fallback = false) {
  if (argument == nullptr || !std::holds_alternative<bool>(*argument)) {
    return fallback;
  }
  return std::get<bool>(*argument);
}

double ReadDoubleArgument(const flutter::EncodableValue* argument,
                          double fallback = 1.0) {
  if (argument == nullptr) {
    return fallback;
  }
  if (std::holds_alternative<double>(*argument)) {
    return std::get<double>(*argument);
  }
  if (std::holds_alternative<int32_t>(*argument)) {
    return static_cast<double>(std::get<int32_t>(*argument));
  }
  if (std::holds_alternative<int64_t>(*argument)) {
    return static_cast<double>(std::get<int64_t>(*argument));
  }
  return fallback;
}

void SetWindowAlwaysOnTop(HWND window, bool always_on_top) {
  SetWindowPos(window, always_on_top ? HWND_TOPMOST : HWND_NOTOPMOST, 0, 0, 0,
               0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
}

void SetWindowOpacity(HWND window, double opacity) {
  const double clamped_opacity =
      opacity < 0.2 ? 0.2 : (opacity > 1.0 ? 1.0 : opacity);
  LONG_PTR ex_style = GetWindowLongPtr(window, GWL_EXSTYLE);
  SetWindowLongPtr(window, GWL_EXSTYLE, ex_style | WS_EX_LAYERED);
  SetLayeredWindowAttributes(
      window, 0, static_cast<BYTE>(clamped_opacity * 255), LWA_ALPHA);
}

void RegisterDesktopLyricsWindowChannel(
    flutter::FlutterViewController* flutter_view_controller, HWND window) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_view_controller->engine()->messenger(),
          "bilimusic/desktop_lyrics_window",
          &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
      [window](const flutter::MethodCall<flutter::EncodableValue>& call,
               std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                   result) {
        const std::string& method_name = call.method_name();
        if (method_name == "startDragging") {
          ReleaseCapture();
          SendMessage(window, WM_NCLBUTTONDOWN, HTCAPTION, 0);
          result->Success();
          return;
        }
        if (method_name == "setAlwaysOnTop") {
          SetWindowAlwaysOnTop(window, ReadBoolArgument(call.arguments()));
          result->Success();
          return;
        }
        if (method_name == "setOpacity") {
          SetWindowOpacity(window, ReadDoubleArgument(call.arguments()));
          result->Success();
          return;
        }
        result->NotImplemented();
      });

  g_desktop_lyrics_channels.push_back(std::move(channel));
}

void ConfigureSubWindowChrome(void *controller) {
  auto *flutter_view_controller =
      reinterpret_cast<flutter::FlutterViewController *>(controller);
  HWND flutter_view = flutter_view_controller->view()->GetNativeWindow();
  HWND window = GetParent(flutter_view);
  if (window == nullptr) {
    return;
  }

  LONG_PTR style = GetWindowLongPtr(window, GWL_STYLE);
  style &= ~(WS_CAPTION | WS_THICKFRAME | WS_MINIMIZEBOX |
             WS_MAXIMIZEBOX | WS_SYSMENU);
  SetWindowLongPtr(window, GWL_STYLE, style);

  RECT frame;
  GetClientRect(window, &frame);
  MoveWindow(flutter_view, 0, 0, frame.right - frame.left,
             frame.bottom - frame.top, TRUE);
  SetWindowPos(window, nullptr, 0, 0, 0, 0,
               SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER |
                   SWP_NOACTIVATE | SWP_FRAMECHANGED);
  RegisterDesktopLyricsWindowChannel(flutter_view_controller, window);
}

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  DesktopMultiWindowSetWindowCreatedCallback(ConfigureSubWindowChrome);
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
