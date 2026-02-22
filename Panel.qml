import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets
import qs.Services.Media
import qs.Services.UI

Item {
  id: root

  property var pluginApi: null

  readonly property bool allowAttach: true
  readonly property int contentPreferredWidth: 360
  readonly property int contentPreferredHeight: 280

  anchors.fill: parent

  opacity: 0

  Component.onCompleted: {
    fadeInTimer.start()
  }

  Timer {
    id: fadeInTimer
    interval: 50
    onTriggered: root.opacity = 1
  }

  Rectangle {
    id: contentItem
    anchors.fill: parent
    color: Color.mSurface
    radius: Style.radiusL
    border.color: Color.mOutline
    border.width: 1

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 20
      spacing: 16

      RowLayout {
        Layout.fillWidth: true
        spacing: 16

        Rectangle {
          id: albumArtPanel
          Layout.preferredWidth: 80
          Layout.preferredHeight: 80
          radius: 12
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

          Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "#20000000"
            visible: MediaService.trackArtUrl === ""

            NIcon {
              anchors.centerIn: parent
              icon: "music"
              color: Color.mOnSurfaceVariant
              pointSize: 28
            }
          }
        }

        ColumnLayout {
          Layout.fillWidth: true
          spacing: 4

          NText {
            text: MediaService.trackTitle || "Unknown"
            color: Color.mOnSurface
            pointSize: Style.fontSizeL
            font.weight: Font.DemiBold
            elide: Text.ElideRight
            Layout.fillWidth: true
          }

          NText {
            text: MediaService.trackArtist || "Unknown Artist"
            color: Color.mOnSurfaceVariant
            pointSize: Style.fontSizeM
            elide: Text.ElideRight
            Layout.fillWidth: true
          }

          NText {
            text: MediaService.trackAlbum || ""
            color: Color.mOnSurfaceVariant
            pointSize: Style.fontSizeS
            elide: Text.ElideRight
            Layout.fillWidth: true
            opacity: 0.7
            visible: text !== ""
          }
        }
      }

      Item {
        id: progressContainer
        Layout.fillWidth: true
        implicitHeight: 28

        property real position: MediaService.currentPosition
        property real duration: MediaService.trackLength
        readonly property real progress: duration > 0 ? Math.max(0, Math.min(1, position / duration)) : 0
        readonly property bool hasValidDuration: duration > 0 && position <= duration * 1.1

        function formatTime(sec) {
          if (sec < 0 || !isFinite(sec)) return "--:--"
          sec = Math.floor(sec)
          let h = Math.floor(sec / 3600)
          let m = Math.floor((sec % 3600) / 60)
          let s = sec % 60
          if (h > 0) {
            return h + ":" + (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s
          }
          return m + ":" + (s < 10 ? "0" : "") + s
        }

        Rectangle {
          id: progressBarBg
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width
          height: 4
          radius: 2
          color: Color.mSurfaceVariant
        }

        Rectangle {
          id: progressBarFill
          anchors.verticalCenter: parent.verticalCenter
          width: progressBarBg.width * parent.progress
          height: progressBarBg.height
          radius: progressBarBg.radius
          color: Color.mPrimary

          Behavior on width {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
          }
        }

        Rectangle {
          id: progressHandle
          anchors.verticalCenter: parent.verticalCenter
          x: Math.min(progressBarFill.width - width / 2, progressBarBg.width - width)
          width: 12
          height: 12
          radius: 6
          color: Color.mPrimary
          visible: parent.hasValidDuration && (progressMouseArea.containsMouse || progressMouseArea.pressed)
        }

        MouseArea {
          id: progressMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: parent.hasValidDuration ? Qt.PointingHandCursor : Qt.ArrowCursor
          enabled: parent.hasValidDuration

          function seekTo(mouseX) {
            if (!parent.hasValidDuration) return
            let ratio = Math.max(0, Math.min(1, mouseX / width))
            let newPos = parent.duration * ratio
            MediaService.setPosition(newPos)
          }

          onClicked: mouse => seekTo(mouse.x)
          onPositionChanged: mouse => {
            if (pressed) seekTo(mouse.x)
          }
        }
      }

      RowLayout {
        Layout.fillWidth: true

        function formatTime(sec) {
          if (sec < 0 || !isFinite(sec)) return "--:--"
          sec = Math.floor(sec)
          let h = Math.floor(sec / 3600)
          let m = Math.floor((sec % 3600) / 60)
          let s = sec % 60
          if (h > 0) {
            return h + ":" + (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s
          }
          return m + ":" + (s < 10 ? "0" : "") + s
        }

        NText {
          text: parent.formatTime(MediaService.currentPosition)
          color: Color.mOnSurfaceVariant
          pointSize: Style.fontSizeS
        }

        Item {
          Layout.fillWidth: true
        }

        NText {
          readonly property real remaining: MediaService.trackLength - MediaService.currentPosition
          text: MediaService.trackLength > 0 && remaining >= 0 ? "-" + parent.formatTime(remaining) : parent.formatTime(MediaService.trackLength)
          color: Color.mOnSurfaceVariant
          pointSize: Style.fontSizeS
        }
      }

      RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        spacing: 32

        NIconButton {
          icon: "player-skip-back"
          enabled: MediaService.canGoPrevious
          opacity: enabled ? 1 : 0.3
          baseSize: 36
          onClicked: MediaService.previous()
        }

        NIconButton {
          icon: MediaService.isPlaying ? "player-pause" : "player-play"
          enabled: MediaService.canPlay
          baseSize: 48
          colorBg: Color.mPrimary
          colorFg: Color.mOnPrimary
          colorBgHover: Color.mHover
          onClicked: MediaService.playPause()
        }

        NIconButton {
          icon: "player-skip-forward"
          enabled: MediaService.canGoNext
          opacity: enabled ? 1 : 0.3
          baseSize: 36
          onClicked: MediaService.next()
        }
      }
    }
  }

  Behavior on opacity {
    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
  }
}
