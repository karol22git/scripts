package UI;
use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(
    print_dictionary_table
    print_two_dictionaries
    print_char_dictionaries
    avalible_acctions
    wait_for_commit
    parse_command
    handle_command
    clear_screen
);

use Crypto qw(
    %cipher %id
    @word_metadata_ciphertext @word_metadata_plaintext
    %frequency_metadata_ciphertext %frequency_metadata_plaintext
    decrypt_word match set_character reset display_ten_lines
    sort_descending match_metadat_type_to_int 
    $cipher_text $plain_text
);

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
            $key1, $dec1, $val1, $key2, $val2;
    }
    print "+----------------+----------------+----------------+   +----------------+----------------+\n";
}

sub print_char_dictionaries {
    my ($dict1_ref, $dict2_ref) = @_;
    print "+----------------+----------------+   +----------------+----------------+\n";
    print "|     CIPHER TEXT METADATA        |   |     ORIGINAL TEXT METADATA      |\n";
    print "+----------------+----------------+   +----------------+----------------+\n";
    
    my @keys1 = sort_descending($dict1_ref);
    my @keys2 = sort_descending($dict2_ref);
    my $max_rows = 20;
    for my $i (0 .. $max_rows-1) {
        my $k1 = decrypt_word(\%cipher,$keys1[$i]) // "";
        my $v1 = $k1 eq "" ? "" : $dict1_ref->{$keys1[$i]};

        my $k2 = $keys2[$i] // "";
        my $v2 = $k2 eq "" ? "" : $dict2_ref->{$k2};

        printf "| %-14s | %-14s |   | %-14s | %-14s |\n", $k1, $v1, $k2, $v2;
    }

    print "+----------------+----------------+   +----------------+----------------+\n";
}

sub avalible_acctions {
    print "Please select one:\n";
    print "metadata_chars() = by selectnig this, programm will print You character counters in each text.\n";
    print "metadata_words(type) = by selectnig this, programm will print You word counters in each text.\n By default, words from cihpertext are transladed via cipher.\nAvalible types biwords, triwords, quadrawords, pentawords, hexawords, octawords.\n"; 
    print "state() = print actual cipher state.\n";
    print "match(), will match cipher arguments (encX) and result Y, based on its frequncy.\n";
    print "set(X,Y) = upgrade cipher, setting encX = Y.\n";
    print "clear_screen() = cleaning terminal.\n";
    print "new_cipher() = setting cipher to id.\n";
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

sub clear_screen {
    system("clear");
}

1;
