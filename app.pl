#!/bin/perl
use 5.38.0;
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

get '/register';

app->start;

__DATA__

@@ register.html.ep
% layout 'page';
<section class="cards">
<div class="card">
    <section class="content logo">
        <form method="POST">
            <fieldset>
                <legend>Account Basics</legend>
                <label for="username">Username</label>
                <input type="text" name="username" placeholder="Username" />
                <label for="password">Password</label>
                <input type="text" name="password" placeholder="At least 12 characters" />
            </fieldset>

            <fieldset>
                <legend>Delivery Info</legend>
                <label for="name">Your Name</label>
                <input type="text" name="name" placeholder="Bob Smith" />
                <label for="name">Your Phone</label>
                <input type="text" name="phone" placeholder="So we can figure out where to meetup" />
            </fieldset>
            <button type="submit">Register</button>
        </form>
    </section>
</div>
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
        <header><h3>Sign Up</h3></header>
        <img class="logo" height="200" width="200" />
        <section class="content">
            <p>Lorem ipsum dolores</p>
        </section>
        <footer>
            <a href="/register" class="button">Sign Up!</a>
        </footer>
    </div>
    <div class="card">
        <header><h3>Already Have An Account?</h3></header>
        <img class="logo" height="200" width="200" />
        <section class="content">
            <p>Lorem ipsum dolores</p>
        </section>
        <footer>
            <a href="/order/add" class="button">Add Your Order</a>
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
		<img class="no_border" src="/img/logo_small.png" height="60" width="60" >
		<p class="caption">Food Truck Order Tracker</p>
	</div>
	<nav>
        <input id="menu-toggle" type="checkbox" />
        <label class='menu-button-container' for="menu-toggle">
            <div class='menu-button'></div>
        </label>
		<ul class="menu">
			<li><a href="/#howitworks">How It Works</a></li>
			<li><a class="button">Add Your Order</a></li>
		</ul>
	</nav>
</header>
<%= content %>
<footer>
	<p>&copy; 2023</p>
</footer>
</body>
</html>


