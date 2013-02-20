import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0

Page {
    tools: ToolBar{
	id: toolBar
	transition: "replace"
	style: ToolBarStyle {
	    background: "image://theme/meegotouch-toolbar-"+((screen.currentOrientation == Screen.Portrait||screen.currentOrientation==Screen.PortraitInverted)?"portrait":"landscape")+"-background"
	}

	ToolIcon {
	    platformIconId: "toolbar-back"
	    onClicked: pageStack.pop()
	}
    }
    
    Column {
	width: parent.width
	
	Text {
	    anchors.horizontalCenter: parent.horizontalCenter
	    text: "Fennec settings"
	    font.pixelSize: 40
	}
	Item { height: 10 }
	Separator { width: parent.width }

    }
}
 
