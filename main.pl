#!/usr/bin/perl
use lib '.';
use strict;
use warnings;
use Crypto;
use UI qw(avalible_acctions handle_command wait_for_commit);
unless (@ARGV == 2) {
    die "Użycie: $0 <ciphertext> <plaintext>\n";
}
my $crypto = Crypto->new($ARGV[0], $ARGV[1]);
while (1) {
    avalible_acctions();
    my $cmd = <STDIN>;
    chomp $cmd;
    handle_command($cmd);
    wait_for_commit();
}