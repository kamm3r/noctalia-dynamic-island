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

  anchors.fill: parent

  readonly property real artSize: Math.min(28, parent.height - 8)

  RowLayout {
    anchors.fill: parent
    spacing: 8

    Rectangle {
      id: albumArtContainer
      Layout.preferredWidth: root.artSize
      Layout.preferredHeight: root.artSize
      Layout.alignment: Qt.AlignVCenter
      radius: 6
      color: "transparent"
      clip: true

      Rectangle {
        anchors.fill: parent
        anchors.margins: -1
        radius: 7
        color: Color.mSurfaceVariant
        visible: MediaService.trackArtUrl === ""
      }

      NImageRounded {
        anchors.fill: parent
        visible: MediaService.trackArtUrl !== ""
        imagePath: MediaService.trackArtUrl
        radius: 6
        borderWidth: 0
        imageFillMode: Image.PreserveAspectCrop
      }

      Rectangle {
        anchors.fill: parent
        radius: 6
        color: "#000000"
        opacity: 0.3
        visible: MediaService.trackArtUrl !== "" && !MediaService.isPlaying

        NIcon {
          anchors.centerIn: parent
          icon: "player-pause"
          color: "#FFFFFF"
          pointSize: 10
        }
      }
    }

    Item {
      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.alignment: Qt.AlignVCenter

      NText {
        id: titleText
        text: MediaService.trackTitle || "Unknown"
        color: Color.mOnSurface
        pointSize: root.barFontSize
        font.weight: Font.Medium
        elide: Text.ElideRight
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: root.showVisualizer ? 36 : 0
      }
    }

    Item {
      Layout.preferredWidth: 28
      Layout.preferredHeight: 20
      Layout.alignment: Qt.AlignVCenter
      visible: root.showVisualizer

      IslandVisualizer {
        anchors.centerIn: parent
        running: root.showVisualizer && MediaService.isPlaying
        barColor: Color.mPrimary
        maxBarHeight: 14
      }
    }

    Rectangle {
      Layout.preferredWidth: 6
      Layout.preferredHeight: 6
      Layout.alignment: Qt.AlignVCenter
      radius: 3
      color: Color.mPrimary
      visible: !root.showVisualizer && MediaService.isPlaying

      SequentialAnimation on opacity {
        running: parent.visible
        loops: Animation.Infinite
        NumberAnimation {
          to: 0.4
          duration: 800
          easing.type: Easing.InOutSine
        }
        NumberAnimation {
          to: 1.0
          duration: 800
          easing.type: Easing.InOutSine
        }
      }
    }
  }
}
