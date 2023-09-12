#!/bin/perl
use 5.36.0;
use lib qw(lib);
use autodie;
use Mojolicious::Lite -signatures;

use FT::DAO;

$ENV{FT_DATABASE_FILE} //= 'food_truck.db';
$ENV{FT_DATA_URL} //= 'https://data.sfgov.org/api/views/rqzj-sfat/rows.csv';

app->secrets( [ $ENV{HOSTNAME} ] );

plugin 'HTMX';

helper dao => sub { state $db = FT::DAO->new( db => $ENV{FT_DATABASE_FILE} ) };

get '/health' => sub ($c) { $c->render( text => $c->dao->ping() ) };

get '/' => 'index';

get '/order/add' => sub ($c) {
    my $trucks = $c->dao->list_food_trucks();
    $c->render( 'order/add' => ( trucks => $trucks ) );
};

post '/order/add' => sub ($c) {
    my $order = $c->dao->add_order( $c->req->body_params()->to_hash );
    $c->render( 'order/thanks', ( order => $order ) );
};

post '/order/:id/delivered' => sub ($c) {
    $c->dao->mark_order_delivered( $c->param('id') );
    $c->redirect_to('/order/list');
};

get '/order/list' => sub ($c) {
    my $orders = $c->dao->list_pending_orders();
    $c->render( 'order/list', ( orders => $orders ) );
};

get '/truck/add' => 'truck/add';
post '/truck/add' => sub ($c) {
    my $truck = $c->dao->add_food_truck( $c->req->body_params()->to_hash );
    $c->render( 'truck/thanks', ( truck => $truck ) );
};

get '/colophon';

app->start;

__DATA__

@@ colophon.html.ep
% layout 'page';
<section class="content">
<header><h2>Colophon</h2></header>
<p>Here are the credits for the various images and fonts used in this website</p>
</section>
<section class="cards" style="flex-flow: column">
<div class="card">
    <img src="/img/joana-godinho-Gwv-t9VQiPM-unsplash.jpg" height=125 width=200 class="logo">
    <section class="content">
        Photo by <a href="https://unsplash.com/@joana_g?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Joana Godinho</a> on <a href="https://unsplash.com/photos/Gwv-t9VQiPM?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
    </section>
</div>
<div class="card">
    <img src="/img/sander-dalhuisen-nA6Xhnq2Od8-unsplash.jpg" height=125 width=200 class="logo">
    <section class="content">
        Photo by <a href="https://unsplash.com/@sanderdalhuisen?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Sander Dalhuisen</a> on <a href="https://unsplash.com/photos/nA6Xhnq2Od8?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
    </section>
</section>

@@ truck/thanks.html.ep
% layout 'page';
<section class="content">
<header><h2>Thanks for adding a new Truck!</h2></header>
<p>Everyone around here's is gonna love the new choices</p>
</section>
<section class="cards">
    <div class="card nologo">
    <section class="content"
       <dl>
        <dt>Truck Name</dt>
        <dd><%= $truck->{applicant} %></dd>
        <dt>Address</dt>
        <dd><%= $truck->{address} %></dd>
        <dd>(<%= $truck->{location_description} // "somwehere near there at least" %>)</dd>
        <dt>Food Stuff</dt>
        <dd><%= $truck->{food_items} %></dd>
       </dl>
    </section>
    </div>
</section>

@@ truck/add.html.ep
% layout 'page';
<section class="content">
<header><h2>Add a Food Truck</h2></header>
</section>
<section class="cards">
<form method="POST">
    <div class="card nologo">
        <section class="content">
                <fieldset>
                    <legend>Truck Info</legend>
                    <label for="applicant">Truck Name</label>
                    <input type="text" name="applicant" placeholder="Taco Pasha's" />
                    <label for="address">Address</label>
                    <input type="text" name="address" placeholder="123 Seasme Street" />
                    <label for="location_description">Location Description</label>
                    <input type="text" name="location_description" placeholder="On the corner in front of Hooper's Store" />
                    <label for="food_items">Food Items</label>
                    <input type="text" name="food_items" placeholder="Tacos, Nachos, and Borscht" />
                </fieldset>
        </section>
        <footer style="flex-flow: row-reverse">
                <button type="submit">Add Truck</button>
        </footer>
    </div>
</form>
</section>

@@ _order.html.ep
<div class="card">
    <header style="display: flexbox; flex-flow: row wrap;">
        <h2><%= $order->{person} %></h2>
        % if ($checkbox) {
            <form method="POST" action="/order/<%= $order->{id} %>/delivered">
                <button>Done</button>
            </form>
        % }
    </header>
    <section class="content logo">
        <dl style="flex-flow: column wrap; gap: 1ex;">
            <dt>Delivered</dt>
            <dd>
                <a href="/truck/<%=$order->{locationid}%>"><%= $order->{applicant} %></a>
            </dd>
            <dt>Address</dt>
            <dd><%= $order->{address} %></dd>
            <dt>Order</dt>
            <dd><%= $order->{food_order} %></dd>
        </dl>
        <p><%= $order->{created_at} %></p>
    </section>
    <section class="content">
        <dl>
            <dt>Drop Off Location</dt>
            <dd><%= $order->{drop_off} %></dd>
            <dt>Phone Number</dt>
            <dd><%= $order->{phone} %></dd>
        </dl>
    </section>
</div>

@@ order/list.html.ep
% layout 'page';
<section class="content">
    <header><h2>Pending Orders</h2></header>
    <p>Jimmy you're gonna have to rush man.</p>
</section>
<section class="cards">
    % for my $o (@$orders) {
        %= include '_order', order => $o, checkbox => 1;
    % }
</section>


@@ order/thanks.html.ep
% layout 'page';
<section class="content">
    <header><h2>Thanks for Ordering</h2></header>
    <p>Jimmy is gonna get to it as soon as possible</p>
</section>
<section class="cards">
    %= include '_order', order => $order, checkbox => 0;
</section>


@@ order/add.html.ep
% layout 'page';
<section class="content">

</section>
<section class="cards">
<form method="POST">
<div class="card nologo">
    <header><h2>Add Your Order</h2></header>
    <section class="content">
            <fieldset>
                <legend>Delivery Info</legend>
                <label for="name">Your Name</label>
                <input type="text" required name="name" placeholder="Bob Smith" />
                <label for="drop_off">Drop Off Location</label>
                <input type="text" required name="drop_off" placeholder="Where to drop off your food" />
                <label for="phone">Your Phone (555-123-4567)</label>
                <input type="tel" required pattern="[0-9]{3}-[0-9]{3}-[0-9]{4}" name="phone" placeholder="In case things go wrong" />
            </fieldset>
            <fieldset>
                <legend>Order Info</legend>

                <label for="truck_id">Food Truck</label>
                <select name="truck_id" style="max-width: 20ex">
                    % for my $t (@$trucks) {
                        <option value="<%= $t->{locationid}; %>">
                            <%= $t->{applicant}; %>
                            (<%= $t->{location_description} // $t->{address}; %>)
                        </option>
                    % }
                </select>
                <label for="order">Your Order</label>
                <textarea rows=5 name="food_order" required></textarea>
            </fieldset>
    </section>
    <footer style="flex-flow: row-reverse; padding: 1ex;">
            <button type="submit">Submit Order</button>
    </footer>
</div>
</form>
</section>

@@ index.html.ep
% layout 'page';

<section id="welcome">
   <header><h2>Welcome to the Food Truck Order Tracker</h2></header>
</section>
<section id="howitworks">
    <header> <h2>How it Works</h2> </header>
    <section class="cards">
    <div class="card">
        <header><h3>Hungry?</h3></header>
        <img src="/img/sander-dalhuisen-nA6Xhnq2Od8-unsplash.jpg" height=125 width=200 class="logo">
        <section class="content">
            <p>Starving? But too busy to go out and get something? Place your
            order and when Jjimmy the Intern makes his run for us we'll add
            your order too.</p>
        </section>
        <footer>
            <a href="/order/add" class="button">Add Your Order</a>
        </footer>
    </div>
    <div class="card">
        <header><h3>Know of a new Food Truck?</h3></header>
        <img src="/img/joana-godinho-Gwv-t9VQiPM-unsplash.jpg" height=125 width=200 class="logo">
        <section class="content">
            <p>Did you find out about some new hot kimchee hot-chicken place
            that you want everyone to know about? Add it to the tracker!</p>
        </section>
        <footer>
            <a href="/truck/add" class="button">Submit Food Truck</a>
        </footer>
    </div>
    </section>
</section>

@@ layouts/page.html.ep
<!doctype html>

<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <title>Food Truck Order Tracker</title>
  <meta name="description" content="">
  <meta name="author" content="Chris Prather">

  <link rel="icon" href="img/favicon.ico">
  <link rel="icon" href="img/favicon.svg" type="image/svg+xml">
  <link rel="apple-touch-icon" href="img/apple-touch-icon.png">

  %= app->htmx->asset

  <link rel="stylesheet" href="/css/styles.css?v=1.0">
</head>

<body>
<header>
	<div class="logo">
		<img class="no_border" src="/img/food_truck_icon.jpg" height="60" width="60" >
		<p class="caption">Food Truck Order Tracker</p>
	</div>
	<nav>
        <input id="menu-toggle" type="checkbox" />
        <label class='menu-button-container' for="menu-toggle">
            <div class='menu-button'></div>
        </label>
		<ul class="menu">
			<li><a href="/#howitworks">How It Works</a></li>
			<li><a href="/order/add" class="button">Add Your Order</a></li>
		</ul>
	</nav>
</header>
<%= content %>
<footer>
	<p>&copy; 2023 </p>
    <p><a class="button ghost" href="/colophon">Colophon</a></p>
</footer>
</body>
</html>


