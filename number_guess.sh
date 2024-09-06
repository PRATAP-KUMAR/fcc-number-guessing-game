#!/bin/bash

PSQL="psql -U freecodecamp -d number_guess --tuples-only -c"

echo -e "\nWelcome to Number Guessing Game"

NUMBER=$((1 + RANDOM%1000))

echo "Enter your username:"
read NAME

GUESSES=0

LOOP() {
    read INPUT

    if ! [[ $INPUT =~ ^[0-9]+$ ]]
    then
      GUESSES=$((GUESSES+1))
      echo "That is not an integer, guess again:"
      LOOP
    elif [[ $INPUT -lt $NUMBER ]]
    then
        GUESSES=$((GUESSES+1))
        echo "It's lower than that, guess again:"
        LOOP
    elif [[ $INPUT -gt $NUMBER ]]
    then
        GUESSES=$((GUESSES+1))
        echo "It's higher than that, guess again:"
        LOOP
    else
        GUESSES=$((GUESSES+1))
        ID=$(echo $USER_ID | cut -d' ' -f 1)
        QUERY=$($PSQL "insert into games values(default, $GUESSES, $ID)")
        echo -e "You guessed it in $GUESSES tries. The secret number was $NUMBER. Nice job!"
        exit 0
    fi
}

USER_ID=$($PSQL "select id from users where username = '$NAME'");
if [[ -z $USER_ID ]]
then
    USER_ID=$($PSQL "insert into users values(default, '$NAME') returning id")
    echo "Welcome, $NAME! It looks like this is your first time here."
    
else
    PLAYED=$($PSQL "select count(id), min(guesses) from games where user_id = $USER_ID")
    echo $PLAYED | while read sum foo min
    do
        echo "Welcome back, $NAME! You have played $sum games, and your best game took $min guesses."
    done
fi

echo "Guess the secret number between 1 and 1000:"
LOOP
