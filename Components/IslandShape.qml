import QtQuick
import QtQuick.Shapes

Item {
  id: root

  property real islandWidth: 200
  property real islandHeight: 36
  property color fillColor: "#000000"
  property color borderColor: "transparent"
  property real borderWidth: 0
  property real cornerRadius: Math.min(16, islandHeight / 2)

  anchors.fill: parent

  Shape {
    anchors.fill: parent
    antialiasing: true

    ShapePath {
      fillColor: root.fillColor
      strokeColor: root.borderColor
      strokeWidth: root.borderWidth
      fillRule: ShapePath.WindingFill

      startX: 0
      startY: 0

      PathLine {
        x: root.islandWidth
        y: 0
      }

      PathLine {
        x: root.islandWidth
        y: root.islandHeight - root.cornerRadius
      }

      PathArc {
        x: root.islandWidth - root.cornerRadius
        y: root.islandHeight
        radiusX: root.cornerRadius
        radiusY: root.cornerRadius
        direction: PathArc.Clockwise
      }

      PathLine {
        x: root.cornerRadius
        y: root.islandHeight
      }

      PathArc {
        x: 0
        y: root.islandHeight - root.cornerRadius
        radiusX: root.cornerRadius
        radiusY: root.cornerRadius
        direction: PathArc.Clockwise
      }

      PathLine {
        x: 0
        y: 0
      }
    }
  }
}
