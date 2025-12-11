use lib '.';
use Modul;
my $n = $ARGV[2];
my $m = $ARGV[3];
my $source_file = $ARGV[0];
my $dest = $ARGV[1];

Modul::init($n,$m);
Modul::addReadXLS($source_file);
Modul::saveCSV($dest);
