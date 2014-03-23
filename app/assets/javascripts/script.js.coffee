$(document).ready ->
	curBg = 0
	$('#mainMenu ul li').mouseover ->
		$('#mainMenu div div').eq(curBg).css('left','-2000px')
		curBg = $(this).index()
		$('#mainMenu div div').eq(curBg).css('left','0')
	
	$('#secondMenu ul li').mouseover ->
		$('#secondMenu div div').eq(curBg).css('left','-2000px')
		curBg = $(this).index()
		$('#secondMenu div div').eq(curBg).css('left','0')
		
	$('#mainMenu').mouseover -> $('#secondMenu ul').css('display','none')
	$('#secondMenu').mouseover ->$('#secondMenu ul').css('display','')