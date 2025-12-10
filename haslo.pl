#my @alphabet = split//, "_AEIOZSLNCWRYTKMDPJUBGHFVXQ";
my @alphabet = split//, "_AIEOZNSLRWCYTKMDPUJBGHFXVQ";
#my @alphabet = split//, "ZS_KDBOUFVQPLCNTRJHMEWAYGIX";
my @msg = split//, "ABCDEFGHIJKLMNOPQRSTUVWXYZ_";
my %characters;
my %twowords;
my %my_biwords;
my %my_triwords;
my %my_quadrwords;
my %my_hexwords;
my %my_siedem;
my @biwords = qw(
   NA ZE TO DO PO BO JA ZA CO OD GO MU MI TU BY ON CI KU AZ IM MA 
);

my @triwords = qw(
SIE NIE ALE PAN TAK JAK JUZ JEJ BYL ZAS DLA TYM ICH GDY NIM POD TAM NAD SAM TEZ
);
my @quadwords = qw(
BYLO JEGO MNIE WIEC PANA PRZY JEST LECZ TEGO JAKO BYLA MOZE OCZY MALY JENO PANI AZJA CZYM MIAL ZEBY
);

my @pentawords = qw (
RZEKL BASIA TYLKO PRZEZ SOBIE TERAZ PRZED ZARAZ KTORY JESLI POTEM KTORA NIEGO NAGLE NAWET JAKBY KTORE LUDZI NIECH GDZIE
);

my @hexawords = qw (
BEDZIE RYCERZ POCZAL CHWILI JEDNAK MIEDZY MICHAL WACPAN BARDZO WIECEJ
);


open  $plik, '<', $ARGV[0] or die "Nie mogę otworzyć pliku: $!\n";
while (my $linia = <$plik>) {
    chomp $linia;  # Usuwanie nowej linii
    #my @slowa = split ' ', $linia;    #To jest _bardzo_ użyteczne
    #for my $w (@slowa) {
    #    if(length($w) == 2) {
    #        $twowords{$w} +=1;
    #    }
    #    if (length($w) == 2){ $my_biwords{$w} +=1;}
    #    elsif (length($w) == 3){ $my_triwords{$w} +=1;}
    #    elsif (length($w) == 4){ $my_quadrwords{$w} +=1;}
    #    elsif (length($w) == 5){ $my_pentawords{$w} +=1;}
    #    elsif (length($w) == 6){ $my_hexwords{$w} +=1;}
    #}
    my @chars = split //, $linia;
    for my $c (@chars) {
        #if($c eq " ") {
        #    $characters{"_"} +=1;
        #}
        # else {
            $characters{$c} += 1;#}
    #
    }
}

close $plik;
my @klucze_posortowane = sort { $characters{$b} <=> $characters{$a} } keys %characters;
my @c_keys = keys %characters;
my $space = $klucze_posortowane[0];
open  $plik, '<', $ARGV[0] or die "Nie mogę otworzyć pliku: $!\n";
while (my $linia = <$plik>) {
    chomp $linia;  # Usuwanie nowej linii
    my @slowa = split $space, $linia;    #To jest _bardzo_ użyteczne
    for my $w (@slowa) {
        if(length($w) == 2) {
            $twowords{$w} +=1;
        }
        if (length($w) == 2){ $my_biwords{$w} +=1;}
        elsif (length($w) == 3){ $my_triwords{$w} +=1;}
        elsif (length($w) == 4){ $my_quadrwords{$w} +=1;}
        elsif (length($w) == 5){ $my_pentawords{$w} +=1;}
        elsif (length($w) == 6){ $my_hexwords{$w} +=1;}
        elsif (length($w) == 7){$my_siedem{$w} +=1;}
    }
}
close $plik;
for my $c (@c_keys) {
    #print "Klucz $c wartosc $characters{$c}\n";
}
# posortuj klucze po wartościach malejąco
#sub getsorted {
#    ($dict) = @_;
#    return sort { $dict{$b} <=> $dict{$a} } keys %dict;
#}
sub decrypt {
    my (%dict, $message) = @_;
    my $r = "";
    for my $c (split //, $message) {
        $r = $r . $dict{$c};
    }
    return $r;
}
sub getsorted {
    my %dict = @_;
    return sort { $dict{$b} <=> $dict{$a} } keys %dict;
}

my @sorted_bikeys = getsorted(%my_biwords);
my @sorted_trikeys = getsorted(%my_triwords);
my @sorted_quadkeys = getsorted(%my_quadrwords);
my @sorted_pentakeys =getsorted(%my_pentawords);
my @sorted_hexkeys = getsorted(%my_hexwords);
my @sorted_siedem = getsorted(%my_siedem);
my $limit = 20;#@sorted_bikeys < 20 ? @sorted_bikeys : 20;
my $hexlimit = 10;
my $pentalimit =10;
my @top_bikeys = @sorted_bikeys[0 .. $limit-1];
my @top_trikeys = @sorted_trikeys[0 .. $limit-1];
my @top_quadkeys = @sorted_quadkeys[0 .. $limit-1];
my @top_pentakeys = @sorted_pentakeys[0 .. $pentalimit-1];
my @top_hexkeys = @sorted_hexkeys[0 .. $hexlimit-1];
my @top_siedem = @sorted_siedem[0..$hexlimit-1];
# wypisz
foreach my $key (@top_hexkeys) {
    print "$key => $my_hexwords{$key}\n";
}
close $plik;

#TUTAJ
#ANALIZA CZESTOTLIWOSCIOWA DLA LITER WYSTEPUJACYCH W TEKSCIE
#my @klucze_posortowane = sort { $characters{$b} <=> $characters{$a} } keys %characters;
#my @c_keys = keys %characters;
#for my $c (@c_keys) {
#    #print "Klucz $c wartosc $characters{$c}\n";
#}
my $n = $#msg;
my @tablica = (undef) x $n;

my %good_decipher;
my %test_cipher;
#TUTAJ CZEGOS NIE ROZUMIEM, Z JAKIEGOS POWODU
# W GOOD_DECIPHER MAMY TERAZ METODE SZYFROWANIA ABCDEFGHIJKLMNOPRSTUVWXYZ_
#MI SIE WYDAJE ZE POWINO BYĆ TAK JAK OPISUJE W PONIZSZYM OPISIE
#NAZW NEI ZMIENIAM, BO DLUGO NAD TYM PRACOWALEM I JESTEM DO NICH PRZYZWYCZAJONY
#REASUUMAC GDYBYSMY UZYLI GOOD_DECIPHER, NA ZASZYFROWANEJ WIDOMOSC, TO ZASZYFROWALIBSMY JA RAZ JESZCZE

#PONIZSZY KOMENTARZ NIE ZROZUMIANY PRZEZE MNIE
#GENERUJEMY SZYFR, W SENSIE MATCHUJEMY SLOWA PO CZESTOTLIWOSCIACH
# ALPHABET TO: _AIEOZNSLRWCYTKMDPUJBGHFXVQ
#W KLUCZE_POSORTOWANE[I] JEST ITA W KOLEJNOSCI MALEJACEJ 
#NAJCZESCIEJ WYSTEPUJACA LITERA
my %new_c;
#for my $i (@msg) {
#    $good_decipher{$i} = $i;
#}
for my $i (0..$#alphabet){
    $good_decipher{$alphabet[$i]} = $klucze_posortowane[$i];

}
#CZYLI TERAZ, CIPHER TO MASZYNKA KTORA MAJAC ZASZYFROWANA LITERE, ZWRACA JEJ DESZYFR


#TEGO UZYWAMY ABY ODSZYFROWAC ZASZYFROWANY TEKST
my %cipher;
for my $key (keys %good_decipher) {
    $cipher{$good_decipher{$key}} = $key;
}
#SZYFRUJEMY ABCDEFGHIJKLMNOPRSTUVWXYZ_
for my $c (@msg) {
    print "$good_decipher{$c}";
}
print "\n";
#print "\n";
#print "$top_hexkeys[0]\n";
#my $r = "";
#    for my $c (split //, $top_hexkeys[0]) {
#        $r = $r . $cipher{$c};
#    }
#print "$r\n";

#expected SEFNKYWA_HCVRODJXPUTMGQILBZ

##SEFNKYWA_HCVRODJXPUTMGQILBZ
##SEPRKYWA_MNFTODJVUCHIQGLBZ
#
#
##SEPRKYWA_MNFTODJVUCHIQGLBZ 
##ZEPRKYWA_MNFTOBJVUCHIQGLDS
#sub decrypt {
#    my (%dict, $message) = @_;
#    my $r = "";
#    for my $c (split //, $message) {
#        $r = $r . $dict{$c};
#    }
#    return $r;
#}


sub isIn { 
    my ($a, @A) = @_;
    if (grep { $_ eq $a } @A) {
        return 1;
    }
    else {
        return 0;
    }
}
sub decrypt {
    my ($dict_ref, $message) = @_;
    my %dict = %{$dict_ref};
    my $r = "";
    for my $c (split //, $message) {
        $r .= $dict{$c} // '';  # use // to avoid undef warnings
    }
    return $r;
}
sub score {
   # my ($dict_ref, @encrypted, @real) = @_;
    my ($dict_ref, $encrypted_ref, $real_ref) = @_;
    my @encrypted = @$encrypted_ref;
    my @real      = @$real_ref;
    #my %dict = %{$dict_ref};
    my $matches = 0;
    for my $wrd (@encrypted) {
        #my $r = "";
        #for my $c (split //, $wrd) {
        #    $r = $r . $dict{$c};
        #}
        my $r = decrypt($dict_ref,$wrd);
        #print "Analizuje teraz $r\n";
        if(isIn($r,@real)) {
            $matches +=1;
        }
    }
    return $matches;
}
print "$top_hexkeys[0]\n";
my $r = decrypt(\%cipher, $top_hexkeys[0]);
print "$r\n";

my $rr = isIn($biwords[0],@biwords);
print "$rr\n";
my $rrr = score(\%cipher,\@top_bikeys,\@biwords);
print "$rrr \n";
my %current_best= %cipher;
my $best_score = score(\%cipher,\@top_bikeys,\@biwords);
for my $i (2..$#klucze_posortowane){
    my $candidate_a = $klucze_posortowane[$i-1];
    my $candidate_b = $klucze_posortowane[$i];
    my $ca_counter = $characters{$candidate_a};
    my $cb_counter = $characters{$candidate_b};
    my $condition = $cb_counter - $ca_counter;
    if ($condition <=1000) {
        #my %new_cipher = %current_best;
        my %new_cipher;
        my $tmp = $klucze_posortowane[$i];
        $klucze_posortowane[$i] = $klucze_posortowane[$i-1];
        $klucze_posortowane[$i-1] = $tmp;
        for my $i (0..$#alphabet){
            $new_cipher{$alphabet[$i]} = $klucze_posortowane[$i];
        }
        my %nc;
        for my $key (keys %new_cipher) {
            $nc{$new_cipher{$key}} = $key;
        }
        #$new_cipher{$alphabet[$i]} = $klucze_posortowane[$i-1];
        #$new_cipher{$alphabet[$i-1]}=$klucze_posortowane[$i];
        my $check = score(\%nc,\@top_bikeys,\@biwords);
        #print "$check current best $best_score\n";
        if( $check>$best_score) {
            $best_score = $check;
            %current_best = %nc;
        }
        else {
            my $tmp = $klucze_posortowane[$i];
            $klucze_posortowane[$i] = $klucze_posortowane[$i-1];
            $klucze_posortowane[$i-1] = $tmp;
        }
    }
    else {
        next;
    }
}


my %new_c;
#for my $i (@msg) {
#    $new_c{$i} = $i;
#}

for my $k (keys %current_best) {
    $new_c{$current_best{$k}} = $k;
}

for my $c (@msg) {
    print "$new_c{$c}";
}
print "\n";
for my $c (split//, "ZAGLOBA") {
    print "$current_best{$c}";
}
print "\n";
print "$top_siedem[0]\n";
#ABCDEFGHIJKLMNOPRSTUVWXYZ_
#SEFNKYWA_HCVRODJXPUTMGQILBZ
#SEPTKYWA HCFRODJXVUNMIQGLBZ
#SEPRKYWA MNFTODJXVUCHIQGLBZ
#SEPRKYWA MNLMTDJXVUCHIQGLBZ
#SEPRKYFA MNLMODJXVUCHIQGLBZ
#SEPRKYWA MNTDJXVUCHIQGLBZ
#SEPRKYWA MNTDJVUCHIQGLBZ
#SEPRKYFA MNTODJVUCHIQGLBZ