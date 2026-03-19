import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
  id: root
  property var pluginApi: null

  // Settings access pattern — always use this fallback chain
  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  // Edit copies of settings (don't modify pluginSettings directly in bindings)
  property real editCompactWidth: cfg.compactWidth ?? defaults.compactWidth ?? 180
  property int editClearDelay: cfg.clearDelay ?? defaults.clearDelay ?? 3000
  property bool editScrollTitle: cfg.scrollTitle ?? defaults.scrollTitle ?? true
  property bool editShowVisualizer: cfg.showVisualizer ?? defaults.showVisualizer ?? true

  spacing: Style.marginL

  NText {
    text: pluginApi?.tr("settings.title.label")
    color: Color.mOnSurface
    pointSize: Style.fontSizeL
    font.weight: Font.Bold
    Layout.fillWidth: true
  }

  NText {
    text: pluginApi?.tr("settings.compactWidth.label") + ": " + Math.round(editCompactWidth)
    color: Color.mOnSurface
    pointSize: Style.fontSizeS
    Layout.fillWidth: true
  }

  NSlider {
    Layout.fillWidth: true
    from: 120
    to: 280
    stepSize: 10
    value: root.editCompactWidth
    onValueChanged: root.editCompactWidth = value
  }

  NText {
    text: pluginApi?.tr("settings.clearDelay.label") + ": " + (editClearDelay / 1000).toFixed(1) + "s"
    color: Color.mOnSurface
    pointSize: Style.fontSizeS
    Layout.fillWidth: true
  }

  NSlider {
    Layout.fillWidth: true
    from: 1000
    to: 10000
    stepSize: 500
    value: root.editClearDelay
    onValueChanged: root.editClearDelay = Math.round(value)
  }

  RowLayout {
    Layout.fillWidth: true
    spacing: Style.marginS

    NText {
      text: pluginApi?.tr("settings.scrollTitle.label")
      color: Color.mOnSurface
      pointSize: Style.fontSizeS
      Layout.fillWidth: true
    }

    NSwitch {
      checked: root.editScrollTitle
      onCheckedChanged: root.editScrollTitle = checked
    }
  }

  RowLayout {
    Layout.fillWidth: true
    spacing: Style.marginS

    NText {
      text: pluginApi?.tr("settings.showVisualizer.label")
      color: Color.mOnSurface
      pointSize: Style.fontSizeS
      Layout.fillWidth: true
    }

    NSwitch {
      checked: root.editShowVisualizer
      onCheckedChanged: root.editShowVisualizer = checked
    }
  }

  // Required — called by the shell when user saves
  function saveSettings() {
    if (!pluginApi) return;
    pluginApi.pluginSettings.compactWidth = root.editCompactWidth;
    pluginApi.pluginSettings.clearDelay = root.editClearDelay;
    pluginApi.pluginSettings.scrollTitle = root.editScrollTitle;
    pluginApi.pluginSettings.showVisualizer = root.editShowVisualizer;
    pluginApi.saveSettings();
  }
}
