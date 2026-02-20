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
  readonly property int expandedTimeout: settings.expandedTimeout ?? 5000
  readonly property bool showVisualizer: settings.showVisualizer ?? true

  readonly property bool hasMedia: MediaService.currentPlayer !== null
  readonly property bool isPlaying: MediaService.isPlaying

  property bool isHovered: false
  property bool isMorphingOut: false

  readonly property string cavaComponentId: "dynamic-island:" + screenName

  readonly property real morphTargetWidth: 360
  readonly property real morphTargetHeight: 280

  readonly property bool isHidden: !hasMedia || isMorphingOut

  implicitWidth: isMorphingOut ? morphTargetWidth : compactWidth
  implicitHeight: isMorphingOut ? morphTargetHeight : capsuleHeight

  visible: hasMedia
  opacity: isMorphingOut ? 0.0 : (isHidden ? 0.0 : 1.0)

  Layout.preferredWidth: visible ? implicitWidth : 0
  Layout.preferredHeight: implicitHeight

  onVisibleChanged: {
    if (visible && showVisualizer && hasMedia && !isMorphingOut) {
      CavaService.registerComponent(cavaComponentId)
    } else {
      CavaService.unregisterComponent(cavaComponentId)
    }
  }

  onHasMediaChanged: {
    if (hasMedia && visible && showVisualizer && !isMorphingOut) {
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
    anchors.leftMargin: 10
    anchors.rightMargin: 10
    active: hasMedia && !isMorphingOut
    sourceComponent: mediaCompactComponent
  }

  Component {
    id: mediaCompactComponent
    MediaCompact {
      screen: root.screen
      barFontSize: root.barFontSize
      showVisualizer: root.showVisualizer && root.isPlaying
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
      if (isMorphingOut || !hasMedia) return
      
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
      duration: 200
      easing.type: Easing.InOutCubic
    }
  }

  Component.onCompleted: {
    Logger.i("DynamicIsland", "Widget loaded on screen:", screenName || "EMPTY")
  }
}
