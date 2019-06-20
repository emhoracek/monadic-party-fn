# monadic-party

## App setup instructions

### Install Stack

### Setup and build the app

Clone the repo: `git clone https://github.com/emhoracek/monadic-party-fn`.

In the repo directory, run `stack setup && stack build`.

## Database setup instructions

### Install PostgreSQL

### Create the databases

First create a user: `createuser monadic_party_user -W` and enter a password.

Next, create the database: `createdb -O monadic_party_user monadic_party_db`

### Run the migrations

Run `stack exec migrate up` to run add the user table to the database.