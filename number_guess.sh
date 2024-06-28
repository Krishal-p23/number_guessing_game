#!/bin/bash
# Script for number guessing game

PSQL="psql -U freecodecamp -d number_guess -t --no-align -c"

# function to display results
DISPLAY_RESULT() {
  echo -e "\nYou guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
}

# function to start the game
GAME() {
  # generate a random number between 1-1000
  SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

  # get the guess from user
  echo -e "\nGuess the secret number between 1 and 1000:"
  GUESS=0
  GUESS_COUNT=0

  while [[ $GUESS -ne $SECRET_NUMBER ]]
  do
    read GUESS
    # increment count variable
    (( GUESS_COUNT++ ))

    # check if the guess is an integer
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo -e "\nThat is not an integer, guess again:"
      continue
    fi

    if (( GUESS < SECRET_NUMBER ))
    then
      echo -e "\nIt's higher than that, guess again:"
    elif (( GUESS > SECRET_NUMBER ))
    then
      echo -e "\nIt's lower than that, guess again:"
    fi
  done

  ADD_GAME=$($PSQL "INSERT INTO games(guesses, user_id) VALUES($GUESS_COUNT, $USER_ID)")
}

MAIN() {
  # get username from the user
  echo "Enter your username: "
  read USERNAME

  # get user id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

  # check if user id is found
  if [[ -z $USER_ID ]]
  then
    # greet new user
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
    # add user to database
    ADD_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    # get new user id
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  else
    # get number of games played and the best game
    DETAILS=$($PSQL "SELECT COUNT(game_id), MIN(guesses) FROM games WHERE user_id = $USER_ID")
    IFS='|' read GAMES_PLAYED BEST_GAME <<< $DETAILS

    # greet user
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi

  GAME
  DISPLAY_RESULT
  exit 0
}

MAIN
