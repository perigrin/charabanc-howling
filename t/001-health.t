use strict;
use Test::More;
use Test::Mojo;

use File::Temp;
my $tempdir = File::Temp->newdir();
$ENV{FT_DATABASE_FILE} = "$tempdir/food_trucks.db";
$ENV{FT_DATA_URL} = 'file://./t/data/Mobile_Food_Facility_Permit.csv';

my $t = Test::Mojo->new(Mojo::File->new('app.pl'));
$t->get_ok('/health')->status_is(200);

done_testing;
