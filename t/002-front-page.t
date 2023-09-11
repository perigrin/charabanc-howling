use Test::More;
use Test::Mojo;

use File::Temp;
my $tempdir = File::Temp->newdir();
$ENV{FT_DATABASE_FILE} = "$tempdir/food_trucks.db";
$ENV{FT_DATA_URL} = 'file://./t/data/Mobile_Food_Facility_Permit.csv';

my $t = Test::Mojo->new(Mojo::File->new('app.pl'));

# TODO inject fixture data of some kind

$t->get_ok('/')
  ->status_is(200)
  ->element_exists('.logo');


done_testing;
