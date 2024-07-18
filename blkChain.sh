#! /bin/bash

#-------------blkChain.sh--------------
#Autor: Luis C.
#Basado en btcanalizer de s4vitar
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

#--------------------------------------------------------------------------------------
# URLs utilizadas:
url_btcrating="https://blockchain.info/ticker"
url_ut="https://blockchain.info/unconfirmed-transactions?format=json"

# Variables Globales
nresults=20 #Limite del número de resultados (Por defecto, 20)
USDperBTC=0;
EURperBTC=0
BTC="BTC"
USD="\$"
EUR="EUR"
#--------------------------------------------------------------------------------------
function ctrl_c(){
  echo -e "\n${redColour}[!]Saliendo...\n${endColour}"
  tput cnorm
  exit 1
}
#--------------------------------------------------------------------------------------
function dependencies(){
  tput civis; counter=0
  dependencies_array=(jq bc)

  echo; for program in "${dependencies_array[@]}"; do
  if [ ! "$(command -v $program)" ]; then
    echo -e "${redColour}[X]${endColour}${grayColour} $program${endColour}${yellowColour} no está instalado${endColour}"; sleep 1
    echo -e "\n${yellowColour}[i]${endColour}${grayColour} Instalando...${endColour}"; sleep 1
    apt install $program -y > /dev/null 2>&1
    echo -e "\n${greenColour}[V]${endColour}${grayColour} $program${endColour}${yellowColour} instalado${endColour}\n"; sleep 2
    let counter+=1
  fi
  done
  tput cnorm
}
#--------------------------------------------------------------------------------------
function btcRating(){
   ratingData=$(curl -s $url_btcrating)
   USDperBTC=$(echo $ratingData | jq '.USD.last')
   EURperBTC=$(echo $ratingData | jq '.EUR.last')
}
#--------------------------------------------------------------------------------------
function printBtcRating(){
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
  echo -e "\n"
  tput cnorm
  exit 1
}
#--------------------------------------------------------------------------------------
function helpPanel(){
   echo "$(clear)"
   echo -e "\n${redColour}[!] Uso: ./blkChain.sh${endColour}"
   for i in $(seq 1 85); do echo -ne "${redColour}-"; done; echo -ne "${endColour}"
   echo -e "\n\n\t${grayColour}[-b]${endColour}${yellowColour} Ver cotización del bitcoin${endColour}"
   echo -e "\n\n\t${grayColour}[-e]${endColour}${yellowColour} Modo exploración${endColour}"
   echo -e "\n\t${grayColour}[-h]${endColour}${yellowColour} Mostrar este panel de ayuda${endColour}\n"
   for i in $(seq 1 85); do echo -ne "${redColour}-"; done; echo -ne "${endColour}"
   echo -e "\n"
   tput cnorm; exit 1
}
#--------------------------------------------------------------------------------------
function getDataArrays(){
   echo "$(clear)"
   jsonUTransactions=$(curl -s $url_ut)
   echo $jsonUTransactions | jq '.[]' > unconfirmedTransactions.json
   hashArray=( $(jq '.[].hash' unconfirmedTransactions.json) )
   echo "Se han capturado datos de ${#hashArray[@]} transacciones no confirmadas"
   for (( i=0; i<${#hashArray[@]}; i++ )) 
   do
     hashArray[$i]=$(echo ${hashArray[$i]} | sed 's/\"//g')
     valueArray=( $(jq '.['$i'].inputs[].prev_out.value' unconfirmedTransactions.json) )
     value=0
     for (( j=0; j<${#valueArray[@]}; j++ ))
     do
       (( value += ${valueArray[$j]} )) 
     done
     valueBTC=$(echo "scale=6; $value/100000000" | bc )  
     valueUSD=$(echo "scale=1; $valueBTC*$USDperBTC" | bc ) 
     valueEUR=$(echo "scale=1; $valueBTC*$EURperBTC" | bc ) 
     echo "$i: ${hashArray[$i]}---$valueBTC$BTC----$USD$valueUSD-----$valueEUR$EUR"
   done
   verDetalle
   #echo "$(./uctValue.sh -e ${hashArray[0]})"
   
}
#--------------------------------------------------------------------------------------
function verDetalle(){
echo "¿Quieres examinar una transacción en especial? (s/n)"
   read sino
   if [ $sino == "s" ]
   then
     echo "Introduce el número de transacción: "
     read numt
     echo "$(./uctValue.sh -e ${hashArray[$numt]})"
   else
     echo "Hsta la vista"
   fi 
}
#------------------------------------MAIN----------------------------------------------
dependencies #Mira si hay que instalar alguna dependencia
parameter_counter=0
btcRating #Revisa las cotizaciones del BitCoin en dólares y euros

while getopts ":ehb" opt
do
  case $opt in
    e) 
      getDataArrays
      ;;
    h)
      helpPanel
      ;;
    b)
      printBtcRating
      ;;
    ?)
      echo "Opción -${OPTARG} no válida"
      tput cnorm; exit 1
      ;;
      
  esac
done

tput cnorm; exit 1

