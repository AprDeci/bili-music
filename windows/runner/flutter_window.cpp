#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

namespace {
constexpr UINT kPreviousCommand = 1;
constexpr UINT kPlayPauseCommand = 2;
constexpr UINT kNextCommand = 3;
constexpr char kChannelName[] =
    "bilimusic/windows_taskbar_thumbnail_toolbar";
constexpr int kPreviousGlyph = 0;
constexpr int kPlayGlyph = 1;
constexpr int kPauseGlyph = 2;
constexpr int kNextGlyph = 3;

bool ReadBool(const flutter::EncodableMap& arguments, const char* key) {
  const auto iterator = arguments.find(flutter::EncodableValue(key));
  return iterator != arguments.end() &&
         std::holds_alternative<bool>(iterator->second) &&
         std::get<bool>(iterator->second);
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
  taskbar_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(), kChannelName,
          &flutter::StandardMethodCodec::GetInstance());
  taskbar_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                 result) {
        if (call.method_name() != "updatePlaybackState" ||
            !call.arguments() ||
            !std::holds_alternative<flutter::EncodableMap>(*call.arguments())) {
          result->NotImplemented();
          return;
        }
        const flutter::EncodableMap& arguments =
            std::get<flutter::EncodableMap>(*call.arguments());
        taskbar_is_playing_ = ReadBool(arguments, "isPlaying");
        taskbar_has_previous_ = ReadBool(arguments, "hasPrevious");
        taskbar_has_next_ = ReadBool(arguments, "hasNext");
        UpdateTaskbarThumbnailToolbar();
        result->Success();
      });
  InitializeTaskbarThumbnailToolbar();
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
  ReleaseTaskbarThumbnailToolbar();
  taskbar_channel_.reset();
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  if (message == taskbar_button_created_message_) {
    taskbar_toolbar_added_ = false;
    UpdateTaskbarThumbnailToolbar();
    return 0;
  }

  if (message == WM_COMMAND && HIWORD(wparam) == THBN_CLICKED &&
      HandleTaskbarThumbnailCommand(LOWORD(wparam))) {
    return 0;
  }

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

void FlutterWindow::InitializeTaskbarThumbnailToolbar() {
  taskbar_button_created_message_ =
      RegisterWindowMessage(L"TaskbarButtonCreated");
  const HRESULT result = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
  taskbar_com_initialized_ = SUCCEEDED(result);
  if (FAILED(CoCreateInstance(CLSID_TaskbarList, nullptr, CLSCTX_INPROC_SERVER,
                              IID_PPV_ARGS(&taskbar_list_))) ||
      FAILED(taskbar_list_->HrInit())) {
    taskbar_list_.Reset();
    return;
  }

  previous_icon_ = CreateMediaIcon(kPreviousGlyph);
  play_icon_ = CreateMediaIcon(kPlayGlyph);
  pause_icon_ = CreateMediaIcon(kPauseGlyph);
  next_icon_ = CreateMediaIcon(kNextGlyph);
}

void FlutterWindow::UpdateTaskbarThumbnailToolbar() {
  if (!taskbar_list_) {
    return;
  }

  THUMBBUTTON buttons[3] = {};
  buttons[0].dwMask = THB_FLAGS | THB_ICON | THB_TOOLTIP;
  buttons[0].iId = kPreviousCommand;
  buttons[0].hIcon = previous_icon_;
  buttons[0].dwFlags = taskbar_has_previous_ ? THBF_ENABLED : THBF_DISABLED;
  wcscpy_s(buttons[0].szTip, L"Previous");

  buttons[1].dwMask = THB_FLAGS | THB_ICON | THB_TOOLTIP;
  buttons[1].iId = kPlayPauseCommand;
  buttons[1].hIcon = taskbar_is_playing_ ? pause_icon_ : play_icon_;
  buttons[1].dwFlags = THBF_ENABLED;
  wcscpy_s(buttons[1].szTip, taskbar_is_playing_ ? L"Pause" : L"Play");

  buttons[2].dwMask = THB_FLAGS | THB_ICON | THB_TOOLTIP;
  buttons[2].iId = kNextCommand;
  buttons[2].hIcon = next_icon_;
  buttons[2].dwFlags = taskbar_has_next_ ? THBF_ENABLED : THBF_DISABLED;
  wcscpy_s(buttons[2].szTip, L"Next");

  if (!taskbar_toolbar_added_) {
    if (SUCCEEDED(taskbar_list_->ThumbBarAddButtons(GetHandle(), 3, buttons))) {
      taskbar_toolbar_added_ = true;
    }
    return;
  }
  taskbar_list_->ThumbBarUpdateButtons(GetHandle(), 3, buttons);
}

bool FlutterWindow::HandleTaskbarThumbnailCommand(WORD command) {
  switch (command) {
    case kPreviousCommand:
      SendTaskbarCommand("previous");
      return true;
    case kPlayPauseCommand:
      SendTaskbarCommand(taskbar_is_playing_ ? "pause" : "play");
      return true;
    case kNextCommand:
      SendTaskbarCommand("next");
      return true;
  }
  return false;
}

void FlutterWindow::SendTaskbarCommand(const char* command) {
  if (taskbar_channel_) {
    taskbar_channel_->InvokeMethod(
        "command", std::make_unique<flutter::EncodableValue>(command));
  }
}

HICON FlutterWindow::CreateMediaIcon(int glyph) {
  constexpr int kSize = 32;
  BITMAPV5HEADER header = {};
  header.bV5Size = sizeof(header);
  header.bV5Width = kSize;
  header.bV5Height = -kSize;
  header.bV5Planes = 1;
  header.bV5BitCount = 32;
  header.bV5Compression = BI_BITFIELDS;
  header.bV5RedMask = 0x00FF0000;
  header.bV5GreenMask = 0x0000FF00;
  header.bV5BlueMask = 0x000000FF;
  header.bV5AlphaMask = 0xFF000000;

  HDC screen = GetDC(nullptr);
  void* pixels = nullptr;
  HBITMAP color = CreateDIBSection(screen, reinterpret_cast<BITMAPINFO*>(&header),
                                   DIB_RGB_COLORS, &pixels, nullptr, 0);
  ReleaseDC(nullptr, screen);
  if (color == nullptr) {
    return nullptr;
  }

  HDC dc = CreateCompatibleDC(nullptr);
  HGDIOBJ previous = SelectObject(dc, color);
  RECT bounds = {0, 0, kSize, kSize};
  FillRect(dc, &bounds, static_cast<HBRUSH>(GetStockObject(BLACK_BRUSH)));
  SetBkMode(dc, TRANSPARENT);
  SetDCBrushColor(dc, RGB(255, 255, 255));
  SelectObject(dc, GetStockObject(DC_BRUSH));

  if (glyph == kPauseGlyph) {
    Rectangle(dc, 8, 7, 13, 25);
    Rectangle(dc, 19, 7, 24, 25);
  } else {
    const bool reverse = glyph == kPreviousGlyph;
    const POINT triangle[] = {
        {reverse ? 23 : 9, 6}, {reverse ? 9 : 23, 16}, {reverse ? 23 : 9, 26},
    };
    Polygon(dc, triangle, 3);
    if (glyph == kPreviousGlyph || glyph == kNextGlyph) {
      Rectangle(dc, reverse ? 6 : 23, 6, reverse ? 9 : 26, 26);
    }
  }

  auto* icon_pixels = static_cast<DWORD*>(pixels);
  for (int index = 0; index < kSize * kSize; ++index) {
    if ((icon_pixels[index] & 0x00FFFFFF) != 0) {
      icon_pixels[index] |= 0xFF000000;
    }
  }

  SelectObject(dc, previous);
  DeleteDC(dc);
  HBITMAP mask = CreateBitmap(kSize, kSize, 1, 1, nullptr);
  ICONINFO icon_info = {};
  icon_info.fIcon = TRUE;
  icon_info.hbmColor = color;
  icon_info.hbmMask = mask;
  HICON icon = CreateIconIndirect(&icon_info);
  DeleteObject(color);
  DeleteObject(mask);
  return icon;
}

void FlutterWindow::ReleaseTaskbarThumbnailToolbar() {
  for (HICON icon : {previous_icon_, play_icon_, pause_icon_, next_icon_}) {
    if (icon != nullptr) {
      DestroyIcon(icon);
    }
  }
  previous_icon_ = nullptr;
  play_icon_ = nullptr;
  pause_icon_ = nullptr;
  next_icon_ = nullptr;
  taskbar_list_.Reset();
  if (taskbar_com_initialized_) {
    CoUninitialize();
    taskbar_com_initialized_ = false;
  }
}
