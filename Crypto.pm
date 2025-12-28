package Crypto;
use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw(
    %id %cipher
    @word_metadata_ciphertext @word_metadata_plaintext
    %frequency_metadata_ciphertext %frequency_metadata_plaintext
    $cipher_text
    $plain_text

    print_cipher
    print_dictionary
    calculate_characters_frequency
    sort_descending
    calculate_word_frequencies
    decrypt_words
    decrypt_word
    display_ten_lines
    set_character
    match
    match_metadat_type_to_int
    reset
    setup
);

our $cipher_text;
our $plain_text;

our %frequency_counter;
our %id  =("A" => "A","B" => "B","C" => "C","D" => "D","E" => "E","F" => "F",
"G" => "G","H" => "H","I" => "I","J" => "J","K" => "K","L" => "L","M" => "M",
"N" => "N","O" => "O","P" => "P","R" => "R","S" => "S","T" => "T","U" => "U",
"V" => "V","W" => "W","X" => "X","Y" => "Y","Z" => "Z"," " => " ","Q" => "Q",
);
our %cipher = %id;
our @word_metadata_ciphertext;
our @word_metadata_plaintext;
our %frequency_metadata_ciphertext;
our %frequency_metadata_plaintext;
sub new {
    my ($class, $cipher_file, $plain_file) = @_;
    $cipher_text = $cipher_file;
    $plain_text = $plain_file;
    setup();
    return bless {}, $class;
}
sub print_cipher {
    my ($cipher) = @_;
    for my $key (keys %cipher) {
        print "$key => $cipher{$key}\n";
    }
}

sub print_dictionary {
    my ($dict_keys, $dict) = @_;
    for my $key (@{$dict_keys}) {
        print "key: $key, value: $dict->{$key}\n";
    }
}

sub calculate_characters_frequency {
    my ($filename) = @_;
    my %characters;
    open my $plik, '<', $filename or die "Cannot open the file! $!\n";
    while (my $line = <$plik>) {
        chomp $line;
        $line = uc($line); 
        $line =~ s/[^A-Z ]//g;
        my @chars = split //, $line;
        for my $c (@chars) {
            $characters{$c} += 1;
        }
    }
    return %characters;
}

sub sort_descending {
    my ($dict_to_sort) = @_;
    return sort { $dict_to_sort->{$b} <=> $dict_to_sort->{$a} } keys %{$dict_to_sort};
}

sub calculate_word_frequencies {
    my ($filename,$space)  =@_;
    my (%my_biwords, %my_triwords, %my_quadrawords, %my_pentawords, %my_hexawords, %my_heptawords);
    open my $plik, '<', $filename or die "Cannot open the file! $!\n";
    while (my $line = <$plik>) {
        chomp $line;
        $line = uc($line);    
        $line =~ s/[^A-Z ]//g;
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
    return (\%my_biwords, \%my_triwords, \%my_quadrawords, \%my_pentawords, \%my_hexawords, \%my_heptawords);
}

sub decrypt_words {
    my ($cipher, @words) =  @_;
    my @result;
    for my $word (@words) {
        my $word_decrypted = "";
        for my $char (split//, $word) {
            $word_decrypted = $word_decrypted . $cipher->{$char};
        }
        push @result, $word_decrypted;
    }
    return @result;
}

sub decrypt_word {
    my ($cipher, $word) = @_;
    my $result = "";
    for my $char (split //, $word) {
        $result = $result . $cipher{$char};
    }
    return $result;
}

sub display_ten_lines {
    my ($filename, $space, $icpher_ref) = @_;
    my $word_per_line_counter = 0;
    my $line_counter = 0;

    print "DESZYFROGRAM\n";
    print "----------------------------------\n";

    open my $plik, '<', $filename or die "Cannot open the file! $!\n";
    LINE: while (my $line = <$plik>) {
        chomp $line;
        my @words = split $space, $line;

        my $cipher_line = "";
        for my $word (@words) {
            print "tutaj slowo $word\n";
            my $word_ciphered = "";
            for my $char (split //, $word) {
                $word_ciphered .= $icpher_ref->{$char} // $char;
            }
            $cipher_line .= $word_ciphered . " ";

            $word_per_line_counter++;
            if ($word_per_line_counter == 5) {
                printf "%-60s\n", $cipher_line;
                $cipher_line = "";
                $word_per_line_counter = 0;
                $line_counter++;

                if ($line_counter == 10) {
                    last LINE;
                }
            }
        }
    }
    print "----------------------------------\n";
    close $plik;
}

sub set_character {
    my ($c1,$c2,$cipher_ref) = @_;
    my %mcipher = %{$cipher_ref}; 
    my $actual_map = $mcipher{$c1};
    $mcipher{$c1} = $c2;
    for my $key (keys %mcipher) {
        if ($mcipher{$key} eq $c2 && $key ne $c1) {
            $mcipher{$key} = $actual_map;
        }
    }
    %{$cipher_ref} = %mcipher;
    if ($c2 eq " ") {
        @word_metadata_ciphertext = calculate_word_frequencies($cipher_text, $cipher{" "});
    }
}

sub match {
    my @keys1 = sort_descending(\%frequency_metadata_ciphertext);
    my @keys2 = sort_descending(\%frequency_metadata_plaintext);
    for my $i (0..$#keys2) {
        $cipher{$keys1[$i]} = $keys2[$i];
    }
}

sub match_metadat_type_to_int {
    my ($metadat_type) = @_;
    if ($metadat_type eq "biwords") {
        return 0;
    }
    elsif ($metadat_type eq "triwords") {
        return 1;
    }
    elsif($metadat_type eq "quadrawords") {
        return 2;
    }
    elsif($metadat_type eq "pentawords") {
        return 3;
    }
    elsif($metadat_type eq "hexawords") {
        return 4;
    }
    else {
        return 5;
    }
}

sub reset {
    %cipher = %id;
}

sub setup {
    # Sprawdź czy pliki zostały ustawione
    unless ($cipher_text && $plain_text) {
        die "Brak ustawionych plików cipher_text lub plain_text!\n";
    }
    
    @word_metadata_ciphertext = calculate_word_frequencies($cipher_text, $cipher{" "});
    @word_metadata_plaintext = calculate_word_frequencies($plain_text, " ");
    %frequency_metadata_ciphertext = calculate_characters_frequency($cipher_text);
    %frequency_metadata_plaintext = calculate_characters_frequency($plain_text);
}
1;