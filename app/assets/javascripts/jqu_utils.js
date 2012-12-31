/* Image rotater */
var jqu_rotate_time_out;
var jqu_images;

function rotate_images(images) {
	jqu_images = images;
	var block = $("#" + images.block);
	block.css({width: images.width + "px", height: (images.height + 24) + "px", background: "#444"});
	block.append("<div class='jqu_imageholder'></div>");
	var imageHolder = $('#' + jqu_images.block + ' .jqu_imageholder');
	imageHolder.css({width: images.width + "px", height: images.height + "px"});
	block.append("<div class='jqu_controlbar'></div>");
	var controlbar = $('#' + jqu_images.block + ' .jqu_controlbar');
	controlbar.css({width: images.width + "px", height: 24 + "px", background: "#444"});
	controlbar.append("<div></div>");
	for( var i=0; i<images.images.length; i++ ) {
		var f = images.images[i];
		imageHolder.append("<div><img src='" + f.src + "' alt='" + f.alt + "' width='" + images.width + "' height='" + images.height + "'></div>");
		$('.jqu_controlbar div').append("<span>&nbsp;" + (i + 1) + "&nbsp;</span>");
	}
	$('.jqu_controlbar div span').click(function() {
		jqu_rotate($(this).index());
	});

	block.addClass('jqu_slideshow');
	$("#" + images.block + ' .jqu_imageholder div:first').addClass('curr');
	$("#" + images.block + ' .jqu_controlbar div span:first').addClass('curr');
	rotate_time_out = setTimeout("jqu_rotate()", 5000);
};

function jqu_rotate(index) {
	clearTimeout(jqu_rotate_time_out);
	var curr = $("#" + jqu_images.block + ' .jqu_imageholder div.curr');
	var spancurr = $("#" + jqu_images.block + ' .jqu_controlbar div span.curr');
	var next = index ? $("#" + jqu_images.block + ' .jqu_imageholder div:eq(' + index + ')') : curr.next();
	var spannext = index ? $("#" + jqu_images.block + ' .jqu_controlbar div span:eq(' + index + ')') : spancurr.next();
	if( next.length < 1 ) {
		next = $("#" + jqu_images.block + ' .jqu_imageholder div:first');
	}
	if( spannext.length < 1 ) {
		spannext = $("#" + jqu_images.block + ' .jqu_controlbar div span:first');
	}
	curr.removeClass('curr').addClass('prev');
	spancurr.removeClass('curr');
	spannext.addClass('curr');
	next.css({opacity: 0.0}).addClass('curr').animate({opacity: 1.0}, 1000, function() {
		curr.removeClass('prev');
	});
	jqu_rotate_time_out = setTimeout("jqu_rotate()", 5000);
}

