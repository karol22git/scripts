# Print the CSV line to the file
package Modul;
use strict;
use warnings;
use Spreadsheet::ParseXLSX;
use Text::CSV;
my @matrix = ();
my $N;
my $M;
sub init {
    my ($n, $m) = @_;
    $Modul::N = $n;
    $Modul::M = $m;
    for my $i (0..$n-1) {
        $Modul::matrix[$i] = [];
        for my $j (0..$m-1) {
            $Modul::matrix[$i][$j] = 0;
        }
    }
}

sub addReadXLS {
    my ($filename) = @_;
    my $parser = Spreadsheet::ParseXLSX->new();
    my $workbook = $parser->parse($filename);
    for my $s ($workbook->worksheets()) {
        for my $i (0..$Modul::N-1) {
            for my $j (0..$Modul::M-1) {
                my $cell = $s->get_cell($i,$j);
                next unless $cell;
                $Modul::matrix[$i][$j] += $cell->value();
            }
        }
    }
}

sub saveCSV {
    my ($dest) = @_;
    open my $plik, '>', $dest or die "Nie mogę otworzyć pliku: $!\n";
    my $csv = Text::CSV->new({ sep_char => ';' });
    for my $row (@Modul::matrix) {
      $csv->combine(@$row);
      print $plik $csv->string(), "\n";   #fh to plik otwarty gdzieś wcześniej...
    }
    close $plik;
}   
1;