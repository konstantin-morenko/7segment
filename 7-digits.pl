#!/usr/bin/perl

use Switch;

my($inWord, $verbose, $on, $off, @word, $comments, $define);
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
    print outputFile $define . "SYM" . $name . " 0x";
    if($out =~ m/^0000/) { print outputFile "0"; } # first zero
    printf outputFile "%x\n", oct("0b" . $out);
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
	if($verbose) { print "Have no comments prefix, using c++ single line (//)\n"; }
	$comments = "// ";
    }
    if($define =~ m/^$/) {
	if($verbose) { print "Have no definition, using c++ (#define)\n"; }
	$define = "#define ";
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

passingArguments();

# reading input file <SYM_NAME> <SEGMENTS ON hgfedcba>
$inputSyms = "./symbols";

# making transmutting
open inputSyms, "<$inputSyms" or die "Can't open input symbols file $inputSyms";

outputInfo($inWord, $off);
while(<inputSyms>) {
    chop();
    switch($_) {
	case /^\#/ {} # comments
	case /^$/ {} # empty lines
	case /\[.*\]/ { # section
	    print outputFile "\n" . $comments . "$_\n";
	}
	else { # symbol
	    encodeSymbol();
	    printSymbol();
	}
    }
}

