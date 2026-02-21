import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.Media

Item {
  id: root

  property var screen
  property real barFontSize: 12
  property bool showVisualizer: false
  property bool scrollTitle: true
  property bool hasMedia: false
  property bool isPlaying: false

  anchors.fill: parent

  readonly property real artSize: Math.round(height * 0.85)
  readonly property real visualizerWidth: 24

  RowLayout {
    anchors.fill: parent
    spacing: 8

    Rectangle {
      id: albumArt
      Layout.preferredWidth: root.artSize
      Layout.preferredHeight: root.artSize
      Layout.alignment: Qt.AlignVCenter
      radius: Math.round(root.artSize * 0.22)
      color: Color.mSurfaceVariant
      clip: true

      NImageRounded {
        anchors.fill: parent
        visible: MediaService.trackArtUrl !== ""
        imagePath: MediaService.trackArtUrl
        radius: parent.radius
        borderWidth: 0
        imageFillMode: Image.PreserveAspectCrop
      }
    }

    Item {
      Layout.fillWidth: true
      Layout.preferredHeight: parent.height
      Layout.alignment: Qt.AlignVCenter
      clip: true

      NScrollText {
        id: scrollTitle
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: parent.height

        text: MediaService.trackTitle || "Unknown"
        scrollMode: root.scrollTitle ? NScrollText.ScrollMode.Always : NScrollText.ScrollMode.Never
        maxWidth: width
        gradientColor: Color.mSurface
        gradientWidth: 6
        waitBeforeScrolling: 2000
        scrollCycleDuration: Math.max(10000, text.length * 150)

        NText {
          color: Color.mOnSurface
          pointSize: root.barFontSize
          font.weight: Font.Medium
          elide: Text.ElideNone
        }
      }
    }

    Item {
      Layout.preferredWidth: root.visualizerWidth
      Layout.preferredHeight: root.artSize
      Layout.alignment: Qt.AlignVCenter

      IslandVisualizer {
        anchors.centerIn: parent
        running: root.showVisualizer && root.isPlaying
        barColor: Color.mPrimary
        maxBarHeight: root.artSize - 6
        visible: root.showVisualizer
      }

      Rectangle {
        width: 6
        height: 6
        radius: 3
        color: Color.mPrimary
        visible: !root.showVisualizer && root.isPlaying
        anchors.centerIn: parent

        SequentialAnimation on opacity {
          running: parent.visible
          loops: Animation.Infinite
          NumberAnimation { to: 0.4; duration: 800; easing.type: Easing.InOutSine }
          NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutSine }
        }
      }
    }
  }
}
