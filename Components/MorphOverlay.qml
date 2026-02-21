import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Services.Media
import qs.Widgets

Rectangle {
  id: root

  property string state: "idle"
  property real targetWidth: 360
  property real targetHeight: 280
  property real targetX: 0
  property real targetY: 0
  property color capsuleColor: Color.mSurface
  property color borderColor: Color.mOutline

  property real _startX: 0
  property real _startY: 0
  property real _startWidth: 180
  property real _startHeight: 32

  signal expanded()
  signal collapsed()

  visible: state !== "idle"
  z: 9999

  width: {
    if (state === "idle") return _startWidth
    if (state === "expanded") return targetWidth
    if (state === "collapsing") return _startWidth
    return targetWidth
  }
  height: {
    if (state === "idle") return _startHeight
    if (state === "expanded") return targetHeight
    if (state === "collapsing") return _startHeight
    return targetHeight
  }
  x: {
    if (state === "idle") return _startX
    if (state === "expanded") return targetX
    if (state === "collapsing") return _startX
    return targetX
  }
  y: {
    if (state === "idle") return _startY
    if (state === "expanded") return targetY
    if (state === "collapsing") return _startY
    return targetY
  }

  radius: Style.radiusL
  color: capsuleColor
  border.color: borderColor
  border.width: Style.capsuleBorderWidth

  opacity: state !== "idle" ? 1 : 0

  readonly property real progress: {
    if (state === "idle" || state === "collapsing") return 0
    if (state === "expanded") return 1
    let wProgress = (width - _startWidth) / Math.max(1, targetWidth - _startWidth)
    let hProgress = (height - _startHeight) / Math.max(1, targetHeight - _startHeight)
    return Math.min(wProgress, hProgress)
  }

  Behavior on width {
    enabled: state === "morphing" || state === "collapsing"
    NumberAnimation {
      duration: 300
      easing.type: Easing.Bezier
      easing.bezierCurve: [0.4, 0, 0.2, 1]
    }
  }

  Behavior on height {
    enabled: state === "morphing" || state === "collapsing"
    NumberAnimation {
      duration: 300
      easing.type: Easing.Bezier
      easing.bezierCurve: [0.4, 0, 0.2, 1]
    }
  }

  Behavior on x {
    enabled: state === "morphing" || state === "collapsing"
    NumberAnimation {
      duration: 300
      easing.type: Easing.Bezier
      easing.bezierCurve: [0.4, 0, 0.2, 1]
    }
  }

  Behavior on y {
    enabled: state === "morphing" || state === "collapsing"
    NumberAnimation {
      duration: 300
      easing.type: Easing.Bezier
      easing.bezierCurve: [0.4, 0, 0.2, 1]
    }
  }

  Behavior on opacity {
    NumberAnimation {
      duration: 150
      easing.type: Easing.OutCubic
    }
  }

  onProgressChanged: {
    if (state === "morphing" && progress >= 0.98) {
      state = "expanded"
      expanded()
    }
  }

  MouseArea {
    id: backgroundMouseArea
    anchors.fill: parent
    enabled: root.state === "expanded"
    hoverEnabled: false
    z: 0

    onClicked: mouse => {
      root.collapse()
      mouse.accepted = true
    }
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 20
    spacing: 16
    z: 1

    opacity: root.progress > 0.5 || root.state === "expanded" ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 100 }
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: 16

      Rectangle {
        id: albumArt
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
      Layout.fillWidth: true
      implicitHeight: 28

      property real position: MediaService.currentPosition
      property real duration: MediaService.trackLength

      function formatTime(sec) {
        sec = Math.floor(sec)
        let m = Math.floor(sec / 60)
        let s = sec % 60
        return m + ":" + (s < 10 ? "0" + s : s)
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
        width: progressBarBg.width * (parent.duration > 0 ? parent.position / parent.duration : 0)
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
        x: progressBarFill.width - width / 2
        width: 12
        height: 12
        radius: 6
        color: Color.mPrimary
        visible: progressMouseArea.containsMouse || progressMouseArea.pressed
      }

      MouseArea {
        id: progressMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        function seekTo(mouseX) {
          let ratio = Math.max(0, Math.min(1, mouseX / width))
          let newPos = parent.duration * ratio
          MediaService.setPosition(newPos)
        }

        onClicked: mouse => {
          seekTo(mouse.x)
          mouse.accepted = true
        }
        onPositionChanged: mouse => {
          if (pressed) seekTo(mouse.x)
        }
      }
    }

    RowLayout {
      Layout.fillWidth: true

      function formatTime(sec) {
        sec = Math.floor(sec)
        let m = Math.floor(sec / 60)
        let s = sec % 60
        return m + ":" + (s < 10 ? "0" + s : s)
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
        text: "-" + parent.formatTime(Math.max(MediaService.trackLength - MediaService.currentPosition, 0))
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

  Timer {
    id: collapseTimer
    interval: 300
    repeat: false
    onTriggered: {
      root.state = "idle"
      root.collapsed()
    }
  }

  function expand(startX, startY, startWidth, startHeight) {
    _startX = startX
    _startY = startY
    _startWidth = startWidth
    _startHeight = startHeight

    x = startX
    y = startY
    width = startWidth
    height = startHeight

    state = "morphing"
  }

  function collapse() {
    if (state === "idle" || state === "collapsing") return

    state = "collapsing"
    collapseTimer.start()
  }

  function close() {
    state = "idle"
    collapseTimer.stop()
  }
}
