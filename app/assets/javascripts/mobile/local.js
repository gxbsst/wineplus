$(document).ready(function(){
	var menu = $("header .list_btn");
	var newHeight = menu.css('height', 'auto').height();
	$("#menu_button").click(function(){
		if(menu.hasClass('close')){
			menu.removeClass('close', 2000);
			menu.height(0).animate({height: newHeight}, 300);
		}else{
			menu.animate({height: 0}, 300, function(){
				menu.addClass('close');
			});
			// menu.addClass('close', 2000);
		}
	});
});

