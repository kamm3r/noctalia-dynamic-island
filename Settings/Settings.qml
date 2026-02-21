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
      text: "Island Width: " + widthSlider.value
      color: Color.mOnSurface
      pointSize: Style.fontSizeS
      Layout.fillWidth: true
    }

    Slider {
      id: widthSlider
      Layout.fillWidth: true
      from: 120
      to: 280
      stepSize: 10
      value: settings.compactWidth ?? 180

      onMoved: {
        pluginApi.pluginSettings.compactWidth = value
        pluginApi.saveSettings()
      }
    }

    NText {
      text: "Clear Delay: " + (delaySlider.value / 1000).toFixed(1) + "s"
      color: Color.mOnSurface
      pointSize: Style.fontSizeS
      Layout.fillWidth: true
    }

    Slider {
      id: delaySlider
      Layout.fillWidth: true
      from: 1000
      to: 10000
      stepSize: 500
      value: settings.clearDelay ?? 3000

      onMoved: {
        pluginApi.pluginSettings.clearDelay = value
        pluginApi.saveSettings()
      }
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.marginS

      NText {
        text: "Scroll Title"
        color: Color.mOnSurface
        pointSize: Style.fontSizeS
        Layout.fillWidth: true
      }

      Switch {
        checked: settings.scrollTitle ?? true
        onToggled: {
          pluginApi.pluginSettings.scrollTitle = checked
          pluginApi.saveSettings()
        }
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
