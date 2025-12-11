use DBI;

sub get_table_name {
    my ($filename) = @_;
    my @splitted_file = split /\./, $filename;
    return $splitted_file[0];
}

sub format_column {
    my ($column) = @_;
    my @letters = split //, $column;
    my $r = $column;
    if (index($column, "date") != -1) {
        $r = $r . " DATE";
    }
    elsif ($letters[0] eq "i") {
        $r = $r . " INTEGER";
    }
    else {
        $r = $r . " TEXT";
    }
    if ($column eq "id") {
        $r = $r . " PRIMARY KEY"
    }
    return $r;
}

sub generate_question_marks {
    my (@cols) = @_;
    my $r = "( ";
    for my $i (0..$#cols-1) {
        $r = $r . "?,";
    }
    $r = $r . "? )";
    return $r;
}
my $t = "CREATE TABLE IF NOT EXISTS ";
#my $tt = $t . get_table_name("siema.txt") . "(";

my $args_num = scalar (@ARGV);
my $db_name = "database.db";
if (-e $db_name) {
    unlink $db_name or die "Nie mogę usunąć pliku $db_name: $!\n";
}
my $dbh = DBI->connect("dbi:SQLite:dbname=$db_name", "", "", { RaiseError => 1, AutoCommit => 1 });

#print $tt;
#print "\n";
for my $i (0..$args_num-1) {
    open  $plik, '<', $ARGV[$i] or die "Nie mogę otworzyć pliku: $!\n";
    my $cols = <$plik>;
    chomp $cols;
    my @cols_names = split ",",$cols;
    my $tt = $t .get_table_name($ARGV[$i]) . "(";
    for my $c (0..$#cols_names-1) {
        $tt = $tt . format_column($cols_names[$c]) . ",";
    }
    $tt = $tt . format_column($cols_names[$#cols_names]) .")";
    $dbh->do($tt);
    #print $tt;
    #print "\n";
    my $ttt = "INSERT INTO " . get_table_name($ARGV[$i]) . " VALUES " . generate_question_marks(@cols_names);
    #print $ttt;
    #print "\n";
    my $sth = $dbh->prepare($ttt);
    while (my $linia = <$plik>) {
        chomp $linia;  # Usuwanie nowej linii;
        my @slowa = split ",", $linia;   #To jest _bardzo_ użyteczne
        $sth->execute(@slowa);
    }
    close $plik;

}
my $sql = qq{
    SELECT e.name,
           e.surname,
           u.email,
           SUM(s.salary) AS total_salary
    FROM employees e
    JOIN user_data u ON e.id = u.employee_id
    JOIN salaries s ON e.id = s.employee_id
    GROUP BY e.id, e.name, e.surname, u.email
    ORDER BY total_salary DESC, u.email ASC
    LIMIT 4
};
my $sth = $dbh->prepare($sql);
$sth->execute();

print "Top 4 employees with highest total salaries:\n";
print "----------------------------------------\n";

while (my @row = $sth->fetchrow_array) {
    print join(" | ", @row), "\n";
}

$sth->finish;
$dbh->disconnect;
#print "$args_num\n";