/**
 * Fivefish Javascript
 * $Id$
 *
 * @author Michael Granger <ged@FaerieMUD.org>
 *
 * Copyright © 2012, Michael Granger
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 * * Neither the name of the author/s, nor the names of the project's
 *   contributors may be used to endorse or promote products derived from this
 *   software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
*/

const MatchThreshold = 0.5;
const RankFuzziness = 0.5;

function initFivefish() {
	console.debug( "Loaded. Waiting for DOM to be ready." );
	$(document).ready( onReady );
}

function hookTooltips() {
	$('header.hero-unit h1').popover({ placement: 'right' });
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

function makeRankingTerm( item ) {
	return item.name.replace( /.*::/, '' ).toLowerCase();
}

function matchIndexItem( item ) {
	var abbrev = this.query;
	var term = makeRankingTerm( item );
	var score = term.score( abbrev, RankFuzziness );

	if ( score >= MatchThreshold ) {
		// console.debug( "Matched item %s (%s=%f)", item.name, term, score );
		return true;
	} else {
		// console.debug( "No match for item %s (%s=%f)", item.name, term, score );
		return false;
	}
}

function sortIndexItems( items ) {
	var abbrev = this.query;

	return items.sort( function(a,b) {
		var termA = makeRankingTerm( a );
		var termB = makeRankingTerm( b );
		var rankA = termA.score( abbrev, RankFuzziness );
		var rankB = termB.score( abbrev, RankFuzziness );

		if ( rankA > rankB ) {
			return -1;
		} else if ( rankA < rankB ) {
			return 1;
		}
		return 0;
	});
}

function pickItemIcon( item ) {
	var icon;

	switch( item.type ) {
	case "anymethod":
	case "metamethod":
		icon = "plus-sign";
		break;
	case "normalmodule":
		icon = "gift";
		break;
	case "normalclass":
		icon = 'briefcase'
		break;
	case "toplevel":
		icon = 'file';
		break;
	default:
		icon = 'question-sign';
	}

	return icon;
}

//{
//		"name": "save_session_data",
//		"link": "Strelka/Session/Db.html#method-c-save_session_data",
//		"snippet": "<p>Save the given <code>data</code> associated with the\n<code>session_id</code> to the DB.\n",
//		"type": "anymethod"
//},
function highlightMatchingItem( item ) {
	var snippet = item.snippet.replace(/<\/?p>/g, '').replace( /\.(.|\n)*/, '.' );
	var icon = pickItemIcon( item );
	var term = makeRankingTerm( item );
	var rank = term.score( this.query, RankFuzziness );

	var html =
		'<span class="search-item">' +
			'<i class="icon-' + icon + '"></i>' +
			'<span class="search-item-name">' + item.name + '</span>' +
			'<span class="search-item-rank">' + ( rank * 10 ).toFixed() + '</span>' +
			'<br />' +
			'<span class="search-item-snippet">' + snippet + "</span>" +
		'</span>';

	var elem = $(html);
	elem.data( 'searchitem', item );

	return elem;
}

function updateSearchInput( itemstr ) {
	var item = this.$menu.find('.active .search-item').data( 'searchitem' );
	$('#navbar-search-target').val( item.link );
	return item.name;
}

function hookSearchForm() {
	$('.navbar-search .search-query').typeahead({
		source: SearchIndex,
		matcher: matchIndexItem,
		sorter: sortIndexItems,
		updater: updateSearchInput,
		highlighter: highlightMatchingItem
	}).change( function() {
		var prefix = $('link[rel=prefix]').attr('href');
		var rel_link = $('#navbar-search-target').val();

		window.location.assign( prefix + '/' + rel_link );
	});
}


function onSearchKey( e ) {
	$('input.search-query').focus();
}

function onReady() {
	console.debug( "Ready!" );

	hookTooltips();
	hookSourceToggles();
	hookSearchForm();
	$(document).bind( 'keydown', 'ctrl+/', onSearchKey );
}


