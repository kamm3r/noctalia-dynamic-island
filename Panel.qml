import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets
import qs.Services.Media
import qs.Services.UI
import "Components"

Item {
    id: root

    property var pluginApi: null

    readonly property bool allowAttach: true
    readonly property int contentPreferredWidth: 367
    readonly property int contentPreferredHeight: 177

    readonly property bool showVisualizer: true
    readonly property bool isPlaying: MediaService.isPlaying

    readonly property string cavaComponentId: "dynamic-island-panel"

    anchors.fill: parent

    opacity: 0

    Component.onCompleted: {
        fadeInTimer.start();
        updateCavaRegistration();
    }

    Component.onDestruction: {
        CavaService.unregisterComponent(cavaComponentId)
    }

    function updateCavaRegistration() {
        if (root.showVisualizer && MediaService.trackLength > 0) {
            CavaService.registerComponent(cavaComponentId)
        } else {
            CavaService.unregisterComponent(cavaComponentId)
        }
    }

    onShowVisualizerChanged: updateCavaRegistration()
    onIsPlayingChanged: updateCavaRegistration()

    Timer {
        id: fadeInTimer
        interval: 50
        onTriggered: root.opacity = 1
    }

    Rectangle {
        id: contentItem
        anchors.fill: parent
        color: "transparent"
        border.width: 0

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    id: albumArtPanel
                    Layout.preferredWidth: 53
                    Layout.preferredHeight: 53
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

                    RowLayout {
                        Layout.fillWidth: true

                        NText {
                            text: MediaService.trackTitle || "Unknown"
                            color: Color.mOnSurface
                            pointSize: Style.fontSizeM
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        IslandVisualizer {
                            running: root.showVisualizer && root.isPlaying
                            barColor: Color.mPrimary
                            maxBarHeight: 14
                            visible: root.showVisualizer && root.isPlaying
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 18
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Rectangle {
                            width: 6
                            height: 6
                            radius: 3
                            color: Color.mPrimary
                            visible: !root.showVisualizer && root.isPlaying
                            Layout.alignment: Qt.AlignVCenter

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

                    NText {
                        text: MediaService.trackArtist || "Unknown Artist"
                        color: Color.mOnSurfaceVariant
                        pointSize: Style.fontSizeS
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
                Layout.fillHeight: true
                Layout.minimumHeight: 12
            }

            Item {
                id: progressContainer
                Layout.fillWidth: true
                implicitHeight: 14

                property real position: MediaService.currentPosition
                property real duration: MediaService.trackLength
                readonly property bool hasDuration: duration > 0
                readonly property real progress: hasDuration ? Math.max(0, Math.min(1, position / duration)) : 0
                readonly property bool hasValidDuration: hasDuration && position <= duration * 1.1

                function formatTime(sec) {
                    if (sec < 0 || !isFinite(sec))
                        return "--:--";
                    sec = Math.floor(sec);
                    let h = Math.floor(sec / 3600);
                    let m = Math.floor((sec % 3600) / 60);
                    let s = sec % 60;
                    if (h > 0) {
                        return h + ":" + (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s;
                    }
                    return m + ":" + (s < 10 ? "0" : "") + s;
                }

                Rectangle {
                    id: progressBarBg
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 5
                    radius: 2.5
                    color: Color.mSurfaceVariant
                }

                Rectangle {
                    id: progressBarFill
                    anchors.verticalCenter: parent.verticalCenter
                    width: progressBarBg.width * parent.progress
                    height: progressBarBg.height
                    radius: progressBarBg.radius
                    color: Color.mPrimary
                    visible: parent.hasValidDuration

                    Behavior on width {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                Rectangle {
                    id: indeterminateBar
                    anchors.verticalCenter: parent.verticalCenter
                    width: 60
                    height: progressBarBg.height
                    radius: progressBarBg.radius
                    color: Color.mPrimary
                    visible: !parent.hasDuration && MediaService.isPlaying

                    SequentialAnimation on x {
                        running: indeterminateBar.visible
                        loops: Animation.Infinite
                        NumberAnimation {
                            from: 0
                            to: progressContainer.width - indeterminateBar.width
                            duration: 1500
                            easing.type: Easing.InOutQuad
                        }
                        NumberAnimation {
                            from: progressContainer.width - indeterminateBar.width
                            to: 0
                            duration: 1500
                            easing.type: Easing.InOutQuad
                        }
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
                        if (!parent.hasValidDuration)
                            return;
                        let ratio = Math.max(0, Math.min(1, mouseX / width));
                        let newPos = parent.duration * ratio;
                        MediaService.setPosition(newPos);
                    }

                    onClicked: mouse => seekTo(mouse.x)
                    onPositionChanged: mouse => {
                        if (pressed)
                            seekTo(mouse.x);
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4

                readonly property bool hasDuration: MediaService.trackLength > 0

                function formatTime(sec) {
                    if (sec < 0 || !isFinite(sec))
                        return "--:--";
                    sec = Math.floor(sec);
                    let h = Math.floor(sec / 3600);
                    let m = Math.floor((sec % 3600) / 60);
                    let s = sec % 60;
                    if (h > 0) {
                        return h + ":" + (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s;
                    }
                    return m + ":" + (s < 10 ? "0" : "") + s;
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
                    text: {
                        if (!parent.hasDuration)
                            return "LIVE";
                        if (remaining >= 0)
                            return "-" + parent.formatTime(remaining);
                        return parent.formatTime(MediaService.trackLength);
                    }
                    color: Color.mOnSurfaceVariant
                    pointSize: Style.fontSizeS
                }
            }
            Item {
                Layout.fillHeight: true
                Layout.minimumHeight: 1
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 16

                NIconButton {
                    icon: "player-skip-back"
                    enabled: MediaService.canGoPrevious
                    opacity: enabled ? 1 : 0.3
                    baseSize: 32
                    onClicked: MediaService.previous()
                }

                NIconButton {
                    icon: MediaService.isPlaying ? "player-pause" : "player-play"
                    enabled: MediaService.canPlay
                    baseSize: 32
                    colorBg: Color.mPrimary
                    colorFg: Color.mOnPrimary
                    colorBgHover: Color.mHover
                    onClicked: MediaService.playPause()
                }

                NIconButton {
                    icon: "player-skip-forward"
                    enabled: MediaService.canGoNext
                    opacity: enabled ? 1 : 0.3
                    baseSize: 32
                    onClicked: MediaService.next()
                }
            }
            Item {
                Layout.minimumHeight: 4
            }
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
}
