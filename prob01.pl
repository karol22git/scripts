#!/usr/bin/perl
my @zwierzeta = ("kot", "pies", "papuga", "kanarek","ryba");
print "$zwierzeta[0]\n";
print scalar @zwierzeta;
print "\n";
$zwierzeta[1] = "kanarek";
push(@zwierzeta,"zaba");
print scalar @zwierzeta;
print "\n";
pop(@zwierzeta);
print scalar @zwierzeta;
print "\n";
foreach my $zwierze (@zwierzeta) {
    print "$zwierze\n";
}
for my $i (0..$#zwierzeta) {
    print "$i $zwierzeta[$i]\n";
}
my @sub_array = @zwierzeta[1..3];
foreach my $zwierze (@sub_array) {
    print "$zwierze\n";
}