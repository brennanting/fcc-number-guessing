#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=numbergame -t --no-align -c"

STARTUP_GAME() {
  echo "Enter your username:"
  read USERNAME

  # get user id
  USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")

  # if user not found
  if [[ -z $USER_ID ]]
    then
      # add user to database
      USER_ADD_RESULT=$($PSQL "insert into users(username) values('$USERNAME')")
  fi

  # new user id
  USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")

  # retrieve user data
  USER_DATA=$($PSQL "select username, games_played, best_game from users where user_id=$USER_ID")
  echo $USER_DATA | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME
    do
      # if username not found or no data
      if [[ $USER_ADD_RESULT = 'INSERT 0 1' || -z $GAMES_PLAYED || -z $BEST_GAME ]]
        then
          echo "Welcome, $USERNAME! It looks like this is your first time here."
        else
          # welcome message with data
          echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
      fi
  done

  # generate number to guess
  NUMBER_TO_GUESS=$(( $RANDOM % 1000 + 1))
  NUMBER_OF_GUESSES=0
  echo "Guess the secret number between 1 and 1000:"
  read NUMBER_INPUT
  
  # while guess is wrong
  while [[ $NUMBER_INPUT != $NUMBER_TO_GUESS ]]
    do
    if [[ ! $NUMBER_INPUT =~ ^[0-9]+$ ]]
      then
        echo "That is not an integer, guess again:"
      else
        (( NUMBER_OF_GUESSES++ ))
        if [[ $NUMBER_INPUT -gt $NUMBER_TO_GUESS ]]
          then 
            echo "It's lower than that, guess again:"
          else 
            echo "It's higher than that, guess again:"
        fi
    fi
      read NUMBER_INPUT
  done

  # factor in final guess
  (( NUMBER_OF_GUESSES ++ ))

  # get user data
  USER_DATA=$($PSQL "select username, games_played, best_game from users where user_id=$USER_ID")
  echo $USER_DATA | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME
    do
      (( GAMES_PLAYED ++ ))
      if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME || -z $BEST_GAME ]]
        then
          BEST_GAME=$NUMBER_OF_GUESSES
      fi
      USER_DATA_UPDATE_RESULT=$($PSQL "update users set games_played=$GAMES_PLAYED, best_game=$BEST_GAME where user_id=$USER_ID")
  done

  # exit message
  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER_TO_GUESS. Nice job!"
}

STARTUP_GAME