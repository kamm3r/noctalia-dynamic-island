import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Services.Media

RowLayout {
  id: root

  property bool running: false
  property color barColor: "#FFFFFF"
  property real barOpacity: 0.85
  property real maxBarHeight: 14
  property bool silent: true

  spacing: 2.5

  property var barHeights: [3, 3, 3, 3, 3, 3]
  property var targetHeights: [3, 3, 3, 3, 3, 3]
  property var velocities: [0, 0, 0, 0, 0, 0]

  Timer {
    interval: 16
    running: root.running
    repeat: true

    onTriggered: {
      let changed = false
      const stiffness = [0.12, 0.16, 0.22, 0.22, 0.16, 0.12]
      const damping = 0.82

      const silent = targetHeights.every(v => v <= 3.05)
      root.silent = silent
      
      for (let i = 0; i < barHeights.length; i++) {
        if (silent) {
          barHeights[i] = 3
          velocities[i] = 0
          changed = true
        } else {
          const phaseOffset = (i - 2.5) * 0.15
          const target = targetHeights[i] + phaseOffset
          let force = (target - barHeights[i]) * stiffness[i]

          velocities[i] += force
          velocities[i] *= damping

          if (Math.abs(velocities[i]) > 0.01) {
            barHeights[i] += velocities[i]
            changed = true
          }
        }
      }

      if (changed) {
        barHeights = barHeights.slice()
        velocities = velocities.slice()
      }
    }
  }

  Connections {
    target: CavaService
    function onValuesChanged() {
      if (!root.running || CavaService.values.length < 32) return

      const values = CavaService.values
      const sampleIndices = [2, 8, 14, 18, 24, 28]

      for (let i = 0; i < 6; i++) {
        const val = values[sampleIndices[i]] || 0
        const scaled = Math.max(3, Math.min(maxBarHeight, 3 + val * 22))
        targetHeights[i] = scaled
      }
      targetHeights = targetHeights.slice()
    }
  }

  Repeater {
    model: 6

    Item {
      width: 2.5
      height: 24
      Layout.alignment: Qt.AlignVCenter

      Rectangle {
        anchors.centerIn: parent
        width: 2.5
        radius: 1.25
        height: root.barHeights[index]
        color: root.barColor
        opacity: root.barOpacity

        Behavior on height {
          enabled: !root.silent
          NumberAnimation {
            duration: 100
            easing.type: Easing.OutCubic
          }
        }
      }
    }
  }
}
