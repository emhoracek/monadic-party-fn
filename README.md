# monadic-party

## App setup instructions

### Install Stack

### Setup and build the app

Clone the repo: `git clone _`.

In the repo directory, run `stack setup && stack build`.

## Database setup instructions (workshop attendees only)

If you are attending the workshop right now, follow the instructions below.

### Setup environment to connect to AWS database

Create a file called `.env` with the following line:

`PG_CONNECT="host=SOMEAWSHOST port=5432 dbname=monadic_party_db user=monadic_party_user password=REPLACEME"`

Libby will give you the password during the workshop. She'll delete the database after the workshop, so use the instructions below if you want to keep working on your project after that.

## Database setup instructions (after the workshop)

### Install PostgreSQL

### Create the databases

First create a user: `createuser monadic_party_user -W` and enter a password.

Next, create the database: `createdb -O monadic_party_user monadic_party_db`

### Setup the environment to connect to your local database

Create a file called `.env` with the following line:

`PG_CONNECT="host=localhost port=5432 dbname=monadic_party_db user=monadic_party_user password=111"`

### Run the migrations

Run `stack exec migrate devel up` to run add the user table to the database.