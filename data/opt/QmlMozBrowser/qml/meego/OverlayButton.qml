import Qt 4.7
import QtQuick 1.1

Item {
	id: root

	signal clicked()
	signal pressAndHold()
	signal pressed()

	property alias iconSource: icon.source
	property alias text: label.text
	property bool itemPressed: false
	property int fixedHeight: 0

	function mouseEntered() {
		console.log("overlay ext entered")
		itemPressed = true
	}

	function mouseExited() {
		console.log("overlay ext exited")
		itemPressed = false
	}

	function mouseReleased() {
		console.log("overlay ext released")
		clicked()
	}

	Rectangle {
		id: background

		anchors.fill: root

		radius: root.height / 5
		border.color: "black"
		border.width: 2
		color: root.enabled ? ((mouseArea.pressed || root.itemPressed)? "#c608b5" : "snow") : "lightgray"
		opacity: (mouseArea.pressed || root.itemPressed)? 0.9 : 0.9
	}

	Image {
		id: icon
		anchors.left: root.left
		anchors.top: root.top
		anchors.bottom: root.bottom
		anchors.margins: root.height / 20
		height: root.height - anchors.leftMargin
		width: height
		fillMode: Image.PreserveAspectFit
		smooth: true
		cache: true
		asynchronous: true
		visible: source != ""
		opacity: root.enabled ? 1.0 : 0.2
	}

	Text {
		id: label
		anchors.verticalCenter: root.verticalCenter
		anchors.left: icon.visible ? icon.right : root.left
		anchors.leftMargin: 0//(root.width - (icon.visible ? icon.width : 0) - paintedWidth) / 2 - root.radius
		height: root.fixedHeight ? root.fixedHeight : root.height - root.radius*2
		font.pixelSize: height

	        anchors.right: parent.right

	        horizontalAlignment: icon.visible ? Text.AlignLeft : Text.AlignHCenter
	        elide: Text.ElideRight

		opacity: root.enabled ? 1.0 : 0.2
	}

	MouseArea {
		id: mouseArea

		anchors.fill: parent
		hoverEnabled: true
		preventStealing: true

		onPressed: {
			console.log("overlayButton pressed")
			root.pressed()
			mouse.accepted = true
		}
		onReleased: {
			console.log("overlayButton released")
			root.clicked()
			mouse.accepted = true
		}
		onPressAndHold: {
			console.log("overlayButton hold")
			root.pressAndHold()
			mouse.accepted = true
		}
	}
}