#! /bin/bash

#------------------viewAddr.sh-----------------
#Autor: Luis C.
#Basado en btcanalizer de s4vitar
#Utilidades en Bash para rastrear transacciones de blockchain utilizanod apis de blockhain.com

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"
#--------------------------------------------------------------------------------------

# URLs utilizadas:
url_base="https://blockchain.info/rawaddr/"
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
   
   echo -e "\n${redColour}[!] Uso: ./viewAddr.sh${endColour}"
   echo -e "\n\t${grayColour}[-a] address ${endColour}${yellowColour} Proporciona información de la dirección${endColour}"
   echo -e "\n\t${grayColour}[-h]${endColour}${yellowColour} Mostrar este panel de ayuda${endColour}\n"
}
#--------------------------------------------------------------------------------------
function getAddrInfo(){
   url_addr=$url_base$1
   jsonAddressInfo=$(curl -s $url_addr)
   echo $jsonAddressInfo | jq '.' > addressInfo.json
   echo "$(clear)"
   echo -e "${blueColour}CAMBIOS${endColour}"
   echo -e "${blueColour}==============================================================================${endColour}"
   echo "Dólares por BTC: $USDperBTC"
   echo "Euros por BTC: $EURperBTC"
   echo ""
   echo -e "${blueColour}==============================================================================${endColour}"
   echo -e "${blueColour}GENERAL${endColour}"
   echo -e "${blueColour}==============================================================================${endColour}"
   direccion=( $(jq '.address' addressInfo.json) )
   totalRecibido=( $(jq '.total_received' addressInfo.json) )
   totalRecibidoBTC=$(echo "scale=4; $totalRecibido/100000000" | bc)
   totalRecibidoUSD=$(echo "scale=2; $totalRecibidoBTC*$USDperBTC" | bc)
   totalRecibidoEUR=$(echo "scale=2; $totalRecibidoBTC*$EURperBTC" | bc)

   totalEnviado=( $(jq '.total_sent' addressInfo.json) )
   totalEnviadoBTC=$(echo "scale=4; $totalEnviado/100000000" | bc)
   totalEnviadoUSD=$(echo "scale=2; $totalEnviadoBTC*$USDperBTC" | bc)
   totalEnviadoEUR=$(echo "scale=2; $totalEnviadoBTC*$EURperBTC" | bc)

   balanceFinal=( $(jq '.final_balance' addressInfo.json) )
   balanceFinalBTC=$(echo "scale=4; $balanceFinal/100000000" | bc)
   balanceFinalUSD=$(echo "scale=2; $balanceFinalBTC*$USDperBTC" | bc)
   balanceFinalEUR=$(echo "scale=2; $balanceFinalBTC*$EURperBTC" | bc)
   

   echo "Dirección: $direccion"
   echo -ne ${yellowColour}
   seperator="___________________________"
   seperator=$seperator$seperator
   TableWidth=66
   printf "%.${TableWidth}s\n" "$seperator"
   printf "| %-15s| %15s| %15s| %15s|\n"  Total BTC USD EUR
   printf "%.${TableWidth}s\n" "$seperator"
   printf "| %-15s| %15s| %15s| %15s|\n"  Total_Recibido $totalRecibidoBTC $totalRecibidoUSD $totalRecibidoEUR
   printf "| %-15s| %15s| %15s| %15s|\n"  Total_Enviado $totalEnviadoBTC $totalEnviadoUSD $totalEnviadoEUR
   printf "| %-15s| %15s| %15s| %15s|\n"  Balance_Final $balanceFinalBTC $BalanceFinalUSD $balanceFinalEUR
   echo -ne ${endColour}
   echo -e "${blueColour}==============================================================================${endColour}"
}
#--------------------------------------------------------------------------------------

#------------------------------------MAIN----------------------------------------------
btcRating

while getopts ":a:h" opt
do
  case $opt in
    a) 
      getAddrInfo $OPTARG
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
