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

	$( 'div.method header i' ).click( function(e) {
		var icon = e.target;
		var method_div = $(icon).parents( 'div' ).get(0);
		var source = $(method_div).find( 'div.method-source-code' );

		console.debug( "Toggling: %o", source );
		source.fadeToggle();
	});

	$.getJSON( 'file:///search_index.json' ).success( function( data ) {
		$( 'input.search-query' ).typeahead({
			source: data,
			matcher: function(item) {
				console.debug( "Matching %o against %o", item, this.query );
				return false;
			}
		});
	});
}


