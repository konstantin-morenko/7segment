#!/usr/bin/perl

# TODO
# sectors (nums, signs, letters)
# control of errors in segment string

# reading input file <SYM_NAME> <SEGMENTS ON hgfedcba>
$inputSyms = "./symbols";
$outputSyms = "./7-dSymbols.h";
# reading transmutting string WORD 8765431=hgfedcba WORD[8]='a'
print "Segments sequence: ";
$IN_WORD = <STDIN>;
chop($IN_WORD);
open outputSyms, ">$outputSyms" or die "Can't open output file $outputSyms";
print outputSyms "// segments sequence: $IN_WORD\n";
print "# ";
for($i = 7; $i >= 0; $i--) {
    $WORD[$i] = chop($IN_WORD);
    print "$WORD[$i]";
}
print " 0x\n";
# making transmutting
open inputSyms, "<$inputSyms" or die "Can't open input symbols file $inputSyms";
while(<inputSyms>) {
    ($name, $code) = split / /;
    $out = "";
    for($j = 0; $j <= 7; $j++) {
	if($code =~ m/$WORD[$j]/) {
	    $out .= '1';
	}
	else {
	    $out .= '0';
	}
    }
    print "$name $out ";
    # encoding to 0x<HEX>
    # write output
    printf outputSyms "#define SYM" . $name . " 0x%x\n", oct("0b" . $out);
}

