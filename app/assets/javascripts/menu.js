sfHover = function() {
	var sfEls = document.getElementById("nav").getElementsByTagName("li");
	for (var i=0; i<sfEls.length; i++) {
		sfEls[i].onmouseover=function() {
			this.className+=" sfhover";
		}
		sfEls[i].onmouseout=function() {
			this.className=this.className.replace(new RegExp(" sfhover\\b"), "");
		}
	}
}
if (window.attachEvent) window.attachEvent("onload", sfHover);

function LoginMgr() {
	this._userTypes = ["registered", "existing", "new"];
}

LoginMgr.prototype.setUserType = function(userType) {
	this._userType = userType;
	for( var i=0; i<this._userTypes.length; i++ ) {
		document.getElementById(this._userTypes[i]).style.display = userType == this._userTypes[i] ? "inline" : "none";
	}
}