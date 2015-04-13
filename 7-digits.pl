#!/usr/bin/perl

# reading input file <SYM_NAME> <SEGMENTS ON hgfedcba>
$inputSyms = "./symbols";
$outputSyms = "./7-dSymbols.h";
# reading transmutting string WORD 8765431=hgfedcba WORD[8]='a'
print "Segments sequence (inversion is - before) [8dig]: ";
$IN_WORD = <STDIN>;
chop($IN_WORD);
$on = "1"; $off = "0";
if($IN_WORD =~ s/-//) {
    $on = "0"; $off = "1";
}
open outputSyms, ">$outputSyms" or die "Can't open output file $outputSyms";
print outputSyms "// segments sequence: $IN_WORD\n";
if($off) {
    print outputSyms "// inversion (common anodes)\n";
}
else {
    print outputSyms "// no inversion (common cathodes)\n";
}
for($i = 7; $i >= 0; $i--) {
    $WORD[$i] = chop($IN_WORD);
}
# making transmutting
open inputSyms, "<$inputSyms" or die "Can't open input symbols file $inputSyms";
while(<inputSyms>) {
    chop();
    if(!m/^#/ && !m/^$/) {
	if(m/\[.*\]/) { # section
	    print outputSyms "\n// $_\n";
	}
	else { # symbol
	    ($name, $code) = split / /;
	    $out = "";
	    for($j = 0; $j <= 7; $j++) {
		if($code =~ m/$WORD[$j]/) {
		    $out .= $on;
		}
		else {
		    $out .= $off;
		}
	    }
	    # encoding to 0x<HEX>
	    # write output
	    if($out =~ m/^0000/) { # first zero
		printf outputSyms "#define SYM" . $name . " 0x0%x\n", oct("0b" . $out);
	    }
	    else {
		printf outputSyms "#define SYM" . $name . " 0x%x\n", oct("0b" . $out);
	    }
	}
    }
}

