#!/usr/bin/perl
#++
# retriever for words in files
#--
use strict;
use warnings;
use utf8;
use Encode qw/encode decode/;
use threads;
#use JSON;
use JSON qw/encode_json decode_json/;

sub debug_print {
  #print STDERR 'debug: ',@_; #この行をコメントアウトするとデバックプリントしない
}

if ($^O eq 'MSWin32') {
  binmode STDIN, ':encoding(cp932)';
  binmode STDOUT, ':encoding(cp932)';
  binmode STDERR, ':encoding(cp932)';
} else {
  binmode STDIN,  ':utf8';
  binmode STDOUT, ':utf8';
  binmode STDERR, ':utf8';
}

my @pgm = split(/\\/, $0);
print "*** $^O Start $pgm[-1] '@ARGV' ***\n";
goto help if($#ARGV < 0);

my $retfiles = shift @ARGV;
my $retwords = shift @ARGV;
# 例外をキャッチ
eval {
  open RETFL,   "<:utf8", $retfiles  or die qq/Can't open file "$retfiles for retfiles" : $!/;
  open RETWORD, "<:utf8", $retwords  or die qq/Can't open file "$retwords" for retwords : $!/;
};
# 例外が発生した場合の処理
if ($@) {
  print "Exception occur: $@";
  exit 901;
}

my $files_json;
#while (<RETFL>) {
#  chomp($_);
#  $files_json .= encode('utf-8', $_);
#}
eval {
  local $/ = undef;
  $files_json = encode('utf-8', <RETFL>);
  #$files_json = <RETFL>;
  close(RETFL);
};
if ($@) {
  print "Exception occur: $@";
  exit 902;
}

my $files_ref = decode_json( $files_json );
#debug_print "expath: '", $files_ref->{'expath'}, "'\n";
my $expath = $files_ref->{'expath'};
debug_print "expath: '$expath'\n";
my %fileslis = %{$files_ref->{'list'}};
foreach ( sort keys %fileslis ) {
  debug_print "$_: '", $fileslis{$_}, "'\n";
}

my $words_json;
#while (<RETWORD>) {
#  chomp($_);
#  $words_json .= encode('utf-8', $_);
#}
eval {
  local $/ = undef;
  $words_json = encode('utf-8', <RETWORD>);
  #$words_json = <RETWORD>;
  close(RETWORD);
};
if ($@) {
  print "Exception occur: $@";
  exit 903;
}

my $words_ref = decode_json( $words_json );
my @name = @{$words_ref->{'name'}};
if (defined $name[0]) {
  if (defined $name[1]) {
    debug_print "name: '", $name[0], "', '", $name[1], "'\n";
  } else {
    debug_print "name: '", $name[0], "'\n";
  }
} else {
  die "no 1st word to retrieve!";
}

my @anoname = @{$words_ref->{'anothername'}};
if (defined $anoname[0]) {
  if (defined $anoname[1]) {
    debug_print "another name: '", $anoname[0], "', '", $anoname[1], "'\n";
  } else {
    debug_print "another name: '", $anoname[0], "'\n";
  }
}
my @words = (@name, @anoname);
my $wordlen = @words;
debug_print "wordlen=$wordlen\n";

print "retrieve word(s): ";
foreach (@words) {
  print "'$_' ";
}
print "\n\n";

my @gefls;
foreach ( sort keys %fileslis ) {
  debug_print "$expath$fileslis{$_}\n";
  push @gefls, $expath . $fileslis{$_};
}
debug_print  "\n\n";

my @getxt = ();
foreach (@gefls) {
  #print encode('cp932', $_), "\n";
  
  print "==== $_ ", '='x(55-length($_)), "\n";
  
  open DATAFILE, '<:encoding(cp932)', encode('cp932', $_)  or die "Open for %_ Error:$!";
  my @data = <DATAFILE>;
  if ($wordlen == 1) {
    findexact(\@data, $words[0]);
  } elsif($wordlen == 2) {
    find2words(\@data, $words[0], $words[1]);
  } else {
    find4words(\@data, $words[0], $words[1], $words[2], $words[3]);
  }
  close DATAFILE;
}
print '='x61,"\n";

exit 0;

sub findexact {
  my $data = $_[0];
  my $word = $_[1];
  my $len = @$data;
  debug_print "length=$len\n";
  for (my $i=0; $i<$len; $i++) {
    if ($data->[$i] =~ /$word/i) {
      my $ii = $i - 1;
      print "$ii) ", $data->[$i];
    }
  }
}

sub find2words {
  my $data = $_[0];
  my $w1 = $_[1];
  my $w2 = $_[2];
  my $len = @$data;
  for (my $i=0; $i<$len; $i++) {
    if ($data->[$i] =~ /(${w1}\s*${w2}|${w2}\s*${w1})/i) {
      my $ii = $i - 1;
      print "$ii) ", $data->[$i];
    }
  }
}

sub find4words {
  my $data = $_[0];
  my $w1 = $_[1];
  my $w2 = $_[2];
  my $w3 = $_[3];
  my $w4 = $_[4];
  my $len = @$data;
  for (my $i=0; $i<$len; $i++) {
    if ($data->[$i] =~ /(${w1}\s*${w2}|${w2}\s*${w1}|${w3}\s*${w4}|${w4}\s*${w3})/i) {
      my $ii = $i - 1;
      print "$ii) ", $data->[$i];
    }
  }
}

help:
print "lack of argguments - requires 2 json files\n";
print " syntax: retriever.pl  files(json-file)  words(json-file)\n";
print "  file(s) in json-file:\n";
print "   target file(s) retrieving\n";
print "  word(s) in json-file\n";
print "   a word for exact match\n";
print "   2 words for word<1 or 2> \\s* word<2 or 1> for match\n";
print "   4 words for word<1 or 2> \\s* word<2 or 1> OR for word<3 or 4> \\s* word<4 or 3> for match\n";
print "   \\s means 'whitespace' as regex";
print "   and * matches zero or more times.\n";
exit 1;
