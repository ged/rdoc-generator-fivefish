# -*- rake -*-

require 'rake/clean'

FONTSRC     = ASSETDIR + 'fonts'
TTF_FONTS   = FileList[ (FONTSRC + '*.ttf').to_s ]
WOFF_FONTS  = TTF_FONTS.pathmap( (FONTSDIR + "%n.woff").to_s )

LICENSE_SRC = FONTSRC + 'OFL.txt'
LICENSE     = LICENSE_SRC.to_s.pathmap( (FONTSDIR + '%f').to_s )

task :assets => [ LICENSE, *WOFF_FONTS ]

# Generate WOFF fonts from the source TTF ones
rule '.woff' => [
	proc {|woff| woff.pathmap( (FONTSRC + "%n.ttf").to_s )},
	FONTSDIR.to_s
] do |task|
	sh 'sfnt2woff', task.source
	mv task.source.pathmap( '%X.woff' ), FONTSDIR, :verbose => true
end
CLEAN.include( WOFF_FONTS )

file LICENSE => LICENSE_SRC do |task|
	cp task.prerequisites.first, task.name, verbose: true
end
CLEAN.include( LICENSE )


