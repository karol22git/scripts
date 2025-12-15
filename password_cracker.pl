
my $cipher_text = $ARGV[0];
my $plain_text = $ARGV[1];
my %frequency_counter;
my %id  =("A" => "A","B" => "B","C" => "C","D" => "D","E" => "E","F" => "F",
"G" => "G","H" => "H","I" => "I","J" => "J","K" => "K","L" => "L","M" => "M",
"N" => "N","O" => "O","P" => "P","R" => "R","S" => "S","T" => "T","U" => "U",
"V" => "V","W" => "W","X" => "X","Y" => "Y","Z" => "Z"," " => " ","Q" => "Q",
);
my %cipher = %id;
my @word_metadata_ciphertext;
my @word_metadata_plaintext;
my %frequency_metadata_ciphertext;
my %frequency_metadata_plaintext;

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

sub print_dictionary_table {
    my ($dict_ref) = @_;
    print "+----------------+----------------+\n";
    print "|     KEY        |    VALUE       |\n";
    print "+----------------+----------------+\n";
    for my $key (sort keys %{$dict_ref}) {
        printf "| %-14s | %-14s |\n", $key, $dict_ref->{$key};
    }
    print "+----------------+----------------+\n";
}
sub print_two_dictionaries {
    my ($dict1_ref, $dict2_ref) = @_;
    print "+----------------+----------------+----------------+   +----------------+----------------+\n";
    print "|   CIPHER KEY   |   DECRYPTED    |   FREQUENCY    |   |   PLAIN KEY    |   FREQUENCY    |\n";
    print "+----------------+----------------+----------------+   +----------------+----------------+\n";
    my @keys1 = sort_descending($dict1_ref);
    my @keys2 = sort_descending($dict2_ref);
    my $max_rows = 20;

    for my $i (0 .. $max_rows-1) {
        my $key1 = $keys1[$i] // "";
        my $dec1 = $key1 eq "" ? "" : decrypt_word(\%cipher, $key1);
        my $val1 = $key1 eq "" ? "" : $dict1_ref->{$key1} // "";

        my $key2 = $keys2[$i] // "";
        my $val2 = $key2 eq "" ? "" : $dict2_ref->{$key2} // "";

        printf "| %-14s | %-14s | %-14s |   | %-14s | %-14s |\n",
            $key1, $dec1, $val1, $key2, $val2, "";
    }
    print "+----------------+----------------+----------------+   +----------------+----------------+\n";
}

sub print_char_dictionaries {
    my ($dict1_ref, $dict2_ref) = @_;
    print "+----------------+----------------+   +----------------+----------------+\n";
    print "|     CIPHER TEXT METADATA        |   |     ORIGINAL TEXT METADATA      |\n";
    print "+----------------+----------------+   +----------------+----------------+\n";
    
    my @keys1 = sort_descending($dict1_ref);#sort keys %{$dict1_ref};
    my @keys2 = sort_descending($dict2_ref) ;##sort keys %{$dict2_ref};
    my $max_rows = 20;
    for my $i (0 .. $max_rows-1) {
        my $k1 = decrypt_word(\%cipher,$keys1[$i]) // "";
        my $v1 = $k1 eq "" ? "" : $dict1_ref->{$keys1[$i]};

        my $k2 = $keys2[$i] // "";
        my $v2 = $k2 eq "" ? "" : $dict2_ref->{$k2};

        printf "| %-14s | %-14s | %-14s |   | %-14s | %-14s |\n",$keys1[$i], $k1, $v1, $k2, $v2;
    }

    # stopka
    print "+----------------+----------------+   +----------------+----------------+\n";
}
sub setup {
    @word_metadata_ciphertext = calculate_word_frequencies($cipher_text, $cipher{" "});
    @word_metadata_plaintext = calculate_word_frequencies($plain_text, " ");
    %frequency_metadata_ciphertext = calculate_characters_frequency($cipher_text);
    %frequency_metadata_plaintext = calculate_characters_frequency($plain_text);
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
sub clear_screen {
    system("clear");
}

sub avalible_acctions {
    print "Please select one:\n";
    print "metadata_chars() = by selectnig this, programm will print You character counters in each text.\n";
    print "metadata_words(type) = by selectnig this, programm will print You word counters in each text.\n By default, words from cihpertext are transladed via cipher.\nAvalible types biwords, triwords, quadrawords, pentawords, hexawords, octawords."; 
    print "state() = print actual cipher state.\n";
    print "match(), will match cipher arguments (encX) and result Y, based on its frequncy.\n";
    print "set(X,Y) = upgrade cipher, setting encX = Y.\n";
    print "clear_screen() = cleaning terminal.\n";
    print "new_cipher() = setting cipher to id.\n";
   # print "show_page() = display one page from ciphertext and translate it via cipher.\n";
    print "exit() = mysterious command.\n";
}
sub wait_for_commit {
    print "Enter any key to continue.\n";
    my $timeholder = <STDIN>;
}

sub parse_command {
    my ($line,@types) = @_;
    for my $t (@types) {
        if (index($line, $t) != -1) {
            return $t;
        }
    }
    return "error";
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

sub match {
    my @keys1 = sort_descending(\%frequency_metadata_ciphertext);
    my @keys2 = sort_descending(\%frequency_metadata_plaintext);
    for my $i (0..$#keys2) {
        $cipher{$keys1[$i]} = $keys2[$i];
    }
}

sub handle_command {
    my ($line) = @_;
    my @command_types = ("metadata_chars","metadata_words","state","match","set", "clear_screen","exit","show_page","new_cipher");
    my @metadata_types = ("biwords","triwords","quadrawords","pentawords","hexawords","octawords");
    my $cmd = parse_command($line, @command_types);
    if($cmd eq "metadata_chars") {
        print_char_dictionaries(\%frequency_metadata_ciphertext,\%frequency_metadata_plaintext);
    }
    elsif ($cmd eq "metadata_words") {
        my $metadata_type = parse_command($line,@metadata_types);
        if ($metadata_type eq "error") {
            print "You entered correct command with wrongly formatted arguments. Try again.\n";
        }
        my $i = match_metadat_type_to_int($metadata_type);
        print_two_dictionaries($word_metadata_ciphertext[$i],$word_metadata_plaintext[$i]);

    }
    elsif($cmd eq "state") {
        print_dictionary_table(\%cipher);
    }
    elsif ($cmd eq "match") {
        match();
    }
    elsif($cmd eq "set") {
        my $i = index($line,"(");
        my $j = index($line, ")");
        my @splitted = split //, $line;
        my $c1 = $splitted[$i+1];
        my $c2 = $splitted[$j-1];
        if ($c1 =~ /^[A-Z ]$/ && $c2 =~ /^[A-Z ]$/) {
            set_character($c1,$c2,\%cipher);
        }
        else {
            print "You entered correct command with wrongly formatted arguments. Try again.\n";
        }
    }
    elsif ($cmd eq "clear_screen") {
        clear_screen();
    }
    elsif ($cmd eq "new_cipher") {
        reset();
    }
    elsif ($cmd eq "exit") {
        exit;
    }
    elsif($cmd eq "show_page") {
        display_ten_lines($cipher_text,$cipher{" "},\%cipher);
    }
    else {
        print "You selected unavabile option. Please try again.\n";
    }
}
sub reset() {
    %cipher = %id;
}
setup();
while(1) {
    avalible_acctions();
    my $cmd = <STDIN>;
    handle_command($cmd);
    wait_for_commit();
}