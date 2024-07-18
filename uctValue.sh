#! /bin/bash

#---------------------uctValue.sh----------------------
#Autor: Luis C.
#Basado en btcanalizer de s4avitar
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
url_suct="https://blockchain.info/rawtx/"
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
function helpPanel(){
   
   echo -e "\n${redColour}[!] Uso: ./uctValue.sh${endColour}"
   echo -e "\n\t${grayColour}[-e] hash ${endColour}${yellowColour} Proporciona información de la transacción${endColour}"
   echo -e "\n\t${grayColour}[-h]${endColour}${yellowColour} Mostrar este panel de ayuda${endColour}\n"
}
#--------------------------------------------------------------------------------------
function getHashInfo(){
    echo "$(clear)"
    echo -e "${blueColour}CAMBIOS${endColour}"
    echo -e "${blueColour}==============================================================================${endColour}"
    echo "Dólares por BTC: $USDperBTC"
    echo "Euros por BTC: $EURperBTC"
    echo ""
    echo -e "${blueColour}==============================================================================${endColour}"
    echo -e "${blueColour}GENERAL${endColour}"
    echo -e "${blueColour}==============================================================================${endColour}"
    hash=$1
    url_suct=$url_suct$hash
    jsonSingleTransactionInfo=$(curl -s $url_suct)
    echo $jsonSingleTransactionInfo | jq '.' > singleTransaction.json
    inputValueArray=( $(jq '.inputs[].prev_out.value' singleTransaction.json) )
    inputAddrArray=( $(jq '.inputs[].prev_out.addr' singleTransaction.json) )
    outValueArray=( $(jq '.out[].value' singleTransaction.json) )
    outAddrArray=( $(jq '.out[].addr' singleTransaction.json) )
    fee=( $(jq '.fee' singleTransaction.json) )
    timehash=( $(jq '.time' singleTransaction.json) )
    timePrep=$(date -d @$timehash)
    echo "Hash: $hash"
    echo "fee: $fee SAT"
    echo "time: $timePrep"
    echo "=============================================================================="
    echo ""
    echo -e "${blueColour}INPUTS${endColour}"
    echo -e "${blueColour}==============================================================================${endColour}"
    totalInputValue=0
    for (( i=0; i<${#inputAddrArray[@]}; i++ )) 
    do
      inValBTC=$(echo "scale=4; ${inputValueArray[$i]}/100000000" | bc)
      inValUSD=$(echo "scale=2; $inValBTC*$USDperBTC" | bc)
      inValEUR=$(echo "scale=2; $inValBTC*$EURperBTC" | bc)
      inAddress=$(echo ${inputAddrArray[$i]} | sed 's/\"//g')
      echo "Dirección: $inAddress"
      echo "Valor: $inValBTC BTC        \$$inValUSD        $inValEUR€"
      (( totalInputValue += ${inputValueArray[$i]} ))  
      echo "-------------------------------------------------------------------------------"
    done
    totInValBTC=$(echo "scale=4; $totalInputValue/100000000" | bc)
    totInValUSD=$(echo "scale=2; $totInValBTC*$USDperBTC" | bc)
    totInValEUR=$(echo "scale=2; $totInValBTC*$EURperBTC" | bc)
    echo -e "${yellowColour}Total entradas: $totInValBTC BTC        \$$totInValUSD        $totInValEUR€${endColour}"
    echo -e "${blueColour}==============================================================================${endColour}"
    echo ""
    echo -e "${blueColour}OUTPUTS${endColour}"
    echo -e "${blueColour}==============================================================================${endColour}"
    totalOutputValue=0
    for (( i=0; i<${#outAddrArray[@]}; i++ )) 
    do
      outValBTC=$(echo "scale=4; ${outValueArray[$i]}/100000000" | bc)
      outValUSD=$(echo "scale=2; $outValBTC*$USDperBTC" | bc)
      outValEUR=$(echo "scale=2; $outValBTC*$EURperBTC" | bc)
      outAddress=$(echo ${outAddrArray[$i]} | sed 's/\"//g')
      echo "Dirección: $outAddress}"
      echo "Valor: $outValBTC BTC        \$$outValUSD        $outValEUR€"
      (( totalOutputValue += ${outValueArray[$i]} )) 
      echo "-------------------------------------------------------------------------------"
    done
    totOutValBTC=$(echo "scale=4; $totalOutputValue/100000000" | bc)
    totOutValUSD=$(echo "scale=2; $totOutValBTC*$USDperBTC" | bc)
    totOutValEUR=$(echo "scale=2; $totOutValBTC*$EURperBTC" | bc)
    echo -e "${yellowColour}Total salidas: $totOutValBTC BTC        \$$totOutValUSD        $totOutValEUR€${endColour}"
    echo -e "${blueColour}==============================================================================${endColour}"
}
#------------------------------------MAIN----------------------------------------------
btcRating

while getopts ":e:h" opt
do
  case $opt in
    e) 
      getHashInfo $OPTARG
      ;;
    h)
      helpPanel
      tput cnorm; exit 1
      ;;
    ?)
      echo -e "\n${redColour}Opción -${OPTARG} no válida${endColour}"
      helpPanel
      tput cnorm; exit 1
      ;;
      
  esac
done



