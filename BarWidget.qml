import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.Media
import qs.Services.UI
import "Components"

Item {
  id: root

  // Injected properties
  property var pluginApi: null
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0

  // Settings access pattern — always use this fallback chain
  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})
  property real compactWidthVal: cfg.compactWidth ?? defaults.compactWidth ?? 180
  property int clearDelayVal: cfg.clearDelay ?? defaults.clearDelay ?? 3000
  property bool scrollTitleVal: cfg.scrollTitle ?? defaults.scrollTitle ?? true
  property bool showVisualizerVal: cfg.showVisualizer ?? defaults.showVisualizer ?? true

  readonly property string screenName: screen?.name ?? ""
  readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
  readonly property bool isBarVertical: barPosition === "left" || barPosition === "right"
  readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)
  readonly property real barFontSize: Style.getBarFontSizeForScreen(screenName)

  readonly property bool hasMedia: MediaService.currentPlayer !== null
  readonly property bool isPlaying: MediaService.isPlaying
  readonly property bool needsSpectrum: root.showVisualizerVal && root.isPlaying

  property bool showContent: true

  scale: 1.0

  readonly property string cavaComponentId: "dynamic-island:" + screenName

  implicitWidth: compactWidthVal
  implicitHeight: capsuleHeight

  visible: true
  opacity: (hasMedia || showContent) ? 1.0 : 0.3

  Layout.preferredWidth: implicitWidth
  Layout.preferredHeight: implicitHeight

  onHasMediaChanged: {
    if (!hasMedia) {
      clearDelayTimer.start()
    } else {
      clearDelayTimer.stop()
      showContent = true
    }
  }

  Timer {
    id: clearDelayTimer
    interval: root.clearDelayVal
    repeat: false
    onTriggered: {
      showContent = false
    }
  }

  onNeedsSpectrumChanged: {
    if (needsSpectrum) {
      SpectrumService.registerComponent(cavaComponentId)
    } else {
      SpectrumService.unregisterComponent(cavaComponentId)
    }
  }

  Component.onDestruction: {
    SpectrumService.unregisterComponent(cavaComponentId)
  }

  // Context menu (right-click)
  NPopupContextMenu {
    id: contextMenu
    model: [
      { "label": pluginApi?.tr("menu.settings"), "action": "settings", "icon": "settings" }
    ]
    onTriggered: action => {
      contextMenu.close();
      PanelService.closeContextMenu(screen);
      if (action === "settings") {
        BarService.openPluginSettings(screen, pluginApi.manifest);
      }
    }
  }

  NBox {
    id: visualCapsule
    width: root.implicitWidth
    height: root.implicitHeight
    x: Style.pixelAlignCenter(parent.width, width)
    y: Style.pixelAlignCenter(parent.height, height)

    radius: Style.radiusL
    color: Color.mSurface
    border.color: Color.mOutline
    border.width: Style.capsuleBorderWidth

    Loader {
      id: contentLoader
      anchors.fill: parent
      anchors.leftMargin: 10
      anchors.rightMargin: 10
      anchors.topMargin: 4
      anchors.bottomMargin: 4
      active: hasMedia || showContent
      sourceComponent: mediaCompactComponent
    }
  }

  Component {
    id: mediaCompactComponent
    MediaCompact {
      screen: root.screen
      barFontSize: root.barFontSize
      showVisualizer: root.showVisualizerVal && root.isPlaying
      scrollTitle: root.scrollTitleVal
      hasMedia: root.hasMedia || root.showContent
      isPlaying: root.isPlaying
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onPressed: {
      if (mouse.button === Qt.LeftButton) {
        root.scale = 0.97
      }
    }
    onReleased: {
      root.scale = 1.0
    }
    onClicked: mouse => {
      if (mouse.button === Qt.LeftButton) {
        pluginApi?.openPanel(root.screen, root)
      } else if (mouse.button === Qt.RightButton) {
        PanelService.showContextMenu(contextMenu, root, screen);
      }
    }
  }

  Behavior on opacity {
    NumberAnimation {
      duration: 300
      easing.type: Easing.InOutCubic
    }
  }

  Behavior on scale {
    NumberAnimation {
      duration: 150
      easing.type: Easing.OutCubic
    }
  }

  Component.onCompleted: {
    if (needsSpectrum) {
      SpectrumService.registerComponent(cavaComponentId)
    }
    Logger.i("DynamicIsland", "Widget loaded on screen:", screenName || "EMPTY")
  }
}
