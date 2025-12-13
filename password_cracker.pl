
my $cipher_text = $ARGV[0];
my $plain_text = $ARGV[1];
my %frequency_counter;
my %cipher = ("A" => "A","B" => "B","C" => "C","D" => "D","E" => "E","F" => "F",
"G" => "G","H" => "H","I" => "I","J" => "J","K" => "K","L" => "L","M" => "M",
"N" => "N","O" => "O","P" => "P","R" => "R","S" => "S","T" => "T","U" => "U",
"V" => "V","W" => "W","X" => "X","Y" => "Y","Z" => "Z"," " => " ","Q" => "Q",
);
sub get_nwords {
    my ($n, );
}

sub set_character {
    my ($c1,$c2,$cipher) = @_;
    my $actual_map = $cipher{$c1};
    $cipher{$c1} = $c2;
    for my $key (keys %cipher) {
        if ($cipher{$key} eq $c2 && $key ne $c1) {
            $cipher{$key} = $actual_map;
        }
    }
}

sub print_cipher {
    my ($cipher) = @_;
    for my $key (keys %cipher) {
        print "$key => $cipher{$key}\n";
    }
}

sub calculate_characters_frequency {
    my ($filename) = @_;
    my %characters;
    open  $plik, '<', $filename or die "Cannot open the file! $!\n";
    while (my $line = <$plik>) {
        chomp $line;
        my @chars = split //, $line;
        for my $c (@chars) {
            $characters{$c} += 1;
        }
    }
    return %characters;
}

sub sort_frequency {
    my ($characters) = @_;
    return sort { $characters{$b} <=> $characters{$a} } keys %characters;
}

sub calculate_word_frequencies {
    my ($filename,$space)  =@_;
    my (%my_biwords, %my_triwords, %my_quadrawords, %my_pentawords, %my_hexawords, %my_heptawords);
    open  $plik, '<', $filename or die "Cannot open the file! $!\n";
    while (my $line = <$plik>) {
        chomp $line;
        my @words = split $space, $line;
        for my $w (@words) {
            if (length($w) == 2){ $my_biwords{$w} +=1;}
            elsif (length($w) == 3){ $my_triwords{$w} +=1;}
            elsif (length($w) == 4){ $my_quadrawords{$w} +=1;}
            elsif (length($w) == 5){ $my_pentawords{$w} +=1;}
            elsif (length($w) == 6){ $my_hexawords{$w} +=1;}
            elsif (length($w) == 7){$my_heptawords{$w} +=1;}
        }   
    }
    close $plik;
    return (\%my_biwords, \%my_triwords, \%my_quadrwords, \%my_pentawords, \%my_hexwords, \%my_siedem);
}
print_cipher(\%cipher);
set_character("A", "B",\%cipher);
print "---------------------------------------------\n";
print_cipher(\%cipher);
