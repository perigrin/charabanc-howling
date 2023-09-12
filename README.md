# Charabanc Howling

This is a solution to the Estee Lauder coding challenge.

## SYNOPSIS

To get it running (assuming you've got a install of perl `5.38.0`):

```
carton install
carton exec morbo app.pl
```

If you don't have `5.38.0` but you have `docker` then you can do (untested):

```
docker build .
docker run charabanc
```

### DESCRIPTION

> A charabanc or "char-à-banc" /ˈʃærəbæŋk/ (often pronounced "sharra-bang"
> in colloquial British English) is a type of horse-drawn vehicle or early motor
> coach, usually open-topped, common in Britain during the early part of the 20th
> century. It has "benched seats arranged in rows, looking forward, commonly used
> for large parties, whether as public conveyances or for excursions".
> -- [Wikipedia](https://en.wikipedia.org/wiki/Charabanc)

This is a REST application that manages simple orders from the Food Trucks in
San Francisco. The user-visible UI is I hope pretty self explanatory. After
orders are entered someone can visit `/order/list` to get a list of all the
pending orders and check them off when they're delivered.

The application uses SQLite and Mojolicious.

### FUTURE PLANS

There's a distinct lack of validation in places, it could be improved.
Additionally the testing needs to be fleshed out to cover all the endpoints.

If this is to be more than a demo app it could be modified to deploy to
postgresql fairly easily but it doesn't not currently support that. You'd need
to update the sql to be portable and the default URLs.
