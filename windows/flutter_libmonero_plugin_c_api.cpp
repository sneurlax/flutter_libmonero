#include "include/flutter_libmonero/flutter_libmonero_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_libmonero_plugin.h"

void FlutterLibmoneroPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_libmonero::FlutterLibmoneroPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
