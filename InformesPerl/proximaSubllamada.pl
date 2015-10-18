#! /usr/bin/env perl

my (@archivos);
my (@subllamadas);
my ($local);
my ($localnum);

opendir(REPOS,"$ENV{REPODIR}");
@archivos = readdir(REPOS);
closedir(REPOS);
foreach $archivo (@archivos) {
	if ( "$archivo" =~ /^subllamadas\.[0-9][0-9][0-9]$/ ) {
		($local,$localnum) = split(/\./,$archivo);
		if ( "$localnum" =~ /^0[0-9][0-9]$/ ) {
			$localnum =~ s/^(0)([0-9][0-9])$/\2/;
			if ( "$localnum" =~ /^0[0-9]$/ ) {
				$localnum =~ s/^(0)([0-9])$/\2/;
			}
		}
		push(@subllamadas,$localnum);
	}
}

if ( @subllamadas > 0 ) {
	@subllamadas = sort { $a <=> $b } @subllamadas;
	my ($proximo) = $subllamadas[$#subllamadas];
	$proximo++;
	if ( "$proximo" =~ /^[0-9]$/ ) {
		$proximo = "00".$proximo;
	}
	if ( "$proximo" =~ /^[0-9][0-9]$/ ) {
		$proximo = "0".$proximo;
	}
	print $proximo."\n";
} else {
	print "000\n";
}
