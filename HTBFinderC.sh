#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"
blackColour="\e[0;30m\033[1m"

function ctrl_c(){
    echo -e "\n\n${redColour}[!] Saliendo...\n${endColour}"
    tput cnorm; exit 1
}

# CTRL + C
trap ctrl_c INT

function helpPanel(){
    echo -e "\n ${yellowColour}[+]${endColour} ${grayColour}Uso:${endColour}"
    echo -e "\t${purpleColour}u)${endColour} ${grayColour}Actualizar base de datos de las máquinas${endColour}"
    echo -e "\t${purpleColour}m)${endColour} ${grayColour}Buscar por el nombre de una máquina${endColour}"
    echo -e "\t${purpleColour}i)${endColour} ${grayColour}Buscar por la IP de una máquina${endColour}"
    echo -e "\t${purpleColour}d)${endColour} ${grayColour}Buscar por la dificultad de una máquina${endColour}"
    echo -e "\t${purpleColour}o)${endColour} ${grayColour}Buscar por el sistema operativo de una máquina${endColour}"
    echo -e "\t${purpleColour}s)${endColour} ${grayColour}Buscar las habilidades requeridas de una máquina${endColour}"
    echo -e "\t${purpleColour}l)${endColour} ${grayColour}Buscar por el estilo de certificación de una máquina${endColour}"
    echo -e "\t${purpleColour}h)${endColour} ${grayColour}Mostrar el panel de ayuda general${endColour}\n"
}


function updateMachines(){
    if [ ! -f bundle.js ]; then
      tput civis
      echo -e "\n${redColour}[!]${endColour} ${grayColour}La base de datos no ha sido encontrada${endColour}"
      sleep 1
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}La base de datos está siendo descargada...${endColour}"
      curl -s -X GET $machines_url > bundle.js
      js-beautify bundle.js | sponge bundle.js
      echo -e "\n${greenColour}[+]${endColour} ${grayColour}La base de datos ha sido descargada${endColour}\n"
      tput cnorm
    else
      tput civis
      echo -e "\n${greenColour}[+]${endColour} ${grayColour}La base de datos ha sido encontrada${endColour}"
      sleep 1
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Comprobando integridad de la base de datos...${endColour}"
      curl -s -X GET $machines_url > bundle_temp.js
      js-beautify bundle_temp.js | sponge bundle_temp.js
      md5_bundle="$(md5sum bundle.js | awk '{print $1}')"
      md5_temp_bundle="$(md5sum bundle_temp.js | awk '{print $1}')"
      if [ "$md5_bundle" == "$md5_temp_bundle" ]; then
        echo -e "\n${greenColour}[+]${endColour} ${grayColour}La base de datos estaba actualizada${endColour}\n"
        rm bundle.js
        mv bundle_temp.js bundle.js && tput cnorm
      else
        echo -e "\n${redColour}[!]${endColour} ${grayColour}La base de datos no estaba actualizada${endColour}"
        sleep 1
        echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Actualizando la base de datos...${endColour}"
        rm bundle.js
        mv bundle_temp.js bundle.js
        sleep 0.5
        echo -e "\n${greenColour}[+]${endColour} ${grayColour}La base de datos ha sido actualizada${endColour}\n"
        tput cnorm
      fi
    fi
}

function searchMachine(){
    machineNameCheck="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//')"

    if [ "$machineNameCheck" ]; then
    # A tener en cuenta que el segundo sed de TODAS las variable definidas aquí se puede ahorrar, grepeando por "name:" o lo que corresponda.
      printname=$(cat bundle.js | awk "/name: \"${machineName}\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | sed 's/name/Nombre/' | grep "Nombre:" | sed 's/Nombre://' | sed 's/^ *//')
      printip=$(cat bundle.js | awk "/name: \"${machineName}\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | sed 's/ip/IP/' | grep "IP:" | sed 's/IP://' | sed 's/^ *//')
      printso=$(cat bundle.js | awk "/name: \"${machineName}\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | sed 's/so/SO/' | grep "SO:" | awk '{print $2}')
      printdificultad=$(cat bundle.js | awk "/name: \"${machineName}\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | sed 's/dificultad/Dificultad/' | grep "Dificultad:" | sed 's/Dificultad://' | sed 's/^ *//')
      printskills=$(cat bundle.js | awk "/name: \"${machineName}\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | sed 's/skills/Skills/' | grep "Skills:" | sed 's/Skills://' | sed 's/^ *//')
      printlike=$(cat bundle.js | awk "/name: \"${machineName}\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | sed 's/like/Estilo/' | grep "Estilo:" | sed 's/Estilo://' | sed 's/^ *//')
      printyoutube=$(cat bundle.js | awk "/name: \"${machineName}\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | sed 's/youtube/YouTube/' | grep "YouTube:" | awk '{print $2}')
      printactivedir=$(cat bundle.js | awk "/name: \"${machineName}\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | tr -d ':' | sed 's/^ *//' | grep "activeDirectory" | sed 's/activeDirectory//' | sed 's/^ *//' | sed 's/Active Directory/✔/')
      
      echo -e "\n${greenColour}[+]${endColour} ${grayColour}Listando las propiedades de la máquina${endColour} ${blueColour}$machineName${endColour}${grayColour}:${endColour}\n"
      echo -e "${blueColour}Nombre: ${endColour}${grayColour}${printname}${endColour}"
      echo -e "${blueColour}IP: ${endColour}${grayColour}${printip}${endColour}"
      echo -e "${blueColour}SO: ${endColour}${grayColour}${printso}${endColour}"
      echo -e "${blueColour}Dificultad: ${endColour}${grayColour}${printdificultad}${endColour}"
      echo -e "${blueColour}Skills: ${endColour}${grayColour}${printskills}${endColour}"
      echo -e "${blueColour}Estilo: ${endColour}${grayColour}${printlike}${endColour}"
      echo -e "${grayColour}You${endColour}${redColour}Tube${endColour}${grayColour}: ${endColour}${grayColour}${printyoutube}${endColour}\n"
      if [ "$printactivedir" ]; then
        echo -e "${blueColour}Active Directory: ${endColour}${greenColour} ${endColour}\n"
      else
        variableFantasma=0
      fi
    else
      echo -e "\n${redColour}[!]${endColour} ${grayColour}La máquina${endColour} ${blueColour}${machineName}${endColour} ${grayColour}no existe${endColour}"
      tput civis && sleep 1; tput cnorm && algoMas
    fi
}

function searchIP(){
  ipcheck=$(cat bundle.js | grep -w "${searchxip}" -B 3 | grep "name:" | sed 's/^ *//' | tr -d '"' | tr -d ',' | sed 's/name: //')

  if [ ${ipcheck} ]; then
    ipprint=$(cat bundle.js | grep -w "${searchxip}" -B 3 | grep "name:" | sed 's/^ *//' | tr -d '"' | tr -d ',' | sed 's/name: //')
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}La máquina que corresponde a la IP es:${endColour} ${blueColour}${ipprint}${endColour}\n"
    echo -e "${yellowColour}[?]${endColour} ${grayColour}¿Deseas mostrar las propiedades de${endColour} ${blueColour}${ipprint}${endColour}${grayColour}?${endColour} ${greenColour}y${endColour}${grayColour}/${endColour}${redColour}n${endColour}\n"
    read -r respuesta
  
    if [ "${respuesta}" == "y" ]; then
      machineName=${ipprint}; clear && searchMachine
    elif [ "${respuesta}" == "n" ]; then
      algoMas
    else
      echo -e "${respuesta_no_valida}"
    fi
  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}La IP que has buscado no existe${endColour}\n"
  fi
}

function algoMas(){
  declare -i variablealgomas=0
  echo -e "\n${yellowColour}[?]${endColour} ${grayColour}¿Hay algo más que quieras hacer?${endColour} ${greenColour}y${endColour}${grayColour}/${endColour}${redColour}n${endColour}\n"
  read -r algomas

  while [ "$(echo $algomas)" == "y" ]; do
    if [ $variablealgomas -ge 1 ]; then
      echo -e "\n${yellowColour}[?]${endColour} ${grayColour}¿Hay algo más que quieras hacer?${endColour} ${greenColour}y${endColour}${grayColour}/${endColour}${redColour}n${endColour}\n"
      read -r algomas
    fi
    if [ "$(echo $algomas)" == "y" ]; then
      echo -e "\n${greenColour}[+]${endColour} ${grayColour}Estas son las opciones disponibles: ${endColour}\n"
      echo -e "\t${purpleColour}u)${endColour} ${grayColour}Actualizar base de datos de las máquinas${endColour}"
      echo -e "\t${purpleColour}m)${endColour} ${grayColour}Buscar por el nombre de una máquina${endColour}"
      echo -e "\t${purpleColour}i)${endColour} ${grayColour}Buscar por la IP de una máquina${endColour}"
      echo -e "\t${purpleColour}d)${endColour} ${grayColour}Buscar por la dificultad de una máquina${endColour}"
      echo -e "\t${purpleColour}o)${endColour} ${grayColour}Buscar por el sistema operativo de una máquina${endColour}"
      echo -e "\t${purpleColour}s)${endColour} ${grayColour}Buscar las habilidades requeridas de una máquina${endColour}"
      echo -e "\t${purpleColour}l)${endColour} ${grayColour}Buscar por el estilo de certificación de una máquina${endColour}"
      echo -e "\t${purpleColour}h)${endColour} ${grayColour}Mostrar el panel de ayuda general${endColour}\n"
      echo -en "${greenColour}[+]${endColour} ${grayColour}Inserte lo que quiera hacer:${endColour} "
      read -r content
      let variablealgomas+=1
      ./$0 $content
    fi
  done
  if [ "${algomas}" == "n" ]; then
    echo -e "${redColour}\n[!] Saliendo...\n${endColour}"
  else
    echo -e "${respuesta_no_valida}"; algoMas
  fi
}

function searchDificultad(){
  dificultadChecker="$(cat bundle.js | grep "dificultad: \"$dificultad\"" -B 5 | grep "name: " | awk 'NF{print$NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$dificultadChecker" ]; then
  
    if [ "$dificultad" == "Fácil" ]; then
      echo -e "\n${greenColour}[+]${endColour} ${grayColour}Las máquinas de dificultad${endColour} ${greenColour}${dificultad}${endColour} ${grayColour}son:${endColour}\n\n${dificultadChecker}\n"
    elif [ "$dificultad" == "Media" ]; then
      echo -e "\n${greenColour}[+]${endColour} ${grayColour}Las máquinas de dificultad${endColour} ${yellowColour}${dificultad}${endColour} ${grayColour}son:${endColour}\n\n${dificultadChecker}\n"
    elif [ "$dificultad" == "Difícil" ]; then
      echo -e "\n${greenColour}[+]${endColour} ${grayColour}Las máquinas de dificultad${endColour} ${redColour}${dificultad}${endColour} ${grayColour}son:${endColour}\n\n${dificultadChecker}\n"
    elif [ "$dificultad" == "Insane" ]; then
      echo -e "\n${greenColour}[+]${endColour} ${grayColour}Las máquinas de dificultad${endColour} ${blackColour}${dificultad}${endColour} ${grayColour}son:${endColour}\n\n${dificultadChecker}\n"
    else
      variableFantasma=1
    fi

  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}La dificultad no es válida${endColour}"
    tput civis && sleep 1; tput cnorm && algoMas
  fi
}

function searchOS(){
  osChecker="$(cat bundle.js | grep "so: \"${system}\"" -B 4 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$osChecker" ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Las máquinas${endColour} ${blueColour}${system}${endColour} ${grayColour}son:${endColour}\n\n ${osChecker}\n"
  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}El sistema operativo no es válido${endColour}"
    tput civis && sleep 1; tput cnorm && algoMas
  fi
}

function searchSystemDificultad(){
  combinationCheck=$(cat bundle.js | grep "so: \"$system\"" -C 4 | grep "dificultad: \"$dificultad\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)

  if [ "$combinationCheck" ]; then
    
    if [ "$dificultad" == "Fácil" ]; then
      echo -e "\n${greenColour}[+]${endColour} ${grayColour}Las máquinas de dificultad${endColour} ${greenColour}${dificultad}${endColour} ${grayColour}y sistema${endColour} ${blueColour}${system}${endColour} ${grayColour}son:${endColour}\n\n${combinationCheck}\n"
    elif [ "$dificultad" == "Media" ]; then
      echo -e "\n${greenColour}[+]${endColour} ${grayColour}Las máquinas de dificultad${endColour} ${yellowColour}${dificultad}${endColour} ${grayColour}y sistema${endColour} ${blueColour}${system}${endColour} ${grayColour}son:${endColour}\n\n${combinationCheck}\n"
    elif [ "$dificultad" == "Difícil" ]; then
      echo -e "\n${greenColour}[+]${endColour} ${grayColour}Las máquinas de dificultad${endColour} ${redColour}${dificultad}${endColour} ${grayColour}y sistema${endColour} ${blueColour}${system}${endColour} ${grayColour}son:${endColour}\n\n${combinationCheck}\n"
    elif [ "$dificultad" == "Insane" ]; then
      echo -e "\n${greenColour}[+]${endColour} ${grayColour}Las máquinas de dificultad${endColour} ${blackColour}${dificultad}${endColour} ${grayColour}y sistema${endColour} ${blueColour}${system}${endColour} ${grayColour}son:${endColour}\n\n${combinationCheck}\n"
    else
      variableFantasma=1
    fi
  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}El sistema o la dificultad no han sido encontrados${endColour}"
    tput civis && sleep 1; tput cnorm && algoMas
  fi
}

function searchSkills(){
  #echo -e "Las skills son $skills"
  skills=$1
  skillChecker=$(cat bundle.js | grep "skills: " -B 6 | grep -iw "$skills" -B 6 | grep "name: " | tr -d '"' | tr -d ',' | awk 'NF{print$NF}' | column)

  if [ "${skillChecker}" ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Las máquinas que requieren de la skill${endColour} ${blueColour}${skills}${endColour} ${grayColour}son:\n${endColour} \n${skillChecker}\n"
  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}No hay máquinas que cumplan con la${endColour}${blackColour}/s${endColour} ${grayColour}skill${endColour}${blackColour}/s${endColour} ${skillChecker}\n"
    tput civis && sleep 1; tput cnorm && algoMas
  fi
}

function searchSkillsSystem(){
  skillsystemChecker=$(cat bundle.js | grep "skills: " -C 6 | grep -iw "$skills" -C 6 | grep "$system" -C6 | grep "name: " | tr -d '"' | tr -d ',' | awk 'NF{print$NF}' | column)

  if [ "${skillsystemChecker}" ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Las máquinas${endColour} ${blueColour}${system}${endColour} con la${endColour}${blackColour}/s${endColour} ${grayColour}skill${endColour}${blackColour}/s${endColour} ${blueColour}${skills}${endColour} ${grayColour}son:${endColour} \n\n${skillsystemChecker}\n"
  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}No hay máquinas que cumplan con los requisitos${endColour}\n"
    tput civis && sleep 1; tput cnorm && algoMas
  fi
}

function searchSkillsDificultad(){
  skillsdificultadChecker=$(cat bundle.js | grep "skills: " -C 6 | grep -iw "$skills" -C 6 | grep "$dificultad" -C 6 | grep "name: " | tr -d '"' | tr -d ',' | awk 'NF{print$NF}' | column)
  
  if [ "${skillsdificultadChecker}" ]; then
    
    if [ "$dificultad" == "Fácil" ]; then
      echo -e "\n${greenColour}[+]${endColour} ${grayColour}Las máquinas${endColour} ${greenColour}${dificultad}${endColour} con la${endColour}${blackColour}/s${endColour} ${grayColour}skill${endColour}${blackColour}/s${endColour} ${blueColour}${skills}${endColour} ${grayColour}son:${endColour} \n\n${skillsdificultadChecker}\n"
    elif [ "$dificultad" == "Media" ]; then
      echo -e "\n${greenColour}[+]${endColour} ${grayColour}Las máquinas${endColour} ${yellowColour}${dificultad}${endColour} con la${endColour}${blackColour}/s${endColour} ${grayColour}skill${endColour}${blackColour}/s${endColour} ${blueColour}${skills}${endColour} ${grayColour}son:${endColour} \n\n${skillsdificultadChecker}\n"
    elif [ "$dificultad" == "Difícil" ]; then
      echo -e "\n${greenColour}[+]${endColour} ${grayColour}Las máquinas${endColour} ${redColour}${dificultad}${endColour} con la${endColour}${blackColour}/s${endColour} ${grayColour}skill${endColour}${blackColour}/s${endColour} ${blueColour}${skills}${endColour} ${grayColour}son:${endColour} \n\n${skillsdificultadChecker}\n"
    elif [ "$dificultad" == "Insane" ]; then
      echo -e "\n${greenColour}[+]${endColour} ${grayColour}Las máquinas${endColour} ${blackColour}${dificultad}${endColour} con la${endColour}${blackColour}/s${endColour} ${grayColour}skill${endColour}${blackColour}/s${endColour} ${blueColour}${skills}${endColour} ${grayColour}son:${endColour} \n\n${skillsdificultadChecker}\n"
    else
      variableFantasma=1
    fi
  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}No hay máquinas que cumplan con los requisitos${endColour}\n"
    tput civis && sleep 1; tput cnorm && algoMas
  fi
}

function searchCert(){
  certChecker=$(cat bundle.js | grep "like: " -B 7 | grep "$like" -B 7 | grep "name: " | tr -d '"' | tr -d ',' | awk 'NF{print$NF}' | column)

  if [ "${certChecker}" ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Las máquinas de estilo${endColour} ${blueColour}${like}${endColour} ${grayColour}son:${endColour} \n${certChecker}"
  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}No se han encontrado máquinas del estilo${endColour} ${blueColour}${like}${endColour}"
    tput civis && sleep 1; tput cnorm && algoMas
  fi
}

function searchLikeDificultad(){
  likedificultadChecker=$(cat bundle.js | grep "like: " -B 7 | grep "$like" -B 7 | grep "dificultad: \"$dificultad\"" -B 7 | grep "name: " | tr -d '"' | tr -d ',' | awk 'NF{print$NF}' | column)

  if [ "${likedificultadChecker}" ]; then
    
    if [ "$dificultad" == "Fácil" ]; then
      echo -e "${greenColour}[+]${endColour} ${grayColour}Las máquinas del estilo${endColour} ${blueColour}${like}${endColour} ${grayColour}y de dificultad${endColour} ${greenColour}${dificultad}${endColour} ${grayColour}son:${endColour} \n${likedificultadChecker}"
    elif [ "$dificultad" == "Media" ]; then
      echo -e "${greenColour}[+]${endColour} ${grayColour}Las máquinas del estilo${endColour} ${blueColour}${like}${endColour} ${grayColour}y de dificultad${endColour} ${yellowColour}${dificultad}${endColour} ${grayColour}son:${endColour} \n${likedificultadChecker}"
    elif [ "$dificultad" == "Difícil" ]; then
      echo -e "${greenColour}[+]${endColour} ${grayColour}Las máquinas del estilo${endColour} ${blueColour}${like}${endColour} ${grayColour}y de dificultad${endColour} ${redColour}${dificultad}${endColour} ${grayColour}son:${endColour} \n${likedificultadChecker}"
    elif [ "$dificultad" == "Insane" ]; then
      echo -e "${greenColour}[+]${endColour} ${grayColour}Las máquinas del estilo${endColour} ${blueColour}${like}${endColour} ${grayColour}y de dificultad${endColour} ${blackColour}${dificultad}${endColour} ${grayColour}son:${endColour} \n${likedificultadChecker}"
    else
      variableFantasma=1
    fi
  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}No hay máquinas que cumplan con los requisitos${endColour}\n"
    tput civis && sleep 1; tput cnorm && algoMas
  fi

}

function searchLikeSystem(){
  likesystemChecker=$(cat bundle.js | grep "like: " -B 7 | grep "$like" -B 7 | grep "so: \"$system\"" -B 7 | grep "name: " | tr -d '"' | tr -d ',' | awk 'NF{print$NF}' | column)
  
  if [ "${likesystemChecker}" ]; then
    echo -e "\n ${greenColour}[+]${endColour} ${grayColour}Las máquinas del estilo${endColour} ${blueColour}${like}${endColour} ${grayColour}y sistema${endColour} ${blueColour}${system}${endColour} ${grayColour}son:${endColour} \n\n${likesystemChecker}\n"
  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}No hay máquinas que cumplan con los requisitos${endColour}\n"
    tput civis && sleep 1; tput cnorm && algoMas
  fi
}

# Global Variables
machines_url="https://htbmachines.github.io/bundle.js"
respuesta_no_valida="\n${redColour}[!]${endColour} ${grayColour}Esa respuesta no es válida${endColour}\n"

# Indicadores
declare -i parameter_m_counter=0

# Chivatos
declare -i chivatoSystem=0
declare -i chivatoDificultad=0
declare -i chivatoSkills=0
declare -i chivatoLike=0

# Principal
while getopts "m:i:d:o:s:l:uh" arg; do 
    case $arg in 
        m) machineName=$OPTARG; let parameter_m_counter+=1;; 
        h) let parameter_m_counter+=66;;
        u) let parameter_m_counter+=17;;
        i) searchxip=$OPTARG; let parameter_m_counter+=200;;
        d) dificultad=$OPTARG; chivatoDificultad=1; let parameter_m_counter+=325;;
        o) system=$OPTARG; chivatoSystem=1; let parameter_m_counter+=9000;;
        l) like="$OPTARG"; chivatoLike=1; let parameter_m_counter+=501;;
        s) skills="$OPTARG"; chivatoSkills=1; let parameter_m_counter+=412;;
    esac
done 

if [ $parameter_m_counter -eq 1 ]; then
    searchMachine
  elif [ $parameter_m_counter -eq 17 ]; then
    updateMachines
  elif [ $parameter_m_counter -eq 200 ]; then
    searchIP
  elif [ $parameter_m_counter -eq 325 ]; then
    searchDificultad
  elif [ $parameter_m_counter -eq 9000 ]; then
    searchOS
  elif [ $parameter_m_counter -eq 501 ]; then
    searchCert
  elif [ $parameter_m_counter -eq 412 ]; then
    searchSkills "$skills"
  elif [ $chivatoLike -eq 1 ] && [ $chivatoSystem -eq 1 ]; then
    searchLikeSystem "$like $system"
  elif [ $chivatoLike -eq 1 ] && [ $chivatoDificultad -eq 1 ]; then
    searchLikeDificultad "$like $dificultad"
  elif [ $chivatoSystem -eq 1 ] && [ $chivatoDificultad -eq 1 ]; then
    searchSystemDificultad
  elif [ $chivatoSkills -eq 1 ] && [ $chivatoSystem -eq 1 ]; then
    searchSkillsSystem
  elif [ $chivatoSkills -eq 1 ] && [ $chivatoDificultad -eq 1 ]; then
    searchSkillsDificultad 
  elif [ $parameter_m_counter -eq 66 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Panel de ayuda${endColour}\n"
    echo -e "\t${purpleColour}Uso${endColour}${grayColour}: SCRIPT [parámetros] {variable}${endColour}"
    echo -e "\n\t${purpleColour}-u${endColour}${grayColour}: Actualizar la base de datos [-u]${endColour}"
    echo -e "\t\t Busca por la base de datos de donde se obtiene todos los nombres de las máquinas y si no la encuentra la descarga de la página https://htbmachines.github.i"
    echo -e "\t\t Si la encuentra comprueba su integridad y en dado caso la actualiza"
    echo -e "\n\t${purpleColour}-m${endColour}${grayColour}: Busca por el nombre de una máquina [-m] {máquina}${endColour}"
    echo -e "\t\t Busca en la base de datos por el nombre de una máquina. Este parámetro no es combinable con ningún otro, pues este muestra la información íntegra de la máquina."
    echo -e "\n\t${purpleColour}-i${endColour}${grayColour}: Busca por la IP de una máquina [-i] {ip}${endColour}"
    echo -e "\t\t Busca en la base de datos por la IP de una máquina. Si la encuentra te da el nombre y te pregunta si quieres mostrar todos los parámetros. No es combinable con ningún otro parámetro."
    echo -e "\n\t${purpleColour}-d${endColour}${grayColour}: Busca por la dificultad de una máquina [-d] {dificultad} (Insane, Difícil, Media, Fácil)${endColour}"
    echo -e "\t\t Busca por la dificultad de una máquina, se muestra en colores el output para diferenciar rapidamente la dificultad escogida."
    echo -e "\n\t${purpleColour}-o${endColour}${grayColour}: Busca por el sistema operativo de una máquina [-o] {sistema} (Windows, Linux)${endColour}"
    echo -e "\t\t Busca por el sistema operativo de la máquina."
    echo -e "\n\t${purpleColour}-s${endColour}${grayColour}: Busca por las skills de una máquina [-s] {skill}${endColour}"
    echo -e "\t\t Busca por las habilidadades requeridas de una máquina, ES IMPORTANTE que el skill vaya entre comillas dobles \"\" (no funciona si no, filtraría solo por todo lo que haya antes del primer espacio). Puedes buscar por cualquier vulnerabilidad a explotar en una máquina."
    echo -e "\n\t${purpleColour}-l${endColour}${grayColour}: Busca por las certificaciones recomendadas de una máquina [-l] {certificación} (eJPT, OSCP, OSED...)${endColour}"
    echo -e "\t\t Busca por todas las certificaciones recomendadas para la máquina en concreto, ES IMPORTANTE que se escriban las certificaciones respetando el CaseSensitive de las mismas."
    echo -e "\n\t${purpleColour}-h${endColour}${grayColour}: Muestra este panel de ayuda [-h]${endColour}"
    echo -e "\n\t ${grayColour}Hay varios parámetros que se pueden combinar entre sí, estos son: [-d][-o][-s][-l] se pueden combinar para filtrar por máquinas que por ejemplo sean de Linux y tengan una dificultad Difícil.${endColour}"
    echo -e  "\t ${grayColour}Así mismo se pueden filtrar por máquinas que estén recomendadas para la certificación OSCP y que requieran de la skill \"WPAD\".${endColour}"
    echo -e "\n ${grayColour}Para cualquier duda contactar a ${blueColour}lukiiimohh#0633${endColour} ${grayColour}en Discord.${endColour}\n"
  else
    helpPanel
fi
