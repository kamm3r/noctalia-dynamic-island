import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.Media

Item {
  id: root
  property var pluginApi: null

  // IPC handler for CLI control (qs ipc call plugin:dynamic-island commandName)
  IpcHandler {
    target: "plugin:dynamic-island"

    function toggle() {
      if (pluginApi) {
        pluginApi.withCurrentScreen(screen => {
          pluginApi.togglePanel(screen);
        });
      }
    }

    function playPause() {
      MediaService.playPause();
    }

    function next() {
      MediaService.next();
    }

    function previous() {
      MediaService.previous();
    }
  }
}
