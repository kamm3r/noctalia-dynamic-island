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
  property bool isMorphActive: false

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

  function resetMorphState() {
    root.isMorphActive = false
    if (morphOverlayLoader.item) {
      morphOverlayLoader.item.close()
    }
  }

  Component.onDestruction: {
    CavaService.unregisterComponent(cavaComponentId)
    if (morphOverlayLoader.item) {
      morphOverlayLoader.item.close()
    }
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

    opacity: root.isMorphActive ? 0 : 1

    Behavior on opacity {
      NumberAnimation {
        duration: 150
        easing.type: Easing.OutCubic
      }
    }

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

  Loader {
    id: morphOverlayLoader
    active: false
    sourceComponent: MorphOverlay {
      targetWidth: 360
      targetHeight: 280

      onCollapsed: {
        var popupWindow = PanelService.getPopupMenuWindow(root.screen)
        if (popupWindow) {
          popupWindow.close()
        }
      }
    }

    Connections {
      target: morphOverlayLoader.item
      ignoreUnknownSignals: true
      function onCollapsed() {
        root.isMorphActive = false
        var popupWindow = PanelService.getPopupMenuWindow(root.screen)
        if (popupWindow) {
          popupWindow.close()
        }
      }
      function onStateChanged() {
        if (morphOverlayLoader.item && morphOverlayLoader.item.state === "idle") {
          root.isMorphActive = false
        }
      }
    }

    function showMorph(startX, startY, startWidth, startHeight, targetX, targetY) {
      active = true
      Qt.callLater(() => {
        if (item) {
          item.targetX = targetX
          item.targetY = targetY
          item.expand(startX, startY, startWidth, startHeight)
        }
      })
    }

    function hideMorph() {
      if (item) {
        item.collapse()
      }
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: {
      if (root.isMorphActive) return

      root.isMorphActive = true

      var globalPos = visualCapsule.mapToItem(null, 0, 0)
      var barWindow = root.Window.window
      var windowPos = barWindow ? Qt.point(barWindow.x, barWindow.y) : Qt.point(0, 0)

      var screenStartX = windowPos.x + globalPos.x
      var screenStartY = windowPos.y + globalPos.y

      var targetX = screenStartX + (root.implicitWidth - 360) / 2
      var targetY = screenStartY + root.implicitHeight + 10

      var popupWindow = PanelService.getPopupMenuWindow(root.screen)
      if (popupWindow) {
        morphOverlayLoader.parent = popupWindow.dialogParent

        morphOverlayLoader.showMorph(
          screenStartX,
          screenStartY,
          root.implicitWidth,
          root.implicitHeight,
          targetX,
          targetY
        )

        popupWindow.open()
      }
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
