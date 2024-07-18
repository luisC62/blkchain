#! /bin/bash

#----------------btcRating.sh-------------------
#Autor: Luis C.
#Basado en btcanalyzer de s4vitar
#Utilidades en Bash para rastrear transacciones de blockchain utilizando apis de blockchain.com


#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

trap ctrl_c INT

url_btcrating="https://blockchain.info/ticker"
USDperBTC=0
EURperBTC=0

#--------------------------------------------------------------------------------------
function ctrl_c(){
  echo -e "\n${redColour}[!]Saliendo...\n${endColour}"
  tput cnorm
  exit 1
}
#--------------------------------------------------------------------------------------
function btcRating(){
   ratingData=$(curl -s $url_btcrating)
   USDperBTC=$(echo $ratingData | jq '.USD.last')
   EURperBTC=$(echo $ratingData | jq '.EUR.last')
}
#--------------------------------------------------------------------------------------

#--------------------------------MAIN--------------------------------------------------
btcRating

#echo "1 Bitcoin vale $USDperBTC dólares"
#echo "1 Bitcoin vale $EURperBTC euros"

echo "$(clear)"

echo -ne "${yellowColour}"

seperator="================="
seperator=$seperator$seperator
rows="|%11s| %12s|\n"
TableWidth=25

printf "| %10s| %10s|\n" USD EUR
printf "%.${TableWidth}s\n" "$seperator"
printf "$rows" "\$"$USDperBTC $EURperBTC"€"
echo ""

echo -ne "${endColour}"






