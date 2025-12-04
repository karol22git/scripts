#!/usr/bin/perl
my %animals;
while (my $linia = <STDIN>) {
    chomp $linia;  # Usuwanie nowej linii
    my @slowa = split /\s+/, $linia;    #To jest _bardzo_ użyteczne
    foreach my $slowo (@slowa) {
        my $a = $animals{$slowo};
        $animals{$slowo} = $a +1;
    }
}
my @animals_keys = keys %animals;
my @animals_keys_sorted = sort @animals_keys;
foreach my $slowo (@animals_keys_sorted) {
    print "$slowo $animals{$slowo}\n";
}