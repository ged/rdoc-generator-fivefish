/**
 * Fivefish Javascript
 * $Id$
 *
 * @author Michael Granger <ged@FaerieMUD.org>
 *
 */

var $window = $(window);

function initFivefish() {
	$(document).ready( onReady );
}

function onReady() {
	console.debug( "Ready!" );

	$(window).scroll( onScroll );
}

function onScroll( e ) {
	if ( $('.subnav').length ) {
		console.debug( "Offset is: %d", $('.subnav').offset().top );
	}
}

