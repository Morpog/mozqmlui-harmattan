/* -*- Mode: C++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Qt 4.7
import QtMozilla 1.0
import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import QtMobility.feedback 1.1

FocusScope {
    id: mainScope
    objectName: "mainScope"
    
    anchors.fill: parent
    property variant viewport
    
    signal pageTitleChanged(string title)
    signal setClipboard(string text)
    
    //x: 0; y: 0
    //width: 800; height: 600
    
    Component.onCompleted: {
	createWindow(startURL)
    }
    
    function load(address) {
	addressLine.text = address;
	viewport.child().load(address)
    }
    
    function focusAddressBar() {
	addressLine.forceActiveFocus()
	addressLine.selectAll()
    }
    
    Connections {
	target: viewport
	onUrlChanged: {
	    addressLine.text = url;
	    addressLine.cursorPosition = 0;
	}
	onTitleChanged: {
		pageTitle.text = title;
		pageTitleChanged(title);
	}
	onContextUrl: {
	    showContextMenu(url, src);
	}
    }

    function createWindow(address){
	for (var i=0; i<storage.count-1; i++){
	    storage.get(i).element.visible = false
	    storage.get(i).element.focus = false
	}
	var component = Qt.createComponent("FennecWindow.qml");
	var object = component.createObject(browserArea);
	object.anchors.fill = browserArea
	object.visible = true
	object.focus = true
	
	storage.insert(storage.count-1, {name:"page", element:object})
	storage.pageIndex = storage.count-2
	
	mainScope.viewport = storage.get(storage.count-2).element
	object.address = address
	addressLine.text = address
	addressLine.cursorPosition = 0
	pageTitle.text = " "
	navigationBar.anchors.topMargin = 0
    }

    Item {
	    id: browserArea
	    anchors.left: parent.left
	    anchors.right: parent.right
	    anchors.top: navigationBar.bottom
	    anchors.bottom: tabsBar.top
	}
    
    Rectangle {
	id: navigationBar
	color: "#efefef"
	height: 70
	anchors {
	    top: parent.top
	    left: parent.left
	    right: parent.right
	    topMargin: 0
	}
	
	Column {
	    width: parent.width
	    spacing: 2
	    
	    Text{
		id: pageTitle
		height: 18
		anchors.left: parent.left
		anchors.leftMargin: 10
		anchors.right: parent.right
		anchors.rightMargin: 10
		font.pixelSize: 18
		text: " "
		horizontalAlignment: (paintedWidth > parent.width)?Text.AlignLeft:Text.AlignHCenter
	    }
	    
	    Row {
		id: controlsRow
		height: 50
		width: parent.width
		spacing: 4
		
		ToolIcon {
		    id: backButton
		    height: 40
		    width: 40
		    anchors.verticalCenter: parent.verticalCenter
		    platformIconId: "toolbar-previous-"+(viewport.child().canGoBack?"":"dimmed-")+"white"
		    enabled: viewport.child().canGoBack
		    onClicked: {
			console.log("going back")
			viewport.child().goBack()
		    }
		}
		
		ToolIcon {
		    id: forwardButton
		    height: 40
		    width: 40
		    anchors.verticalCenter: parent.verticalCenter
		    platformIconId: "toolbar-next-"+(viewport.child().canGoForward?"":"dimmed-")+"white"
		    enabled: viewport.child().canGoForward
		    onClicked: {
			console.log("going forward")
			viewport.child().goForward()
		    }
		}
		
		ToolIcon {
		    id: reloadButton
		    height: 40
		    width: 40
		    anchors.verticalCenter: parent.verticalCenter
		    platformIconId: viewport.child().loading ?"toolbar-stop-white":"toolbar-refresh-white"
		    onClicked: {
			if (viewport.child().loading) {
			    console.log("stop loading")
			    viewport.child().stop()
			} else {
			    console.log("reloading")
			    viewport.child().reload()
			}
		    }
		}
		
		Rectangle {
		    color: "white"
		    border.width: 1
		    height: 40
		    width: parent.width - 138
		    anchors.verticalCenter: parent.verticalCenter
		    radius: 10
		    
		    Rectangle {
			anchors {
			    top: parent.top
			    bottom: parent.bottom
			    left: parent.left
			}
			width: parent.width / 100 * viewport.child().loadProgress
			radius: 10
			color: "blue"
			opacity: 0.3
			visible: viewport.child().loadProgress != 100
		    }
		    
		    TextField {
			id: addressLine
			platformStyle: TextFieldStyle {
			    id: myTextFieldStyle
			    backgroundSelected: ""
			    background: ""
			    backgroundDisabled: ""
			    backgroundError: ""
			}
			inputMethodHints: Qt.ImhNoPredictiveText
			font {
			    pixelSize: 25
			    family: "Nokia Pure Text"
			}
			anchors {
			    verticalCenter: parent.verticalCenter
			    left: parent.left
			    leftMargin: -10
			    right: parent.right
			    rightMargin: 0
			}
			
			onActiveFocusChanged: {
			    tabsBar.anchors.bottomMargin = -100
			    browserArea.enabled = !addressLine.focus
			}
			
			Keys.onReturnPressed:{
			    console.log("going to: ", addressLine.text)
			    load(addressLine.text);
			    mainScope.viewport.focus = true
			}
			
			Keys.onPressed: {
			    if (((event.modifiers & Qt.ControlModifier) && event.key == Qt.Key_L) || event.key == Qt.key_F6) {
				focusAddressBar()
				event.accepted = true
			    }
			}
		    }
		}
	    }
	}
	
	Component.onCompleted: {
	    print("QML On Completed>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	}
	Component.onDestruction: {
	    print("QML On Destroyed>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	}
    }
    
    Rectangle {
	id: tabsBar
	anchors {
	    bottom: parent.bottom
	    bottomMargin: -100
	    left: parent.left
	    right: parent.right
	}
	height: 100
	color: "white"
	border.width: 2
	border.color: "#aaaaaa"
	
	ListView {
	    anchors.fill: parent
	    anchors.rightMargin: 100
	    clip: true
	    model: storage
	    orientation: ListView.Horizontal
	    delegate: tabDelegate
	    spacing: 0
	}
	
	Button {
	    width: 80
	    height: 80
	    anchors.verticalCenter: parent.verticalCenter
	    anchors.right: parent.right
	    anchors.rightMargin: 10
	    iconSource: "image://theme/icon-m-toolbar-rich-text-view-menu"
	    
	    onClicked: {
		pageStack.push(Qt.resolvedUrl("Settings.qml"))
	    }
	}
    }
    
    Item {
	id: pageArea
	anchors.top: navigationBar.bottom
	anchors.left: parent.left
	anchors.right: parent.right
	anchors.bottom: tabsBar.top
	
	MouseArea{
	    id: interactionArea
	    anchors.fill: parent
	    preventStealing: true
	    
	    property int mouseX: 0
	    property int mouseY: 0
	    property int edgeY: 0
	    property bool longPressed: false
	    property bool longLocked: false

	    function toggleBars() {
		if (navigationBar.anchors.topMargin > -20)
			navigationBar.anchors.topMargin = 0;
		else
			navigationBar.anchors.topMargin = -70;

		if (tabsBar.anchors.bottomMargin > -20)
			tabsBar.anchors.bottomMargin = 0;
		else
			tabsBar.anchors.bottomMargin = -100;
	    }
	    
	    onClicked: {
		viewport.focus = true;
		navigationBar.anchors.topMargin = -70
		tabsBar.anchors.bottomMargin = -100
	    }
	    
	    onPressed: {
		viewport.focus = true;
		longPressed = false;
		toggleBars()
		longLocked = false;
		var mapped = mapToItem(mainScope, mouse.x, mouse.y);
		mouseY = mapped.y
		mouseX = mapped.x
	    }
	    
	    onReleased: {
	    	viewport.enabled = true
		viewport.focus = true;
		//if (longPressed) {
		    toggleBars()
		    longPressed = false;
		//}
		longLocked = false
		edgeY = 0
	    }
	    
	    onPressAndHold: {
		var mapped = mapToItem(mainScope, mouse.x, mouse.y);
		if (!longLocked && Math.round(mapped.y - mouseY) < 30 && Math.round(mapped.x - mouseX) < 30) {
		    vibra.play()
		    //mouseX = mouse.x
		    //mouseY = mouse.y
		    longPressed = true
		}
	    }
	    
	    onPositionChanged: {
		var mapped = mapToItem(mainScope, mouse.x, mouse.y);
		var deltaY = mouseY - mapped.y
		if (!longPressed && Math.round(deltaY) > 30) {
			longLocked = true
		}
		if (!longLocked && longPressed && contextMenu.status==DialogStatus.Closed) {
			var bottomDelta = deltaY
			if (bottomDelta > 100)
				bottomDelta = 100;
			tabsBar.anchors.bottomMargin = bottomDelta - 100;
		}
		if (viewport.child().contentRect.y == 0) {
			if (deltaY < 0) {
				viewport.enabled = false
				if (edgeY == 0)
					edgeY = mapped.y

				var topDelta = mapped.y - edgeY;
				if (topDelta > 70)
					topDelta = 70;
				navigationBar.anchors.topMargin = topDelta - 70;
			}
			else {
				viewport.enabled = true
			}
		}
	    }
	}
    }
    
    function showContextMenu(url, img) {
	contextMenu.url = url
	contextMenu.img = img
	if (url.length > 0 || img.length > 0)
	    contextMenu.open()
    }
    
    Menu {
	id: contextMenu
	property string url: ""
	property string img: ""
	visualParent: pageStack
	MenuLayout {
	    MenuItem {
		text: "Open link url in new tab"
		visible: contextMenu.url.length > 0
		onClicked: { 
		    contextMenu.close()
		    viewport.focus = true
		    createWindow(contextMenu.url)
		} 
	    }
	    MenuItem {
		text: "Open image url in new tab"
		visible: contextMenu.img.length > 0
		onClicked: { 
		    contextMenu.close()
		    viewport.focus = true
		    createWindow(contextMenu.img)
		} 
	    }
	    MenuItem {
	    	text: "Copy link url to clipboard"
		visible: contextMenu.url.length > 0
	    	onClicked: { 
		    contextMenu.close()
		    viewport.focus = true
		    setClipboard(contextMenu.url)
		}
	    }
	    MenuItem {
	    	text: "Copy image url to clipboard"
		visible: contextMenu.img.length > 0
	    	onClicked: { 
		    contextMenu.close()
		    viewport.focus = true
		    setClipboard(contextMenu.img)
		}
	    }
	}
    }
    
    Keys.onPressed: {
	if (((event.modifiers & Qt.ControlModifier) && event.key == Qt.Key_L) || event.key == Qt.key_F6) {
	    console.log("Focus address bar")
	    focusAddressBar()
	    event.accepted = true
	}
    }
    
    ListModel{
	id: storage
	property int pageIndex: 0
	
	ListElement {name:"newpage"}
    }
    
    Component {
	id: tabDelegate
	Item {
	    width: 84
	    height: 100
	    
	    Rectangle{
		id: background
		anchors.left: parent.left
		anchors.leftMargin: 2
		anchors.right: parent.right
		anchors.rightMargin: 2
		anchors.bottom: parent.bottom
		anchors.bottomMargin: 3
		height: storage.pageIndex==index?80:(name=="newpage"?80:60)
		radius: 10
		border.width: 4
		border.color: storage.pageIndex==index?"green":(name=="newpage"?"blue":"black")
		color: "white"
	    
		Label {
		    anchors.centerIn: parent
		    font.pixelSize: 60
		    text: name=="newpage"?"+":(index+1)
		}
	    }
	    
	    MouseArea {
		anchors.fill: parent
		
		function activateIndex(m_index){
		    for (var i=0; i<storage.count-1; i++){
			storage.get(i).element.visible = false
			storage.get(i).element.focus = false
		    }
		    storage.get(m_index).element.visible = true
		    storage.get(m_index).element.focus = true
		    storage.pageIndex = m_index
		    mainScope.viewport = storage.get(m_index).element
		    addressLine.text = storage.get(m_index).element.url
		    addressLine.cursorPosition = 0
		    pageTitle.text = storage.get(m_index).element.title
		    if (pageTitle.text == "") { pageTitle.text = " " }
		}
		
		onClicked: {		    
		    if (index==storage.count-1)
			createWindow("");
		    else
			activateIndex(index);
		    
		    navigationBar.anchors.topMargin = 0
		}
		onPressAndHold: {
		    if (index != storage.count-1 && storage.count > 2){
			vibra.play()
			if (index>1)
			    activateIndex(index-1);
			else
			    activateIndex(0);
			
			storage.remove(index)
			storage.get(index).element.destroy()
		    }
		}
	    }
	}
    }
    
    ThemeEffect {
	id: vibra
	effect: ThemeEffect.PopupOpen
    }
}
