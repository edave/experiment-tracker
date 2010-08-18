function passwordHelper(passwordElement, confirmElement, username){
	var validationElements = new Array();
	validationElements["confirm"] = jQuery("div#pwd-valid-confirm");
    validationElements["len"] = jQuery("div#pwd-valid-len");
    validationElements["caps"] = jQuery("div#pwd-valid-caps");
    validationElements["num"] = jQuery("div#pwd-valid-num");
    validationElements["login"] = jQuery("div#pwd-valid-login");
    
    if (typeof(username) == 'string') {
        new Form.Element.Observer(passwordElement.attr('id'), 0.3, function(element, value){
            passwordHelperComparer($(element).value, jQuery(confirmElement).attr('value'), username, validationElements);
        });
        new Form.Element.Observer(confirmElement.attr('id'), 0.3, function(element, value){
            passwordHelperComparer(jQuery(passwordElement).attr('value'), $(element).value, username, validationElements);
        });
    }
    else {
        new Form.Element.Observer(passwordElement.attr('id'), 0.3, function(element, value){
            passwordHelperComparer($(element).value, jQuery(confirmElement).attr('value'), jQuery(username).attr('value'), validationElements);
        });
        new Form.Element.Observer(confirmElement.attr('id'), 0.3, function(element, value){
			passwordHelperComparer(jQuery(passwordElement).attr('value'), $(element).value, jQuery(username).attr('value'), validationElements);
        });
        new Form.Element.Observer(username.attr('id'), 0.3, function(element, value){
            passwordHelperComparer(jQuery(passwordElement).attr('value'), jQuery(confirmElement).attr('value'), $(element).value, validationElements);
        });
    }
}

function passwordHelperComparer(passwordValue, confirmValue, usernameValue, validationElements){
    var successClassName = 'validation-success';
    var errorClassName = 'validation-error';
    
    var errorElements = new Array();
    var successElements = new Array();
    
	// Confirm password check
    if (passwordValue == confirmValue) {
        successElements.push(validationElements["confirm"]);
    }
    else {
        errorElements.push(validationElements["confirm"]);
    }
    
    //Length check
    if (passwordValue.length >= 6) {
        successElements.push(validationElements["len"]);
    }
    else {
        errorElements.push(validationElements["len"]);
    }
    
    // Username check    
    if (passwordValue != usernameValue) {
		 successElements.push(validationElements["login"]);
    }
    else {
        errorElements.push(validationElements["login"]);
    }
	
	// Confirm check
	if (passwordValue == confirmValue) {
        successElements.push(validationElements["confirm"]);
    }
    else {
        errorElements.push(validationElements["confirm"]);
    }
	
	// Num Check
	if (passwordValue.match(/\d+/)) {
        successElements.push(validationElements["num"]);
    }
    else {
        errorElements.push(validationElements["num"]);
    }
	
	// Caps Check
	if (passwordValue.match(/[A-Z]/)) {
        successElements.push(validationElements["caps"]);
    }
    else {
        errorElements.push(validationElements["caps"]);
    }
   
	 for (var i=0; i < errorElements.length; i++) {
	 	var errorElement = errorElements[i];
		errorElement.removeClass(successClassName);
        errorElement.addClass(errorClassName);
    }
   
	for (var j=0; j < successElements.length; j++) {
	 	var successElement = successElements[j];
		successElement.removeClass(errorClassName);
        successElement.addClass(successClassName);
    }
}