import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
  id: root

  property var pluginApi: null
  property var settings: pluginApi?.pluginSettings ?? {}

  implicitWidth: 320
  implicitHeight: column.implicitHeight + Style.marginL * 2

  ColumnLayout {
    id: column
    anchors.fill: parent
    anchors.margins: Style.marginL
    spacing: Style.marginM

    NText {
      text: "Dynamic Island Settings"
      color: Color.mOnSurface
      pointSize: Style.fontSizeL
      font.weight: Font.Bold
      Layout.fillWidth: true
    }

    NText {
      text: "Compact Width: " + compactWidthSlider.value
      color: Color.mOnSurface
      pointSize: Style.fontSizeS
      Layout.fillWidth: true
    }

    Slider {
      id: compactWidthSlider
      Layout.fillWidth: true
      from: 150
      to: 300
      stepSize: 10
      value: settings.compactWidth ?? 200

      onMoved: {
        pluginApi.pluginSettings.compactWidth = value
        pluginApi.saveSettings()
      }
    }

    NText {
      text: "Expanded Width: " + expandedWidthSlider.value
      color: Color.mOnSurface
      pointSize: Style.fontSizeS
      Layout.fillWidth: true
    }

    Slider {
      id: expandedWidthSlider
      Layout.fillWidth: true
      from: 300
      to: 500
      stepSize: 25
      value: settings.expandedWidth ?? 400

      onMoved: {
        pluginApi.pluginSettings.expandedWidth = value
        pluginApi.saveSettings()
      }
    }

    NText {
      text: "Expanded Height: " + expandedHeightSlider.value
      color: Color.mOnSurface
      pointSize: Style.fontSizeS
      Layout.fillWidth: true
    }

    Slider {
      id: expandedHeightSlider
      Layout.fillWidth: true
      from: 80
      to: 200
      stepSize: 10
      value: settings.expandedHeight ?? 120

      onMoved: {
        pluginApi.pluginSettings.expandedHeight = value
        pluginApi.saveSettings()
      }
    }

    NText {
      text: "Auto-collapse Timeout (ms): " + timeoutSlider.value
      color: Color.mOnSurface
      pointSize: Style.fontSizeS
      Layout.fillWidth: true
    }

    Slider {
      id: timeoutSlider
      Layout.fillWidth: true
      from: 2000
      to: 10000
      stepSize: 500
      value: settings.expandedTimeout ?? 5000

      onMoved: {
        pluginApi.pluginSettings.expandedTimeout = value
        pluginApi.saveSettings()
      }
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.marginS

      NText {
        text: "Show Visualizer"
        color: Color.mOnSurface
        pointSize: Style.fontSizeS
        Layout.fillWidth: true
      }

      Switch {
        checked: settings.showVisualizer ?? true
        onToggled: {
          pluginApi.pluginSettings.showVisualizer = checked
          pluginApi.saveSettings()
        }
      }
    }
  }
}
