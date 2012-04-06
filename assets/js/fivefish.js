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
	var SearchBox = function( element, options ) {
		this.init( 'searchbox', element, options );
	};


	/* Subclass the Bootstrap Modal component */
	SearchBox.prototype = $.extend( {}, $.fn.modal.Constructor.prototype, {

		constructor: SearchBox,

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
			this.data( data );
			this.listen();
		},

		/**
		 * Set the search index data for the searchbox to {newdata}.
		 * @param {Array} newdata The new RDoc search index data.
		 * @returns The current data.
		 * @type Array
		 */
		data: function( newdata ) {
			if ( newdata ) {
				console.debug( "Populating searchbox with index data: %o", newdata );
				this.data = newdata;
			}
			return this.data;
		},

		/**
		 * Attach event listeners to the searchbox.
		 * @private
		 */
		listen: function () {
			this.$element.
				on( 'blur',     $.proxy(this.blur, this) ).
				on( 'keypress', $.proxy(this.keypress, this) ).
				on( 'keyup',    $.proxy(this.keyup, this) );

			if ($.browser.webkit || $.browser.msie) {
				this.$element.on('keydown', $.proxy(this.keypress, this) );
			}
		},

		keyup: function ( e ) {
			var key = e.which;
			console.debug( "Keycode: %d", key );

			if ( key === 27 ) this.hide();

			e.stopPropagation();
			e.preventDefault();
		},

		keypress: function ( e ) {
			if ( !this.shown ) return;

			switch( e.keyCode ) {
				case 9: // tab
				case 13: // enter
				case 27: // escape
					e.preventDefault();
					break;

				case 38: // up arrow
					e.preventDefault();
					this.prev();
					break;

				case 40: // down arrow
					e.preventDefault();
					this.next();
					break;
			}

			e.stopPropagation();
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


