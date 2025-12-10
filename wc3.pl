#!/usr/bin/perl
use bytes;
#-m
sub count_characters {
    my $characters_counter = 0;
    my $plik = @_[0];
    while (my $linia = <$plik>) {
        $characters_counter += length($linia);
    }
    return $characters_counter;
}

#-c
sub count_bytes {
    my $plik = @_[0];
    my $byte_size = 0;
    if (!($ARGV[0] eq "-")) {
        $byte_size = -s $plik;
    }
    else {
        while (my $linia = <$plik>) {
            $byte_size += bytes::length($linia);
        }
    }
    return $byte_size; 
}

sub count_words {
    my $words_counter = 0;
    my $plik = @_[0];
    while (my $linia = <$plik>) {
        chomp $linia;  # Usuwanie nowej linii
        my @slowa = split ' ', $linia; 
        #my @slowa = split /\s+/, $linia; 
        $words_counter += scalar(@slowa);
    }
    return $words_counter;
}
sub count_newlines {
    my $newline_counter = 0;
    my $plik = @_[0];
    while (my $linia = <$plik>) {
        $newline_counter += chomp $linia;
    }
    return $newline_counter;
}

sub count_top_ten_words {
    my %words_table;
     my $plik = @_[0];
    while (my $linia = <$plik>) {
        chomp $linia;  # Usuwanie nowej linii
        if($i_flag) {
            $linia = lc($linia);
        }
        my @slowa = split ' ', $linia;   # split ' ' ignoruje puste elementy
        #my @slowa = split /\s+/, $linia;    #To jest _bardzo_ użyteczne
        foreach my $slowo (@slowa) {
            #my $a = $words_table{$slowo};
            #print $a;
            $words_table{$slowo} = $words_table{$slowo} +1;
        }
    }
    #my @xx = keys %words_table;
    #print $xx[0];
    #print $words_table{$xx[0]};
    my @klucze_posortowane = sort { $words_table{$b} <=> $words_table{$a} } keys %words_table;
    for my $i (0 .. $#klucze_posortowane) {
        last if $i >= 10;  # zatrzymaj po 10 elementach
        $formatted = $klucze_posortowane[$i];
        $formatted =~ s/[^A-Za-z]/?/g;
        print "$formatted $words_table{$klucze_posortowane[$i]}\n";
    }
}

my %word_counter;
#my $plik = STDIN;
use Getopt::Std;
my $m_flag = 0;
my $c_flag = 0;
my $w_flag = 0;
my $l_flag = 0;
my $p_flag = 0;
my $none_flag = 1;
$i_flag=0;
my %opts;
getopts('cmliwp', \%opts);

if ($opts{c}) {
    $c_flag=1;
    $none_flag = 0;
}
if ($opts{m}) {
    $m_flag = 1 ;
    $none_flag = 0;
}
if ($opts{l}) {
    $l_flag=1;
    $none_flag = 0;
}
if ($opts{i}) {
    $i_flag=1;
    $none_flag = 0;
}
if ($opts{w}) {
    $w_flag = 1;
    $none_flag = 0;
}
if ($opts{p}) {
    $p_flag=1;
    $none_flag = 0;
}
my $plik;
if ($ARGV[0] eq "-") {
    $plik = STDIN;
    #print "h";
}
else {
    open  $plik, '<', $ARGV[0] or die "Nie mogę otworzyć pliku: $!\n";
}
my $c_counter = count_characters($plik);
my $b_counter = count_bytes($plik);;
my $w_counter = count_words($plik);
my $nl_counter = count_newlines($plik);

if($m_flag) {
    #print "m_flag";
    my $c = count_characters($plik);
    print $c;
}
if($c_flag) {
    my $c = count_bytes($plik);
    print $c;
}
if($w_flag) {
    my $c = count_words($plik);
    print $c;
}
if($l_flag) {
    my $c = count_newlines($plik);
    print $c;
}
if($p_flag) {
    count_top_ten_words($plik);
}
if (!($ARGV[0] eq "-")) {
    close $plik;
}
if($none_flag) {
    print " $nl_counter  $w_counter  $b_counter";
    if (!($ARGV[0] eq "-")) {
        print " $ARGV[0]\n";
    }
}
