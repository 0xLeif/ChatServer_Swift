//Hold a chat.
var chat = new Webchat(window.location.host);

//Define what a chat is.
function Webchat(hostname) {
	
	//Declarations
	var chat = this;
	var username = "";
	var displayName = "";
	var avatar = "";
	
	//Start Lifecycle
	chat.socket = new WebSocket('ws://' + hostname + '/chat', 'chat');
	
	//Start Chat Sequence On New Chat
	chat.socket.onopen = function() {
		chat.promptUserInfo();
	}
	
	//Get & Send Basic Info to Server
	chat.promptUserInfo = function() {
		while (!displayName) {
			displayName = prompt('What do you want to be called?');
		}
		chat.start(displayName);
	}
	
	//Actually setup the chat window and start talking
	chat.start = function(handle) {
		var json = JSON.stringify({"handle": handle});
		chat.socket.send(json);
		showChatWindow(); //This triggers the animation that shows the main window, defined in animations.js
	}
	
	//Append New Messages to the Chat Window
	chat.appendMessage = function(message, selfSent) {
		
		var messageSection = document.querySelector('.messages');
		
		var div = document.createElement('div');
		div.className = 'message';
		
		var span = document.createElement('span');
		span.innerHTML = message;
		
		if (selfSent) {
			div.className += ' self';
		}
		div.appendChild(span);
		
		messageSection.appendChild(div);
		messageSection.scrollTop = messageSection.scrollHeight;
	}
	
	//Send New Messages to Server
	chat.sendMessage = function(message) {
		var json = JSON.stringify({"handle": handle, "message": message});
		chat.socket.send(json);
	}
	
	//Receive New Messages from the Server
	chat.socket.onmessage = function(received) {
		var jsonAry = JSON.parse(received.data);
		var message = jsonAry["message"];
		var selfSent = false;
		chat.appendMessage(message, selfSent);
	}
	
	//Handle Chat Text Submission
	$('form').on('submit', function(form) {
				 form.preventDefault();
				 
				 var text = $('.sendbar-input').val();
				 
				 chat.appendMessage(text, true);
				 chat.sendMessage(text);
				 
				 $('.sendbar-input').val('');
				 });
};
