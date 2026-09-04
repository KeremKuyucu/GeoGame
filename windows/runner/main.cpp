#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <string>
#include <vector>

#include "flutter_window.h"
#include "utils.h"

#define APPLINK_MSG_ID (WM_USER + 2)

struct EnumState {
  DWORD current_pid = 0;
  HWND found_hwnd = nullptr;
};

// Check if another instance of GeoGame is running, forward the link and bring it to foreground
bool CheckAndForwardToExistingInstance() {
  EnumState state;
  state.current_pid = GetCurrentProcessId();

  EnumWindows([](HWND hwnd, LPARAM lparam) -> BOOL {
    auto* s = reinterpret_cast<EnumState*>(lparam);
    wchar_t class_name[64] = {};
    GetClassNameW(hwnd, class_name, 64);
    if (_wcsicmp(class_name, L"FLUTTER_RUNNER_WIN32_WINDOW") == 0) {
      DWORD pid = 0;
      GetWindowThreadProcessId(hwnd, &pid);
      if (pid != 0 && pid != s->current_pid) {
        HANDLE hProcess = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
        if (hProcess) {
          wchar_t exe_path[MAX_PATH] = {};
          DWORD len = MAX_PATH;
          if (QueryFullProcessImageNameW(hProcess, 0, exe_path, &len)) {
            if (wcsstr(exe_path, L"geogame.exe") != nullptr) {
              s->found_hwnd = hwnd;
              CloseHandle(hProcess);
              return FALSE;
            }
          }
          CloseHandle(hProcess);
        }
      }
    }
    return TRUE;
  }, reinterpret_cast<LPARAM>(&state));

  HWND target = state.found_hwnd;
  if (!target) {
    HWND w = FindWindowW(L"FLUTTER_RUNNER_WIN32_WINDOW", L"geogame");
    if (w) {
      DWORD pid = 0;
      GetWindowThreadProcessId(w, &pid);
      if (pid != state.current_pid) {
        target = w;
      }
    }
  }

  if (!target) {
    return false;
  }

  // Parse command line arguments for deep link
  int argc = 0;
  wchar_t** argv = CommandLineToArgvW(GetCommandLineW(), &argc);
  if (argv) {
    if (argc >= 2) {
      for (int i = 1; i < argc; ++i) {
        std::wstring arg = argv[i];
        if (arg.rfind(L"io.supabase.geogame:", 0) == 0 || arg.find(L"://") != std::wstring::npos) {
          int size_needed = WideCharToMultiByte(CP_UTF8, 0, arg.c_str(), -1, nullptr, 0, nullptr, nullptr);
          if (size_needed > 0) {
            std::string utf8_link(size_needed, 0);
            WideCharToMultiByte(CP_UTF8, 0, arg.c_str(), -1, &utf8_link[0], size_needed, nullptr, nullptr);

            COPYDATASTRUCT cds = {0};
            cds.dwData = APPLINK_MSG_ID;
            cds.cbData = static_cast<DWORD>(utf8_link.size() + 1);
            cds.lpData = const_cast<char*>(utf8_link.c_str());

            SendMessage(target, WM_COPYDATA, reinterpret_cast<WPARAM>(target), reinterpret_cast<LPARAM>(&cds));
            break;
          }
        }
      }
    }
    LocalFree(argv);
  }

  // Bring existing window to foreground smoothly
  if (IsIconic(target)) {
    ShowWindow(target, SW_RESTORE);
  } else {
    ShowWindow(target, SW_SHOW);
  }
  SetForegroundWindow(target);

  return true;
}

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // If an instance of this app is already running, forward the link to it and exit.
  if (CheckAndForwardToExistingInstance()) {
    return EXIT_SUCCESS;
  }

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"geogame", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
