import QtQuick 1.1

Rectangle {
    width: parent.width
    height: 2
    color:"transparent"
    
    Rectangle {
	id: divider
	anchors.verticalCenter: parent.verticalCenter
	x:0
	width: parent.width
	height: 1
	color: "gray"
	opacity: 0.3
    }
    
    Rectangle {
	anchors.top: divider.bottom
	x:0
	width: parent.width
	height: 1
	color: theme.inverted? "darkgray" : "white"
	opacity: theme.inverted? 0.3 : 0.5
    }
    
}
