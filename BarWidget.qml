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

  property var pluginApi: null
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""

  readonly property string screenName: screen?.name ?? ""
  readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
  readonly property bool isBarVertical: barPosition === "left" || barPosition === "right"
  readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)
  readonly property real barFontSize: Style.getBarFontSizeForScreen(screenName)

  readonly property var settings: pluginApi?.pluginSettings ?? {}
  readonly property real compactWidth: settings.compactWidth ?? 180
  readonly property int clearDelay: settings.clearDelay ?? 3000
  readonly property bool scrollTitle: settings.scrollTitle ?? true
  readonly property bool showVisualizer: settings.showVisualizer ?? true

  readonly property bool hasMedia: MediaService.currentPlayer !== null
  readonly property bool isPlaying: MediaService.isPlaying

  property bool showContent: true

  readonly property string cavaComponentId: "dynamic-island:" + screenName

  implicitWidth: compactWidth
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
    interval: root.clearDelay
    repeat: false
    onTriggered: {
      showContent = false
    }
  }

  onVisibleChanged: {
    if (visible && showVisualizer && (hasMedia || showContent)) {
      CavaService.registerComponent(cavaComponentId)
    } else {
      CavaService.unregisterComponent(cavaComponentId)
    }
  }

  Component.onDestruction: {
    CavaService.unregisterComponent(cavaComponentId)
  }

  Rectangle {
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
      showVisualizer: root.showVisualizer && root.isPlaying
      scrollTitle: root.scrollTitle
      hasMedia: root.hasMedia || root.showContent
      isPlaying: root.isPlaying
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: {
      pluginApi?.openPanel(root.screen, root)
    }
  }

  Behavior on opacity {
    NumberAnimation {
      duration: 300
      easing.type: Easing.InOutCubic
    }
  }

  Component.onCompleted: {
    Logger.i("DynamicIsland", "Widget loaded on screen:", screenName || "EMPTY")
  }
}
