#!/usr/bin/perl -w                                                                                                                                                                                                                           
# libdatetime-format-builder-perl needed                                                                                                                                                                                                     
# libfile-readbackwards-perl needed                                                                                                                                                                                                          # chelmiki@gmail.com
 
use DateTime ();
use DateTime::Duration ();
use DateTime::Format::Strptime ();
use File::ReadBackwards;

$num_args = $#ARGV + 1;
if ($num_args != 3) {
    print "\nUsage: check_last_logs.pl pattern minutes log_file\n";
    exit;
}

$search = $ARGV[0];
$interval = $ARGV[1];
$log_file = $ARGV[2];
$time_zone = 'Europe/Madrid';

my $now    = DateTime->now;
$now->set_time_zone($time_zone);

my $delta  = DateTime::Duration->new( minutes => $interval );

$LOGS = File::ReadBackwards->new($log_file) or
    die "can't read file: $!\n";

while (defined($line = $LOGS->readline) ) {
    my @fields = split ' ', $line;
    my $parser = DateTime::Format::Strptime->new(pattern => '%Y-%m-%d %H:%M:%S');
    my $dt = $parser->parse_datetime("$fields[0] $fields[1]");

    if (($dt > $now - $delta)) {
        if ($line =~ m/$search/){
	    print "CRITICAL - There are \"$search\" in the last $interval minutes\n";
	    close(LOGS);
	    exit 2;
        }
    }
    else{
        last;
    }
}
print "OK - There are no \"$search\" in the last $interval minutes\n";
close(LOGS);
exit 0;
