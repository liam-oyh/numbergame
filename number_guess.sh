#!/bin/bash
PSQL="psql --username=freecodecamp dbname=number_guess -t --no-align -c"

NUMBER_GUESSED=0
GAME_PLAYED=0

MAIN_MENU(){

  # promt user to enter name
  echo Enter your username:
  read NAME

  # check if the name exists
  USERNAME=$($PSQL "SELECT username FROM numberGuess WHERE username='$NAME'")
 
  if [[ -z $USERNAME ]]
  then
    echo Welcome, $(echo $NAME | sed -r 's/^ *| *$//g')! It looks like this is your first time here.
    INSERT_USER=$($PSQL "INSERT INTO numberGuess(username) VALUES('$NAME')")
    GAMES_PLAYED=$(echo $($PSQL "SELECT gameplayed FROM numberGuess WHERE username='$USERNAME'") | sed -r 's/^ *| *$//g')
  # if username exists
  else
    # get games_played and best_game
    GAMES_PLAYED=$(echo $($PSQL "SELECT gameplayed FROM numberGuess WHERE username='$USERNAME'") | sed -r 's/^ *| *$//g')
    BEST_GAME=$(echo $($PSQL "SELECT guess FROM numberGuess WHERE username='$USERNAME'") | sed -r 's/^ *| *$//g')
    echo Welcome back, $(echo $USERNAME | sed -r 's/^ *| *$//g')! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
  fi

  echo -e "\nGuess the secret number between 1 and 1000:"
  GUESS_GAME
}

GUESS_GAME(){
    NUMBER=$(( RANDOM % 1000 + 1 ))
    echo $NUMBER

    GUESSES=1

    CHECK_INPUT
    until [[ $NUMBER_GUESSED == $NUMBER ]]
    do
      if [[ $NUMBER_GUESSED > $NUMBER ]]
      then
        echo "It's lower than that, guess again:"
        CHECK_INPUT
        GUESSES=$(($GUESSES+1))
      else
        echo "It's higher than that, guess again:"
        CHECK_INPUT
        GUESSES=$(($GUESSES+1))
      fi
    done

    # output the game result
    echo You guessed it in $GUESSES tries. The secret number was $NUMBER. Nice job!
    
    # update game play history
    GAME_PLAYED=$(($GAME_PLAYED+1))
    
    GUESS_REC=$($PSQL "SELECT guess FROM numberGuess WHERE username='$NAME'")
   
    if [[ -z $GUESS_REC || $GUESS_REC > $GUESSES ]]
    then
      GUESS_REC=$GUESSES
    fi   
      
    # update game play data
    INSERT_LOG=$($PSQL "UPDATE numberGuess SET gameplayed=$GAME_PLAYED, guess=$GUESS_REC WHERE username='$NAME'")

}

CHECK_INPUT(){
  read GUESS_INPUT
  if ! [[ $GUESS_INPUT =~ ^[0-9]+$ ]]
  then
    echo That is not an integer, guess again:
    read GUESS
  else
    NUMBER_GUESSED=$GUESS_INPUT
  fi  
}

MAIN_MENU
