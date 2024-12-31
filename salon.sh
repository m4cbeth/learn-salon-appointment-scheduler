#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"
echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"
MAIN_MENU() {

if [[ $1 ]]; then
  echo $1
fi

$PSQL "SELECT service_id, name FROM services" | while IFS="|" read SERVICE_ID NAME
do
  echo "$SERVICE_ID) $NAME"
done

read SERVICE_ID_SELECTED
INPUT_RESULT=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")

if [[ -z $INPUT_RESULT ]]; then
  echo -e "\nI could not find that service. What would you like today?"
  MAIN_MENU 
else
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers where phone = '$CUSTOMER_PHONE'")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers where phone = '$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]; then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_NAME_RESULT=$($PSQL "INSERT INTO customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers where phone = '$CUSTOMER_PHONE'")
  fi

  echo -e "\nWhat time would you like your $INPUT_RESULT, $CUSTOMER_NAME?"
  read SERVICE_TIME

  INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  if [[ $INSERT_RESULT == "INSERT 0 1" ]]; then
      echo -e "\nI have put you down for a $INPUT_RESULT at $SERVICE_TIME, $CUSTOMER_NAME."
    else
      echo -e "\nAn error occurred while scheduling your appointment. Please try again."
  fi
fi
}


MAIN_MENU
