/**
 * Fivefish Javascript
 * $Id$
 *
 * @author Michael Granger <ged@FaerieMUD.org>
 *
*/


/**
 * A Bootstrap component for the index search interface. Inherits from Bootstrap's
 * modal component, and borrows a bunch of code from the typeahead component.
 *
 * @version $Rev$
 * @requires bootstrap.modal.js
 */
(function( $ ) {

	"use strict"

	/**
	 * @constructor
	 */
	var SearchBox = function( element, data, options ) {
		this.init( element, data, options );
	};


	/* Subclass the Bootstrap Modal component */
	SearchBox.prototype = $.extend( {}, $.fn.modal.Constructor.prototype, {

		constructor: SearchBox,

		searchTimeout: null,
		data: [],

		/**
		 * Initialize the component.
		 * @param {Element} element The DOM element that will be used for the quicksearch.
		 * @param {Array}   data    The RDoc search index; an Array of Objects.
		 * @param {Object}  options Configuration options. Currently ununsed.
		 */
		init: function( element, data, options ) {
			this.$element = $(element);
			this.$input = this.$element.find( '.search-input' );
			this.$meth_list = this.$element.find( '.method-search-results dl' );
			this.$mod_list = this.$element.find( '.module-search-results dl' );
			this.$file_list = this.$element.find( '.file-search-results dl' );
			this.options = options;
			this.data = data;

			this.$element.
				on( 'shown',  $.proxy(this.shown,       this) ).
				on( 'hide',   $.proxy(this.hided,       this) ).
				on( 'search', $.proxy(this.startSearch, this) ).
				on( 'clear',  $.proxy(this.clearSearch, this) );
		},

		/**
		 * Hook up events while the searchbox is visible.
		 * @private
		 */
		shown: function () {
			console.debug( "Listening for keyboard input." );
			$(document).
				on( 'keypress', $.proxy(this.keypress, this) ).
				on( 'keyup',    $.proxy(this.keyup, this) );

			if ($.browser.webkit || $.browser.msie) {
				$(document).on( 'keydown', $.proxy(this.keypress, this) );
			}
		},

		hided: function( e ) {
			console.debug( "Done listening for keyboard input." );
			$(document).off( 'keypress keyup keydown' );
		},

		keyup: function ( e ) {
			var key = e.which;
			var shifted = e.shiftKey;
			console.debug( "Keycode: %d, shifted: %o", key, shifted );

			// Control keys
			if ( e.ctrlKey ) {
				switch( key ) {
					// ctrl+u: clear the search string
					case 85:
						this.$element.trigger( 'clear' );
						break;
				}
			}

			// Append numbers, letters, and spaces to the search string
			else if ( key >= 65 && key <= 90 || key == 32 || key >= 48 && key <=57 ) {
				var text = String.fromCharCode( key );
				if ( !shifted ) text = text.toLowerCase();

				this.$input.append( text );
				this.$element.trigger( 'search' );
			}

			else {
				switch( key ) {
				// Esc
				case 27:
					this.hide();
					break;

				// Backspace
				case 8:
					this.$input.html( this.$input.html().slice(0,-1) );
					this.$element.trigger( 'search' );
					break;
				}
			}

			e.stopPropagation();
			e.preventDefault();
		},

		keypress: function ( e ) {
			console.debug( "Keypress event: %o", e );
		},

		clearSearch: function() {
			console.debug( "Clearing the search input." );
			this.$input.html('');
			this.$element.trigger( 'search' );
		},

		startSearch: function( e ) {
			var target = this;
			if ( this.searchTimeout ) {
				console.debug( "Interrupting a previous search." );
				clearTimeout( this.searchTimeout );
			}
			console.debug( "Scheduling a search..." );
			this.searchTimeout = setTimeout(function () {
				target.search();
			}, 500 );
		},

		search: function() {
			var raw_query = this.$input.html();
			console.debug( "Searching for: '%s'!", raw_query );

			if ( raw_query == '' ) {
				this.displayMatches( this.data );
			} else {
				var query = new RegExp( '.*(' + raw_query + ').*', 'i' );
				console.debug( "  pattern is: %s", query );
				var matches = $.grep( this.data, function(item) {
					console.debug( "    testing: %s", item.name );
					return query.test( item.name );
				});

				this.displayMatches( matches );
			}
		},

		displayMatches: function( matches ) {
			var methods = 0,
			    mods    = 0,
				files   = 0;
			var maxItems = 5; // :TODO: Get this from the options?
			var list;
			var searchbox = this;

			// Remove previous results
			this.$element.find( '.search-results dl' ).empty();

			// Add results until the results are full or we run out of items
			console.debug( "Sorting %d matching items...", matches.length );
			$.each( matches, function(idx, item) {
				list = null;

				switch( item['type'] ) {
					case "anymethod":
						if ( methods < maxItems ) {
							console.debug( "  adding method '%s'", item.name );
							list = searchbox.$meth_list;
							methods++;
						}
						break;

					case "normalclass":
					case "normalmodule":
						if ( mods < maxItems ) {
							console.debug( "  adding mod '%s'", item.name );
							list = searchbox.$mod_list;
							mods++;
						}
						break;

					case "toplevel":
						if ( files < maxItems ) {
							console.debug( "  adding file '%s'", item.name );
							list = searchbox.$file_list;
							files++;
						}
						break;

					default:
						console.debug( "ignoring unknown item '%s'", item['type'] );
				}

				if ( list ) {
					$('<dt>').html( item.name ).appendTo( list );
					$('<dd>').html( item.snippet ).appendTo( list );
				} else {
					console.debug( "  no more room for %s '%s'", item['type'], item.name );
				}
			});

		},

		blur: function (e) {
			var searchbox = this;
			setTimeout( function () { searchbox.hide() }, 150 );
		},

		click: function (e) {
			e.stopPropagation();
			e.preventDefault();
			this.select();
		}


	});


	/* Plugin Definition */

	$.fn.searchbox = function( data, option ) {
		return this.each(function() {
			var $this = $( this );
			var box = $this.data( 'searchbox' );
			var boxdata = typeof data == 'object' ? data : [];
			var options = $.extend( {},
				$.fn.modal.defaults,
				$this.data(),
				typeof option == 'object' && option );

			if (!box) {
				console.debug( "Creating a new searchbox for data: %s", typeof boxdata );
				box = new SearchBox( this, boxdata, options );
				$this.data( 'searchbox', box );
			}

			/* Facilitate calls like: $(sel).searchbox( 'hide' ) */
			if ( typeof data == 'string' ) box[ data ]();
		});
	};

	$.fn.searchbox.Constructor = SearchBox;
	$.fn.searchbox.defaults = $.extend({}, $.fn.modal.defaults);

})( window.jQuery );

var keyboardShortcuts = {
	'/': function(e) { $('#incremental-search').searchbox('show'); },
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
}

function hookSearchOverlay() {
	console.debug( "Setting up searchbox" );
	$('#incremental-search').searchbox( SearchIndex );
	$('#search-button').click( function() {
		$('#incremental-search').searchbox( 'show' );
	});
}

function onReady() {
	console.debug( "Ready!" );

	hookTooltips();
	hookKeyboardShortcuts();
	hookSourceToggles();
	hookSearchOverlay();
}


