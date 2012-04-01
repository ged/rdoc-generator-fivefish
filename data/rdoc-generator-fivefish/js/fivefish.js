/**
 * Fivefish Javascript
 * $Id$
 *
 * @author Michael Granger <ged@FaerieMUD.org>
 *
 */

var keyboardShortcuts = {
	'/': function(e) { $('.navbar-search input').focus(); },
	'shift+/': function(e) { $('#shortcut-help').modal(); }
}

var $window = $(window);

function initFivefish() {
	console.debug( "Loaded. Waiting for DOM to be ready." );
	$(document).ready( onReady );
}

function onReady() {
	console.debug( "Ready!" );

	$('header.hero-unit h1').popover({ placement: 'right' });
	$.each( keyboardShortcuts, function(key, callback) {
		console.debug( "Registering shortcut: %s -> %o", key, callback );
		$('body').bind( 'keyup', key, callback );
	});
}


