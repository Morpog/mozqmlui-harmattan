import Qt 4.7
import QtMozilla 1.0
import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0

QDeclarativeMozView {
    id: webViewport
    anchors.fill: parent
    
    signal urlChanged(string url)
    signal titleChanged(string title)
    signal contextUrl(string url, string src)
    
    property string title: webViewport.child().title
    property string url: webViewport.child().url
    property string address: ""
    
    property int rectX: 0
    property int rectY: 0
    property int rectW: 0
    property int rectH: 0
    property int scrollW: 0
    property int scrollH: 0

    property bool movingHorizontally : false
    property bool movingVertically : true
    property variant visibleArea : QtObject {
	property real yPosition : 0
	property real xPosition : 0
	property real widthRatio : 0
	property real heightRatio : 0
    }

    function scrollTimeout() {
	webViewport.movingHorizontally = false;
	webViewport.movingVertically = false;
    }
    Timer {
	id: scrollTimer
	interval: 500; running: false; repeat: false;
	onTriggered: webViewport.scrollTimeout()
    }
    
    Connections {
	target: webViewport.child()
	onViewInitialized: {
	    print("QML View Initialized first");
	    webViewport.child().addMessageListener("chrome:title")
	    webViewport.child().addMessageListener("context:info")
	    if (address!="")
		webViewport.child().load(address);
	}
	onViewAreaChanged: {
		var r = webViewport.child().contentRect;
		var offset = webViewport.child().scrollableOffset;
		var s = webViewport.child().scrollableSize;
		webViewport.visibleArea.widthRatio = r.width / s.width;
		webViewport.visibleArea.heightRatio = r.height / s.height;
		webViewport.visibleArea.xPosition = offset.x * webViewport.visibleArea.widthRatio * webViewport.child().resolution;
		webViewport.visibleArea.yPosition = offset.y * webViewport.visibleArea.heightRatio * webViewport.child().resolution;
		webViewport.movingHorizontally = true;
		webViewport.movingVertically = true;
		scrollTimer.restart();
        }
	onTitleChanged: {
	    print("onTitleChanged: " + webViewport.child().title)
	    titleChanged(webViewport.child().title)
	}
	onUrlChanged: {
	    print("onUrlChanged: " + webViewport.child().url)
	    urlChanged(webViewport.child().url)
	}
	onRecvAsyncMessage: {
	    print("onRecvAsyncMessage: " + message + ", data:" + data);
	    if (message == "context:info") {
	    	contextUrl(data.aHRef, data.aSrc)
	    }
	}
	onRecvSyncMessage: {
	    print("onRecvSyncMessage:" + message + ", data:" + data);
	    if (message == "embed:testsyncresponse") {
		response.message = { "val" : "response", "numval" : 0.04 };
	    }
	}
	onAlert: {
	    print("onAlert: title:" + data.title + ", msg:" + data.text + " winid:" + data.winid);
	    webViewport.enabled = false;
	    alertDlg.winId = data.winid;
	    alertDlg.titleText = data.title;
	    alertDlg.message = data.text;
	    alertDlg.open();
	}
	onConfirm: {
	    print("onConfirm: title:" + data.title + ", data.text:" + data.text);
	    webViewport.enabled = false;
	    confirmDlg.winId = data.winid;
	    confirmDlg.titleText = data.title;
	    confirmDlg.message = data.text;
	    confirmDlg.open();
	}
	onPrompt: {
	    print("onPrompt: title:" + data.title + ", msg:" + data.text);
	    webViewport.enabled = false;
	    promptDlg.winId = data.winid;
	    promptDlg.titleText = data.title;
	    promptDlg.messageText = data.text;
	    promptDlg.valueText = data.defaultValue;
	    promptDlg.open();
	}
	onAuthRequired: {
	    print("onAuthRequired: title:" + data.title + ", msg:" + data.text + ", winid:" + data.winid);
	    webViewport.enabled = false;
	    authDlg.winId = data.winid;
	    authDlg.titleText = data.title;
	    authDlg.messageText = data.text;
	    authDlg.usernameText = data.defaultValue;
	    authDlg.open();
	}
    }

    ScrollIndicator { flickableItem: webViewport }
    
    QueryDialog {
	id: alertDlg
	property int winId: 0
	acceptButtonText: "OK"
	
	onAccepted: {
	    webViewport.enabled = true;
	    webViewport.child().sendAsyncMessage("alertresponse", {
                    "winid" : winId,
                    "checkval" : 0,
                    "accepted" : true
                });
	}
    }
    
    QueryDialog {
	id: confirmDlg
	property int winId: 0
	acceptButtonText: "OK"
	rejectButtonText: "Cancel"
	
	onAccepted: {
	    webViewport.enabled = true;
	    webViewport.child().sendAsyncMessage("confirmresponse", {
                    "winid" : winId,
                    "checkval" : 0,
                    "accepted" : true
                });
	}
	onRejected: {
	    webViewport.enabled = true;
	    webViewport.child().sendAsyncMessage("confirmresponse", {
                    "winid" : winId,
                    "checkval" : 0,
                    "accepted" : false
                });
	}
    }
    
    Dialog {
	id: promptDlg
	property alias titleText: promptTitleString.text
	property alias messageText: promptMessageString.text
	property alias valueText: valueField.text
	property int winId: 0
	title: Label { 
	    text: "Prompt dialog"
	    anchors.verticalCenter: parent.verticalCenter
	    font.pixelSize: 30
	    color: "white"
	}
	content: Column {
	    width: parent.width
	    spacing: 5
	    
	    Item { height: 40; width: parent.width }
	    
	    Label { 
		id: promptTitleString
		color: "white"
	    }
	    
	    Item { height: 20; width: parent.width }
	    
	    Label {
		id: promptMessageString 
		color: "white"
	    }
	    
	    TextField {
		id: valueField
		width: parent.width
		placeholderText: "value"
		
		Keys.onReturnPressed: promptDlg.accept();
	    }
	    
	    Item { height: 40; width: parent.width }
	}
	buttons: Column {
	    anchors.verticalCenter: parent.verticalCenter
	    spacing: 5
	    
	    Button {text: "OK"; onClicked: promptDlg.accept(); }
	    Button {text: "Cancel"; onClicked: promptDlg.reject(); }
	}
	onAccepted: {
	    webViewport.enabled = true;
        webViewport.child().sendAsyncMessage("promptresponse", {
            "winid" : winId,
            "checkval" : 0,
            "accepted" : true,
            "promptvalue" : valueField.text
        });
	}
	onRejected: {
	    webViewport.enabled = true;
        webViewport.child().sendAsyncMessage("promptresponse", {
            "winid" : winId,
            "checkval" : 0,
            "accepted" : false,
            "promptvalue" : ""
            });
	}
    }
    
    Dialog {
	id: authDlg
	property alias titleText: authTitleString.text
	property alias messageText: authMessageString.text
	property alias usernameText: usernameField.text
	property int winId: 0
	title: Label { 
	    text: "Authentication required"
	    anchors.verticalCenter: parent.verticalCenter
	    font.pixelSize: 30
	    color: "white"
	}
	content: Column {
	    width: parent.width
	    spacing: 5
	    
	    Item { height: 40; width: parent.width }
	    
	    Label { 
		id: authTitleString
		color: "white"
	    }
	    
	    Label { 
		id: authMessageString 
		color: "white"
	    }
	    
	    Item { height: 20; width: parent.width }
	    
	    Label {
		text: "Username"
		color: "white"
	    }
	    
	    TextField {
		id: usernameField
		width: parent.width
		placeholderText: "username"
		
		Keys.onReturnPressed: passwordField.focus = true;
	    }
	    
	    Label {
		text: "Password"
		color: "white"
	    }
	    
	    TextField {
		id: passwordField
		width: parent.width
		placeholderText: "password"
		echoMode: TextInput.Password
		
		Keys.onReturnPressed: authDlg.accept();
	    }
	    
	    Item { height: 40; width: parent.width }
	}
	buttons: Column {
	    anchors.verticalCenter: parent.verticalCenter
	    spacing: 5
	    
	    Button {text: "OK"; onClicked: authDlg.accept(); }
	    Button {text: "Cancel"; onClicked: authDlg.reject();}
	}
	onAccepted: {
	    webViewport.enabled = true;	    
        webViewport.child().sendAsyncMessage("authresponse", {
            "winid" : winId,
            "checkval" : 0,
            "accepted" : true,
            "username" : usernameField.text,
            "password" : passwordField.text
        });
	}
	onRejected: {
	    webViewport.enabled = true;	    
        webViewport.child().sendAsyncMessage("authresponse", {
            "winid" : winId,
            "checkval" : 0,
            "accepted" : false,
            "username" : "",
            "password" : ""
        });
	}
    }
}
