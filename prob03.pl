#!/usr/bin/perl

my @matrix_a = ();
my @matrix_b = ();
my @matrix_c = ();
open my $plik, '<', $ARGV[0] or die "Nie mogę otworzyć pliku: $!\n";
while (my $linia = <$plik>) {
    chomp $linia;  # Usuwanie nowej linii
    my @slowa = split /\s+/, $linia;    #To jest _bardzo_ użyteczne
    #print "$linia\n";
    my @row = ();
    foreach my $slowo (@slowa) {
        push @row, $slowo;
    }
    push @matrix_a, \@row;
}
close $plik;
open my $plik, '<', $ARGV[1] or die "Nie mogę otworzyć pliku: $!\n";
while (my $linia = <$plik>) {
    chomp $linia;  # Usuwanie nowej linii
    my @slowa = split /\s+/, $linia;    #To jest _bardzo_ użyteczne
    #print "$linia\n";
    my @row = ();
    foreach my $slowo (@slowa) {
        push @row, $slowo;
    }
    push @matrix_b, \@row;
}
close $plik;
my $rows_a = scalar @matrix_a;
my $cols_a = scalar @{ $matrix_a[0] };
my $rows_b = scalar @matrix_b;
my $cols_b = scalar @{ $matrix_b[0] };
for my $i (0..$rows_a-1) {
    my @row;
    for my $j (0..$cols_b-1) {
        my $r = 0;
        for my $k (0..$cols_a-1) {
            $r += $matrix_a[$i][$k] * $matrix_b[$k][$j];
        }
        push @row, $r;
    }
    push @matrix_c, \@row;
}
#my $cols = scalar @{ $matrix_a[0] };
#my $rows = scalar @matrix_b;
#my $rows_a = scalar @matrix_a;
#for my $i (0..$rows_a-1) {zz
#    my $r = 0;
#    for my $j (0..$cols-1) {
#        for my $k (0..$cols-1) {
#            $r += $matrix_a[$i][$k] * $matrix_b[$k][$j]
#        }
#        push @row, $r;
#        $r = 0;
#    }
#    push @matrix_c, \@row;
#}
my $cols_c = scalar @{ $matrix_c[0] };
my $rows_c = scalar @matrix_c;
open(my $plik, '>',$ARGV[2] ) or die "Nie można otworzyć pliku: $!";
for my $i (0..$rows_c-1) {
    for my $j (0..$cols_c-1) {
        printf $plik "%8.3f ",$matrix_c[$i][$j];
    }
    print $plik "\n";
}
close $plik or warn "Problem przy zamykaniu pliku: $!";
#for my $i (0..$rows_c-1) {
#    for my $j (0..$cols_c-1) {
#        printf "%8.3f ",$matrix_c[$i][$j] ;
#    }
#    print "\n";
#}
