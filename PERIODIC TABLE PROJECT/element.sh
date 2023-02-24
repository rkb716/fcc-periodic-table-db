#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  ATOMIC_NUMBER=0
  SYMBOL=""
  NAME=""
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    #inputted atomic number
    ATOMIC_NUMBER=$1
    NAME_QUERY_RESULT=$($PSQL "SELECT name FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
    if [[ -z $NAME_QUERY_RESULT ]]
    then
      echo -e "\nI could not find that element in the database."
      exit
    else
      NAME=$NAME_QUERY_RESULT
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
    fi
  else
    #inputted symbol or name
    SYMBOL_QUERY_RESULT=$($PSQL "SELECT name FROM elements WHERE symbol = '$1'")
    if [[ ! -z $SYMBOL_QUERY_RESULT ]]
    then
      SYMBOL=$1
      NAME=$SYMBOL_QUERY_RESULT
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$SYMBOL'")
    else
      NAME_QUERY_RESULT=$($PSQL "SELECT symbol FROM elements WHERE name = '$1'")
      if [[ ! -z $NAME_QUERY_RESULT ]]
      then
        SYMBOL=$NAME_QUERY_RESULT
        NAME=$1
        ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$SYMBOL'")
      else
        echo -e "I could not find that element in the database."
        exit
      fi
    fi
  fi
  TYPE=$($PSQL "SELECT type FROM types INNER JOIN properties USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER")
  MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
  MELTING=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
  BOILING=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
  echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
fi