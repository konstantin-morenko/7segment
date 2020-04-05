#!/usr/bin/perl

use feature 'switch';
use Config::Simple;

my($inWord, $verbose, $on, $off, @word, $comments, $define, $symPrefix, @sections, @fileSections, $sectionCurrent);
$on = 1; $off = 0;

sub encodeSymbol {
    ($name, $code) = split / /;
    $out = "";
    for($j = 0; $j <= 7; $j++) {
	if($code =~ m/$word[$j]/) { $out .= $on; }
	else { $out .= $off; }
    }
}

sub printSymbol {
    print outputFile $define . $symPrefix . $name . " 0b";
    printf outputFile "%08b\n", oct("0b" . $out);
}

sub outputInfo {
    print outputFile $comments . "generated with 7dgen v 1.0\n";
    print outputFile $comments . "segments sequence: @word\n";
    $off
	? print outputFile $comments . "inversion (common anodes)\n"
	: print outputFile $comments . "no inversion (common cathodes)\n";
}

sub passingArguments {
    # checking verbose
    if(m/^--help/ ~~ @ARGV) {
	print "Parameters:\n";
	print "--verbose\n";
	print "    extended output\n";
	print "--segment-sequence=<8 a-h letters sequence 7-0>\n";
	print "    set segment sequence for port (required)\n";
	print "--inversion\n";
	print "    invert output segments (typical for commmon anodes)\n";
	print "--output=<filename>\n";
	print "    set output to file <filename>\n";
	print "--comments=<comment prefix>\n";
	print "    set comment prefix to file\n";
	print "--define=<definition>\n";
	print "    set definition prefix\n";
	print "--symbol-prefix=<prefix>\n";
	print "    set symbol prefix\n";
	print "--sections=<section1[,section2...]>\n";
	print "    set sections to convert\n";
	exit;
    }
    if(m/^--verbose/ ~~ @ARGV) {
	$verbose = 1;
	print "--verbose\n";
    }
    foreach(@ARGV) {
	if(s/^--segment-sequence=//) {
	    $inWord = $_;
	    if($verbose) { print "--segment-sequence=" . $inWord . "\n"; }
	    passingSegments();
	}
	if(s/^--inversion//) {
	    $on = 0; $off = 1;
	    if($verbose) { print "--inversion\n"; }
	}
	if(s/^--output=//) {
	    $outputFile = $_;
	    if($verbose) { print "--output=$outputFile\n"; }
	}
	if(s/^--comments=//) {
	    $comments = $_;
	    if($verbose) { print "--comments=$comments\n"; }
	}
	if(s/^--define=//) {
	    $define = $_;
	    if($verbose) { print "--define=$define\n"; }
	}
	if(s/^--symbol-prefix=//) {
	    $symPrefix = $_;
	    if($verbose) { print "--symbol-prefix=$symPrefix\n"; }
	}
	if(s/^--sections=//) {
	    @sections = split /,/;
	    if($verbose) { print "--sections=@sections\n"; }
	}
    }
    if(!@word) {
	print "Have no --segment-sequence; aborting\n";
	exit;
    }
    if($outputFile =~ m/^$/) {
	if($verbose) { print "Have no output file; using defauil 7digits.h\n"; }
	$outputFile = "7digits.h";
    }
    open outputFile, ">$outputFile" or die "Can't open output file $outputFile";
    if($comments =~ m/^$/) {
	$comments = "// ";
	if($verbose) { print "Have no comments prefix, using c++ single line ($comments)\n"; }
    }
    if($define =~ m/^$/) {
	$define = "#define ";
	if($verbose) { print "Have no definition, using c++ ($define)\n"; }
    }
    if($symPrefix =~ m/^$/) {
	$symPrefix = "SYM";
	if($verbose) { print "Have no symbol prefix, using default ($symPrefix)\n"; }
    }
    if(!@sections) {
	@sections = ("main", "segments", "digits", "letters", "special");
	if($verbose) { print "Have no section definition, using default (@sections)\n"; }
    }
}

sub passingSegments {
    if(length($inWord) != 8) {
	print "The length of --segment-sequence isn't 8: " . length($inWord) . "\n";
	exit;
    }
    if($inWord =~ m/[^a-h]/) {
	print "The symbols in --segment-sequence isn't [a-h]: $inWord\n";
	exit;
    }
    for($i = 7; $i >= 0; $i--) {
	my $symbol = chop($inWord);
	if(m/$symbol/ ~~ @word) {
	    print "The symbols [a-h] isn't unique: $symbol\n";
	    exit;
	}
	else { $word[$i] = $symbol; }
    }
}

Config::Simple->import_from('7digits.conf', \%Config);

if(exists($Config{"Segments.Sequence"})) {
    $inWord = $Config{"Segments.Sequence"};
    passingSegments();
}
if(exists($Config{"Segments.Commons"})) {
    if($Config{"Segments.Commons"} =~ m/Anodes/) {
	$on = 0; $off = 1;
    }
    if($Config{"Segments.Commons"} =~ m/Cathodes/) {
	$on = 1; $off = 0;
    }
}
if(exists($Config{"Segments.Output file"})) {
    $outputFile = $Config{"Segments.Output file"};
}
if(exists($Config{"Segments.Comment prefix"})) {
    $comments = $Config{"Segments.Comment prefix"};
}
if(exists($Config{"Segments.Definition"})) {
    $define = $Config{"Segments.Definition"};
}
if(exists($Config{"Segments.Symbol prefix"})) {
    $symPrefix = $Config{"Segments.Symbol prefix"};
}

passingArguments();

# reading input file <SYM_NAME> <SEGMENTS ON hgfedcba>
$inputSyms = "./symbols";

# making transmutting
open inputSyms, "<$inputSyms" or die "Can't open input symbols file $inputSyms";

outputInfo($inWord, $off);
while(<inputSyms>) {
    chop();
    given($_) {
	when (/^\#/) {} # comments
	when (/^$/) {} # empty lines
	when (/\[.*\]/) { # section
	    s/\[//; s/\]//;
	    $sectionCurrent = $_;
	    if(m/$sectionCurrent/ ~~ @sections) { print outputFile "\n" . $comments . "[$_]\n"; }
	    push(@fileSections, $sectionCurrent);
	}
	default { # symbol
	    if(m/$sectionCurrent/ ~~ @sections) { # only if turned on
		encodeSymbol();
		printSymbol();
	    }
	}
    }
}

foreach(@sections) {
    if(!(m/$_/ ~~ @fileSections)) {
	print "Section '$_' have no definition in file $inputSyms\n";
    }
}

