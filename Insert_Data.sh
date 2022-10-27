#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE games, teams CASCADE")
echo $($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1")
echo $($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1")

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WGOALS OGOALS 
do
  if [[ $WINNER != 'winner' ]]
  then
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    if [[ -z $WINNER_ID ]]
    then
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi
    fi
  fi

  if [[ $OPPONENT != 'opponent' ]]
  then
    OPPONENT_ID=$($PSQL "select team_id FROM teams WHERE name='$OPPONENT'")

    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPONENT
      fi
    fi
  fi


  W_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  O_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

  if [[ -n $W_ID || -n $O_ID ]]
  then
    if [[ $YEAR != "year" ]]
    then
      INSERT_GAMES_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, Winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $W_ID, $O_ID, $WGOALS, $OGOALS)")
      if [[ $INSERT_GAMES_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into games, $YEAR
      fi
    fi 
  fi
done
