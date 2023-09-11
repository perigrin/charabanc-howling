use 5.38.0;
use experimental 'class';

package FT::Data {
    my sub fetch_http_data {
        my $r = HTTP::Tiny->new()->get( $ENV{FT_DATA_URL} );
        unless ( $r->{success} ) {
            die sprintf "Failed to get data from %s: %s %s",
              $ENV{TRUCK_DATA_URL}, $r->{status}, $r->{reason};
        }
        return $r->{content};
    }

    my sub fetch_file_data {
        my ($file) = $ENV{FT_DATA_URL} =~ m|^file://(.*)|;
        open my ($fh), '<', $file;
        return do { local $/; <$fh> }
    }

    sub fetch ($) {
        $ENV{FT_DATA_URL} =~ /^http:/ ? fetch_http_data() : fetch_file_data();
    }
}

class FT::DAO {
    use DBI;
    use HTTP::Tiny;
    use Text::CSV_XS qw(csv);

    field $db : param;
    field $dbh;

    ADJUST {
        $self->create_db() unless -e $db;
        $dbh = DBI->connect(
            "dbi:SQLite:dbname=$db",
            "", "",
            {
                AutoCommit                 => 1,
                RaiseError                 => 1,
                sqlite_see_if_its_a_number => 1,
            }
        );
        $self->load_data() unless $self->food_truck_count();
    }

    # useful for healthchecks
    method ping { $dbh->ping; }

    method create_db {
        # TODO replace with a call to App::Sqitch directly
        system( 'sqitch', 'deploy', "db:sqlite:$db" );
    }

    method food_truck_count() {
        $dbh->selectrow_array('SELECT count(*) from food_trucks;');
    }

    method load_data () {
        my $csv = FT::Data->fetch();
        my $sth = $dbh->prepare(
            q{
            INSERT INTO food_trucks (
                address, applicant, approved, block, blocklot, cnn, dayshours, expiration_date,
                facility_type, fire_prevention_districts, foodItems, latitude, location,
                location_description, locationid, longitude, lot, neighborhoods, NOISent, permit,
                police_districts, prior_permit, received, schedule, status, supervisor_districts,
                x, y, zip_codes
            ) VALUES (
                ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
                ?, ?, ?
            )
        }
        );

        for my $row ( csv( in => \$csv, headers => 'auto' )->@* ) {
            $sth->execute(
                $row->@{
                    'Address',          'Applicant',
                    'Approved',         'block',
                    'blocklot',         'cnn',
                    'dayshours',        'ExpirationDate',
                    'FacilityType',     'Fire Prevention Districts',
                    'FoodItems',        'Latitude',
                    'Location',         'LocationDescription',
                    'locationid',       'Longitude',
                    'lot',              'Neighborhoods (old)',
                    'NOISent',          'permit',
                    'Police Districts', 'PriorPermit',
                    'Received',         'Schedule',
                    'Status',           'Supervisor Districts',
                    'X',                'Y',
                    'Zip Codes'
                }
            );
        }
    }
}
