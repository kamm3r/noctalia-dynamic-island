import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
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

  property bool isHovered: false
  property bool isMorphingOut: false
  property bool showContent: true

  readonly property string cavaComponentId: "dynamic-island:" + screenName

  readonly property real morphTargetWidth: 360
  readonly property real morphTargetHeight: 280

  implicitWidth: isMorphingOut ? morphTargetWidth : compactWidth
  implicitHeight: isMorphingOut ? morphTargetHeight : capsuleHeight

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

  Connections {
    target: pluginApi
    enabled: pluginApi !== null

    function onPanelOpenScreenChanged() {
      if (pluginApi.panelOpenScreen === null && root.isMorphingOut) {
        root.isMorphingOut = false
      }
    }
  }

  IslandShape {
    anchors.fill: parent
    islandWidth: root.implicitWidth
    islandHeight: root.implicitHeight
    fillColor: Color.mSurface
    borderColor: root.isHovered ? Color.mPrimary : Color.mOutline
    borderWidth: 1
  }

  Loader {
    id: contentLoader
    anchors.fill: parent
    anchors.leftMargin: 8
    anchors.rightMargin: 8
    active: hasMedia || showContent
    sourceComponent: mediaCompactComponent
  }

  Component {
    id: mediaCompactComponent
    MediaCompact {
      screen: root.screen
      barFontSize: root.barFontSize
      showVisualizer: root.showVisualizer && root.isPlaying
      scrollTitle: root.scrollTitle
      capsuleHeight: root.capsuleHeight
      hasMedia: root.hasMedia || root.showContent
      isPlaying: root.isPlaying
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onEntered: {
      root.isHovered = true
    }

    onExited: {
      root.isHovered = false
    }

    onClicked: {
      if (isMorphingOut) return
      
      root.isMorphingOut = true
      morphOutTimer.start()
    }
  }

  Timer {
    id: morphOutTimer
    interval: 300
    repeat: false
    onTriggered: {
      pluginApi?.openPanel(root.screen, root)
    }
  }

  Behavior on implicitWidth {
    enabled: root.visible || isMorphingOut
    NumberAnimation {
      duration: 300
      easing.type: Easing.Bezier
      easing.bezierCurve: [0.4, 0, 0.2, 1]
    }
  }

  Behavior on implicitHeight {
    enabled: root.visible || isMorphingOut
    NumberAnimation {
      duration: 300
      easing.type: Easing.Bezier
      easing.bezierCurve: [0.4, 0, 0.2, 1]
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
