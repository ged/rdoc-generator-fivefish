/**
 * Fivefish Javascript
 * $Id$
 *
 * @author Michael Granger <ged@FaerieMUD.org>
 *
 */

var searchIndex = [];

var keyboardShortcuts = {
	'/': function(e) { $('.navbar-search input').focus(); },
	'shift+/': function(e) { $('#shortcut-help').modal(); }
}

function initFivefish() {
	console.debug( "Loaded. Waiting for DOM to be ready." );
	$(document).ready( onReady );
}

function hookTooltips() {
	$('header.hero-unit h1').popover({ placement: 'right' });
}

function hookKeyboardShortcuts() {
	$.each( keyboardShortcuts, function(key, callback) {
		console.debug( "Registering shortcut: %s -> %o", key, callback );
		$('body').bind( 'keyup', key, callback );
	});
}

function hookSourceToggles() {
	$( 'div.method header i' ).click( function(e) {
		var icon = e.target;
		var method_div = $(icon).parents( 'div' ).get(0);
		var source = $(method_div).find( 'div.method-source-code' );

		console.debug( "Toggling: %o", source );
		source.fadeToggle();
	});
}



function doIncrementalSearch() {
	$('#incremental-search').
		modal().
		success( function() {
			this.bind( 'keyup', 
		});
}

function hookSearchOverlay() {
	$('#search-button').click( doIncrementalSearch );
}

function onReady() {
	console.debug( "Ready!" );

	hookTooltips();
	hookKeyboardShortcuts();
	hookSourceToggles();
	hookSearchOverlay();
}


