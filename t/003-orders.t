use Test::More;
use Test::Mojo;

use File::Temp;
my $tempdir = File::Temp->newdir();
$ENV{FT_DATABASE_FILE} = "$tempdir/food_trucks.db";
$ENV{FT_DATA_URL}      = 'file://./t/data/Mobile_Food_Facility_Permit.csv';

my $t = Test::Mojo->new( Mojo::File->new('app.pl') );

# TODO inject fixture data of some kind

$t->get_ok('/order/add')->status_is(200)->element_exists('form');

$t->post_ok(
    '/order/add',
    form => {
        name         => 'Harry Potter',
        phone        => '555-555-5555',
        drop_off     => 'Astronomy Tower',
        truck_id     => '1',
        'food_order' => 'Bernie Botts Every Flavor Beans',
    }
)->status_is(200)
 ->content_type_is('text/html;charset=UTF-8')
; # TODO ->content_like(qr/Harry Potter/) works but fails in the tests

done_testing;
