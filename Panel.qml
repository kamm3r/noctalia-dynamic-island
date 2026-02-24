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
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.minimumHeight: 12
            }

            Item {
                id: progressContainer
                Layout.fillWidth: true
                implicitHeight: 20

                property real position: MediaService.currentPosition
                property real duration: MediaService.trackLength
                readonly property bool hasDuration: duration > 0
                readonly property real progress: hasDuration ? Math.max(0, Math.min(1, position / duration)) : 0
                readonly property bool hasValidDuration: hasDuration && position <= duration * 1.1

                property bool isDragging: false
                property real dragRatio: 0

                function getEffectiveProgress() {
                    return isDragging ? dragRatio : progress;
                }

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
                    width: parent.width * parent.getEffectiveProgress()
                    height: progressBarBg.height
                    radius: progressBarBg.radius
                    color: Color.mPrimary
                    visible: parent.hasValidDuration || parent.isDragging
                }

                Rectangle {
                    id: progressHandle
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.isDragging ? 16 : 12
                    height: parent.isDragging ? 16 : 12
                    radius: parent.isDragging ? 8 : 6
                    x: parent.width * parent.getEffectiveProgress() - width / 2
                    color: Color.mPrimary
                    visible: parent.hasValidDuration || parent.isDragging
                }

                Rectangle {
                    id: timeTooltip
                    visible: progressContainer.isDragging
                    y: -24
                    x: Math.min(Math.max(0, progressMouseArea.mouseX - 30), progressContainer.width - 60)
                    width: 60
                    height: 18
                    radius: 4
                    color: Color.mSurface
                    border.color: Color.mOutline
                    border.width: 1

                    NText {
                        anchors.centerIn: parent
                        text: progressContainer.formatTime(progressContainer.dragRatio * progressContainer.duration)
                        color: Color.mOnSurface
                        pointSize: 10
                    }
                }

                MouseArea {
                    id: progressMouseArea
                    property real mouseX: 0
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: parent.hasValidDuration ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled: parent.hasValidDuration
                    preventStealing: true

                    onPositionChanged: mouse => {
                        mouseX = mouse.x
                        if (pressed && parent.hasValidDuration) {
                            parent.dragRatio = Math.max(0, Math.min(1, mouse.x / parent.width));
                            parent.isDragging = true;
                        }
                    }

                    onPressed: mouse => {
                        if (parent.hasValidDuration) {
                            parent.dragRatio = Math.max(0, Math.min(1, mouse.x / parent.width));
                            parent.isDragging = true;
                        }
                    }

                    onReleased: {
                        if (parent.isDragging) {
                            MediaService.seekByRatio(parent.dragRatio);
                            parent.isDragging = false;
                            parent.dragRatio = 0;
                        }
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
                    text: progressContainer.formatTime(progressContainer.isDragging ? progressContainer.dragRatio * progressContainer.duration : progressContainer.position)
                    color: Color.mOnSurfaceVariant
                    pointSize: Style.fontSizeS
                }

                Item {
                    Layout.fillWidth: true
                }

                NText {
                    readonly property real remaining: progressContainer.duration - (progressContainer.isDragging ? progressContainer.dragRatio * progressContainer.duration : progressContainer.position)
                    text: {
                        if (!progressContainer.hasDuration)
                            return "LIVE";
                        if (remaining >= 0)
                            return "-" + progressContainer.formatTime(remaining);
                        return progressContainer.formatTime(MediaService.trackLength);
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
                spacing: 20

                Item {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32

                    Item {
                        id: prevBtn
                        anchors.fill: parent
                        scale: prevBtn.scaleVal
                        property real scaleVal: 1.0
                        Behavior on scaleVal { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                        Rectangle {
                            id: prevBg
                            anchors.fill: parent
                            radius: 16
                            color: Color.mOnSurface
                            opacity: 0
                        }

                        NIcon {
                            anchors.centerIn: parent
                            icon: "player-skip-back"
                            color: Color.mOnSurface
                            pointSize: 16
                            opacity: MediaService.canGoPrevious ? 1 : 0.3
                        }
                    }

                    MouseArea {
                        id: prevMa
                        anchors.fill: parent
                        enabled: MediaService.canGoPrevious
                        onPressedChanged: {
                            prevBg.opacity = pressed ? 0.1 : 0
                        }
                        onPressed: prevBtn.scaleVal = 0.97
                        onReleased: prevBtn.scaleVal = 1.0
                        onClicked: MediaService.previous()
                    }
                }

                Item {
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 44

                    Item {
                        id: playPauseBtn
                        anchors.fill: parent
                        scale: playPauseBtn.scaleVal
                        property real scaleVal: 1.0
                        Behavior on scaleVal { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                        Rectangle {
                            id: playPauseBg
                            anchors.fill: parent
                            radius: 22
                            color: Color.mOnSurface
                            opacity: 0
                        }

                        NIcon {
                            anchors.centerIn: parent
                            icon: MediaService.isPlaying ? "player-pause" : "player-play"
                            color: Color.mOnSurface
                            pointSize: 20
                        }
                    }

                    MouseArea {
                        id: playPauseMa
                        anchors.fill: parent
                        onPressedChanged: {
                            playPauseBg.opacity = pressed ? 0.1 : 0
                        }
                        onPressed: playPauseBtn.scaleVal = 0.97
                        onReleased: playPauseBtn.scaleVal = 1.0
                        onClicked: MediaService.playPause()
                    }
                }

                Item {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32

                    Item {
                        id: nextBtn
                        anchors.fill: parent
                        scale: nextBtn.scaleVal
                        property real scaleVal: 1.0
                        Behavior on scaleVal { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                        Rectangle {
                            id: nextBg
                            anchors.fill: parent
                            radius: 16
                            color: Color.mOnSurface
                            opacity: 0
                        }

                        NIcon {
                            anchors.centerIn: parent
                            icon: "player-skip-forward"
                            color: Color.mOnSurface
                            pointSize: 16
                            opacity: MediaService.canGoNext ? 1 : 0.3
                        }
                    }

                    MouseArea {
                        id: nextMa
                        anchors.fill: parent
                        enabled: MediaService.canGoNext
                        onPressedChanged: {
                            nextBg.opacity = pressed ? 0.1 : 0
                        }
                        onPressed: nextBtn.scaleVal = 0.97
                        onReleased: nextBtn.scaleVal = 1.0
                        onClicked: MediaService.next()
                    }
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
