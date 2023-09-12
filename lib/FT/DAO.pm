use Feature::Compat::Class;

package FT::Data {
    my sub fetch_http_data {
        my $r = HTTP::Tiny->new()->get( $ENV{FT_DATA_URL} );
        unless ( $r->{success} ) {
            die sprintf "Failed to get data from %s: %s %s",
              $ENV{FT_DATA_URL}, $r->{status}, $r->{reason};
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
                PrintError                 => 1,
                sqlite_see_if_its_a_number => 1,
            }
        );
        $self->load_data() unless $self->food_truck_count();
    }

    # useful for healthchecks
    method ping { $dbh->ping; }

    method create_db {

        # TODO replace with a call to App::Sqitch directly
        warn "Creating database: $db";
        system( 'sqitch', 'deploy', "db:sqlite:$db" );
    }

    method food_truck_count() {
        $dbh->selectrow_array('SELECT count(*) from food_trucks;');
    }

    method load_data () {

        warn "Loading database: $db";
        my $csv = FT::Data->fetch();
        die "No data" unless $csv;

        my $sth = $dbh->prepare(
            q{
            INSERT INTO food_trucks (
                address, applicant, approved, block, blocklot, cnn, dayshours, expiration_date,
                facility_type, fire_prevention_districts, food_items, latitude, location,
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

    method list_food_trucks() {
        $dbh->selectall_arrayref( 'SELECT * FROM food_trucks',
            { Slice => {} } );
    }

    method add_food_truck ($truck) {
        my $sth = $dbh->prepare( q{
            INSERT INTO food_trucks (
                address, applicant, food_items, location_description, locationid
            ) VALUES (?, ?, ?, ?, ?)
        });

        $sth->execute(
            $truck->@{
                'address',    'applicant',
                'food_items', 'location_description',
                'locationid'
            }
        );

        my ($new) = $dbh->selectall_array(
            q{
                SELECT * FROM food_trucks WHERE id = ?
            },
            { Slice => {} },
            $dbh->sqlite_last_insert_rowid()
        );
        return $new;
    }

    method add_order ($order) {
        my $sth = $dbh->prepare(
            q{
            INSERT INTO orders (person, phone, drop_off, truck_id, food_order )
                        VALUES (?, ?, ?, ?, ?)

        }
        );

        $sth->execute(
            $order->@{ 'name', 'phone', 'drop_off', 'truck_id', 'food_order' }
        );

        my ($new) = $dbh->selectall_array(
            q{
                SELECT *
                  FROM orders o
                INNER JOIN food_trucks t ON o.truck_id = t.locationid
                WHERE o.id = ?
            },
            { Slice => {} },
            $dbh->sqlite_last_insert_rowid()
        );
        return $new;
    }

    method list_pending_orders() {
        $dbh->selectall_arrayref(
            q{
                SELECT *
                  FROM orders o
                INNER JOIN food_trucks t ON o.truck_id = t.locationid
                WHERE NOT o.delivered
            },
            { Slice => {} }
        );
    }

    method mark_order_delivered ($id) {
        my $sth = $dbh->prepare(
            q{
            UPDATE orders
               SET delivered = TRUE,
                   delivered_at = datetime()
             WHERE id = ?
        }
        );
        $sth->execute($id);
    }
}

1;
__END__
