#! /bin/bash

ajustarDirectorio() {
# Rutina para elimar caracteres prohibidos
var=$( tr -dc '[a-z][A-Z][0-9]-_ /' <<< "$var" )
var=$( sed "s_\^__g" <<< "$var" )
var=$( sed "s_//*_/_g" <<< "$var" )
var=$( sed -e "s_[[:blank:]][[:blank:]]*_ _g" <<< "$var" )
var=$( sed -e "s_[[:blank:]]*/_/_g" <<< "$var" )
var=$( sed -e "s_/[[:blank:]]*_/_g" <<< "$var" )
var=$( sed -e "s_/[[:blank:]]*/_/_g" <<< "$var" )
}

chequearSetup() {
# Rutina que verifica que los componentes de instalacion estan todos presentes.
	setupOK=true
	if [ ! -d ":setup" ] && [ $setupOK ]; then setupOK=false; fi
	if [ ! -d ":setup/bin" ] && [ $setupOK ]; then setupOK=false; fi
	if [ ! -d ":setup/mae" ] && [ $setupOK ]; then setupOK=false; fi

	if [ ! -f ":setup/bin/AFRAINIC.bash" ] && [ $setupOK ]; then setupOK=false; fi
	if [ ! -f ":setup/bin/AFRARECI.bash" ] && [ $setupOK ]; then setupOK=false; fi
	if [ ! -f ":setup/bin/AFRAUMBR.bash" ] && [ $setupOK ]; then setupOK=false; fi
	if [ ! -f ":setup/bin/AFRALIST.pl" ] && [ $setupOK ]; then setupOK=false; fi
	if [ ! -f ":setup/bin/Arrancar.bash" ] && [ $setupOK ]; then setupOK=false; fi
	if [ ! -f ":setup/bin/Detener.bash" ] && [ $setupOK ]; then setupOK=false; fi
	if [ ! -f ":setup/bin/MoverA.bash" ] && [ $setupOK ]; then setupOK=false; fi
	if [ ! -f ":setup/bin/GraLog.bash" ] && [ $setupOK ]; then setupOK=false; fi

	if [ ! -f ":setup/mae/agentes.mae" ] && [ $setupOK ]; then setupOK=false; fi
	if [ ! -f ":setup/mae/CdA.mae" ] && [ $setupOK ]; then setupOK=false; fi
	if [ ! -f ":setup/mae/CdC.mae" ] && [ $setupOK ]; then setupOK=false; fi
	if [ ! -f ":setup/mae/CdP.mae" ] && [ $setupOK ]; then setupOK=false; fi
	if [ ! -f ":setup/mae/tllama.tab" ] && [ $setupOK ]; then setupOK=false; fi
	if [ ! -f ":setup/mae/umbral.tab" ] && [ $setupOK ]; then setupOK=false; fi
}

verificarCompletitud() {
# Rutina que verifica si la instalacion anterior es completa.
	BINDIR_inst=true
	MAEDIR_inst=true
	NOVEDIR_inst=true
	ACEPDIR_inst=true
	PROCDIR_inst=true
	REPODIR_inst=true
	LOGDIR_inst=true
	RECHDIR_inst=true

	AFRAINIC_inst=true
	AFRARECI_inst=true
	AFRAUMBR_inst=true
	AFRALIST_inst=true
	MoverA_inst=true
	GraLog_inst=true
	Arrancar_inst=true
	Detener_inst=true

	CdP_inst=true
	CdA_inst=true
	CdC_inst=true
	agentes_inst=true
	tllama_inst=true
	umbral_inst=true

	# Corregir campos GRUPO y CONFDIR
	GRUPO_registro=$( grep "^GRUPO.*$" "$CONFDIR/AFRAINST.conf" )
	if [ -z "$GRUPO_registro" ]
	then
		echo "GRUPO=$GRUPO=$USER=$( date +%d/%m/%Y_%T )" >> "$CONFDIR/AFRAINST.conf"
		echo "Variable GRUPO no esta en el archivo de configuracion. Se repara."
		echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-WAR-Variable GRUPO no esta en el archivo de configuracion. Se repara.\n" >> "$CONFDIR/AFRAINST.log"
	else
		grupo_valor=$( sed "s-\(^GRUPO=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" <<< $GRUPO_registro )
		if [ "$grupo_valor" != "$GRUPO" ]
		then
			registro_nuevo="GRUPO=$GRUPO=$USER=$( date +%d/%m/%Y_%T )"
			sed -i "s-$GRUPO_registro-$registro_nuevo-" "$CONFDIR/AFRAINST.conf"
			echo "Variable GRUPO en el archivo de configuracion esta mal. Se repara."
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-WAR-Variable GRUPO en el archivo de configuracion esta mal. Se repara.\n" >> "$CONFDIR/AFRAINST.log"
		fi
	fi

	CONFDIR_registro=$( grep "^CONFDIR.*$" "$CONFDIR/AFRAINST.conf" )
	if [ -z "$CONFDIR_registro" ]
	then
		echo "CONFDIR=$CONFDIR=$USER=$( date +%d/%m/%Y_%T )" >> "$CONFDIR/AFRAINST.conf"
		echo "Variable CONFDIR no esta en el archivo de configuracion. Se repara."
		echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-WAR-Variable CONFDIR no esta en el archivo de configuracion. Se repara.\n" >> "$CONFDIR/AFRAINST.log"
	else
		confdir_valor=$( sed "s-\(^CONFDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" <<< $CONFDIR_registro )
		if [ "$confdir_valor" != "$CONFDIR" ]
		then
			registro_nuevo="CONFDIR=$CONFDIR=$USER=$( date +%d/%m/%Y_%T )"
			sed -i "s-$CONFDIR_registro-$registro_nuevo-" "$CONFDIR/AFRAINST.conf"
			echo "Variable CONFDIR en el archivo de configuracion esta mal. Se repara."
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-WAR-Variable CONFDIR en el archivo de configuracion esta mal. Se repara.\n" >> "$CONFDIR/AFRAINST.log"
		fi
	fi

	# Obtener el resto de los directorios
	BINDIR=$( grep "^BINDIR.*$" "$CONFDIR/AFRAINST.conf" | sed "s-\(^BINDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	MAEDIR=$( grep "^MAEDIR.*$" "$CONFDIR/AFRAINST.conf" | sed "s-\(^MAEDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	NOVEDIR=$( grep "^NOVEDIR.*$" "$CONFDIR/AFRAINST.conf" | sed "s-\(^NOVEDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	ACEPDIR=$( grep "^ACEPDIR.*$" "$CONFDIR/AFRAINST.conf" | sed "s-\(^ACEPDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	PROCDIR=$( grep "^PROCDIR.*$" "$CONFDIR/AFRAINST.conf" | sed "s-\(^PROCDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	REPODIR=$( grep "^REPODIR.*$" "$CONFDIR/AFRAINST.conf" | sed "s-\(^REPODIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	LOGDIR=$( grep "^LOGDIR.*$" "$CONFDIR/AFRAINST.conf" | sed "s-\(^LOGDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	RECHDIR=$( grep "^RECHDIR.*$" "$CONFDIR/AFRAINST.conf" | sed "s-\(^RECHDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )

	# Listar directorios y su contenido cuando corresponde
	echo -e "Directorio de configuracion: \e[93m$CONFDIR"
	list=$( ls -1 "$CONFDIR" )
	ls -1 "$CONFDIR"; echo -e "\e[0m";
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de configuracion: $CONFDIR\n$list\n" >> "$CONFDIR/AFRAINST.log"

	if [ -n "$BINDIR" ]
	then
		if [ -d "$BINDIR" ]
		then
			echo -e "Directorio de ejecutables: \e[93m$BINDIR"	
			list=$( ls -1 "$BINDIR" )
			ls -1 "$BINDIR"; echo -e "\e[0m";
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de ejecutables: $BINDIR\n$list\n" >> "$CONFDIR/AFRAINST.log"
		else
			echo -e "Directorio de ejecutables: \e[91m$BINDIR\e[0m"
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de ejecutables: $BINDIR\nNo existe!\n" >> "$CONFDIR/AFRAINST.log"
			BINDIR_inst=false
		fi
	else
		echo -e "Directorio de ejecutables: \e[91mNO DEFINIDO\e[0m"
		echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-WAR-Directorio de ejecutables: NO DEFINIDO\n" >> "$CONFDIR/AFRAINST.log"
		BINDIR_inst=false
	fi

	if [ -n "$MAEDIR" ]
	then
		if [ -d "$MAEDIR" ]
		then
			echo -e "Directorio de maestros y tablas: \e[93m$MAEDIR"
			list=$( ls -1 "$MAEDIR" )
			ls -1 "$MAEDIR"; echo -e "\e[0m";
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de maestros y tablas: $MAEDIR\n$list\n" >> "$CONFDIR/AFRAINST.log"
		else
			echo -e "Directorio de maestros y tablas: \e[91m$MAEDIR\e[0m"
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-WAR-Directorio de maestros y tablas: $MAEDIR\nNo existe!\n" >> "$CONFDIR/AFRAINST.log"
			MAEDIR_inst=false
		fi
	else
		echo -e "Directorio de maestros y tablas: \e[91mNO DEFINIDO\e[0m"
		echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-WAR-Directorio de maestros y tablas: NO DEFINIDO\n" >> "$CONFDIR/AFRAINST.log"
		MAEDIR_inst=false
	fi

	if [ -n "$NOVEDIR" ]
	then
		if [ -d "$NOVEDIR" ]
		then
			echo -e "Directorio de recepcion de archivos de llamadas: \e[93m$NOVEDIR\e[0m"
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de recepcion de archivos de llamadas: $NOVEDIR\n" >> "$CONFDIR/AFRAINST.log"
		else
			echo -e "Directorio de recepcion de archivos de llamadas: \e[91m$NOVEDIR\e[0m"
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-WAR-Directorio de recepcion de archivos de llamadas: $NOVEDIR\nNo existe!\n" >> "$CONFDIR/AFRAINST.log"
			NOVEDIR_inst=false
		fi
	else
		echo -e "Directorio de recepcion de archivos de llamadas: \e[91mNO DEFINIDO\e[0m"
		echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-WAR-Directorio de recepcion de archivos de llamadas: NO DEFINIDO\n" >> "$CONFDIR/AFRAINST.log"
		NOVEDIR_inst=false
	fi

	if [ -n "$ACEPDIR" ]
	then
		if [ -d "$ACEPDIR" ]
		then
			echo -e "Directorio de archivos de llamadas aceptadas: \e[93m$ACEPDIR\e[0m"
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de archivos de llamadas aceptadas: $ACEPDIR\n" >> "$CONFDIR/AFRAINST.log"
		else
			echo -e "Directorio de archivos de llamadas aceptadas: \e[91m$ACEPDIR\e[0m"
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-WAR-Directorio de archivos de llamadas aceptadas: $ACEPDIR\nNo existe!\n" >> "$CONFDIR/AFRAINST.log"
			ACEPDIR_inst=false
		fi
	else
		echo -e "Directorio de archivos de llamadas aceptadas: \e[91mNO DEFINIDO\e[0m"
		echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-WAR-Directorio de archivos de llamadas aceptadas: NO DEFINIDO\n" >> "$CONFDIR/AFRAINST.log"
		ACEPDIR_inst=false
	fi
 
	if [ -n "$PROCDIR" ]
	then
		if [ -d "$PROCDIR" ]
		then
			echo -e "Directorio de archivos de llamadas sospechosas: \e[93m$PROCDIR\e[0m"
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de archivos de llamadas sospechosas: $PROCDIR\n" >> "$CONFDIR/AFRAINST.log"
			if [ ! -d "$PROCDIR/proc" ]; then mkdir "$PROCDIR/proc"; fi
		else
			echo -e "Directorio de archivos de llamadas sospechosas: \e[91m$PROCDIR\e[0m"
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-WAR-Directorio de archivos de llamadas sospechosas: $PROCDIR\nNo existe!\n" >> "$CONFDIR/AFRAINST.log"
			PROCDIR_inst=false
		fi
	else
		echo -e "Directorio de archivos de llamadas sospechosas: \e[91mNO DEFINIDO\e[0m"
		echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-WAR-Directorio de archivos de llamadas sospechosas: NO DEFINIDO\n" >> "$CONFDIR/AFRAINST.log"
		PROCDIR_inst=false
	fi

	if [ -n "$REPODIR" ]
	then
		if [ -d "$REPODIR" ]
		then
			echo -e "Directorio de reportes de llamadas: \e[93m$REPODIR\e[0m"
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de reportes de llamadas: $REPODIR\n" >> "$CONFDIR/AFRAINST.log"
		else
			echo -e "Directorio de reportes de llamadas: \e[91m$REPODIR\e[0m"
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-WAR-Directorio de reportes de llamadas: $REPODIR\nNo existe!\n" >> "$CONFDIR/AFRAINST.log"
			REPODIR_inst=false
		fi
	else
		echo -e "Directorio de reportes de llamadas: \e[91mNO DEFINIDO\e[0m"
		echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-WAR-Directorio de reportes de llamadas: NO DEFINIDO\n" >> "$CONFDIR/AFRAINST.log"
		REPODIR_inst=false
	fi

	if [ -n "$LOGDIR" ]
	then
		if [ -d "$LOGDIR" ]
		then
			echo -e "Directorio de archivos de log: \e[93m$LOGDIR"
			list=$( ls -1 "$LOGDIR" )
			ls -1 "$LOGDIR"; echo -e "\e[0m";
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de archivos de log: $LOGDIR\n$list\n" >> "$CONFDIR/AFRAINST.log"
		else
			echo -e "Directorio de archivos de log: \e[91m$LOGDIR\e[0m"
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-WAR-Directorio de archivos de log: $LOGDIR\nNo existe!\n" >> "$CONFDIR/AFRAINST.log"
			LOGDIR_inst=false
		fi
	else
		echo -e "Directorio de archivos de log: \e[91mNO DEFINIDO\e[0m"
		echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-WAR-Directorio de archivos de log: NO DEFINIDO\n" >> "$CONFDIR/AFRAINST.log"
		LOGDIR_inst=false
	fi

	if [ -n "$RECHDIR" ]
	then
		if [ -d "$RECHDIR" ]
		then
			echo -e "Directorio de archivos rechazados: \e[93m$RECHDIR\e[0m"
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de archivos rechazados: $RECHDIR\n" >> "$CONFDIR/AFRAINST.log"
			if [ ! -d "$RECHDIR/llamadas" ]; then mkdir "$RECHDIR/llamadas"; fi
		else
			echo -e "Directorio de archivos rechazados: \e[91m$RECHDIR\e[0m"
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-WAR-Directorio de archivos rechazados: $RECHDIR\nNo existe!\n" >> "$CONFDIR/AFRAINST.log"
			RECHDIR_inst=false
		fi
	else
		echo -e "Directorio de archivos rechazados: \e[91mNO DEFINIDO\e[0m"
		echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-WAR-Directorio de archivos rechazados: NO DEFINIDO\n" >> "$CONFDIR/AFRAINST.log"
		RECHDIR_inst=false
	fi

	# Resumen de directorios
	if $BINDIR_inst && $MAEDIR_inst && $NOVEDIR_inst && $ACEPDIR_inst && $PROCDIR_inst && $REPODIR_inst && $LOGDIR_inst && $RECHDIR_inst
	then
		echo "Todos los directorios existen."
		echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Todos los directorios existen.\n" >> "$CONFDIR/AFRAINST.log"
	else
		echo -e "Directorios faltantes: marcados con color \e[91mrojo\e[0m"
		echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-WAR-No todos los directorios existen. Ver entradas anteriores de log.\n" >> "$CONFDIR/AFRAINST.log"
	fi

	# Listar scripts y maestros faltantes, si hay
	echo "Componentes faltantes:"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-WAR-Componentes faltantes:" >> "$CONFDIR/AFRAINST.log"

	if ! [ -f "$BINDIR/AFRAINIC.bash" ]; then echo -e "\e[91mAFRAINIC\e[0m"; echo "AFRAINIC" >> "$CONFDIR/AFRAINST.log"; AFRAINIC_inst=false; fi
	if ! [ -f "$BINDIR/AFRARECI.bash" ]; then echo -e "\e[91mAFRARECI\e[0m"; echo "AFRARECI" >> "$CONFDIR/AFRAINST.log"; AFRARECI_inst=false; fi
	if ! [ -f "$BINDIR/AFRAUMBR.bash" ]; then echo -e "\e[91mAFRAUMBR\e[0m"; echo "AFRAUMBR" >> "$CONFDIR/AFRAINST.log"; AFRAUMBR_inst=false; fi
	if ! [ -f "$BINDIR/AFRALIST.pl" ]; then echo -e "\e[91mAFRALIST\e[0m";echo "AFRALIST" >> "$CONFDIR/AFRAINST.log";  AFRALIST_inst=false; fi
	if ! [ -f "$BINDIR/MoverA.bash" ]; then echo -e "\e[91mMoverA\e[0m"; echo "MoverA" >> "$CONFDIR/AFRAINST.log"; MoverA_inst=false; fi
	if ! [ -f "$BINDIR/GraLog.bash" ]; then echo -e "\e[91mGraLog\e[0m"; echo "GraLog" >> "$CONFDIR/AFRAINST.log"; GraLog_inst=false; fi
	if ! [ -f "$BINDIR/Arrancar.bash" ]; then echo -e "\e[91mArrancar\e[0m"; echo "Arrancar" >> "$CONFDIR/AFRAINST.log"; Arrancar_inst=false; fi
	if ! [ -f "$BINDIR/Detener.bash" ]; then echo -e "\e[91mDetener\e[0m"; echo "Detener" >> "$CONFDIR/AFRAINST.log"; Detener_inst=false; fi

	if ! [ -f "$MAEDIR/CdP.mae" ]; then echo -e "\e[91mCdP.mae\e[0m"; echo "CdP.mae" >> "$CONFDIR/AFRAINST.log"; CdP_inst=false; fi
	if ! [ -f "$MAEDIR/CdA.mae" ]; then echo -e "\e[91mCdA.mae\e[0m"; echo "CdA.mae" >> "$CONFDIR/AFRAINST.log"; CdA_inst=false; fi
	if ! [ -f "$MAEDIR/CdC.mae" ]; then echo -e "\e[91mCdC.mae\e[0m"; echo "CdC.mae" >> "$CONFDIR/AFRAINST.log"; CdC_inst=false; fi
	if ! [ -f "$MAEDIR/agentes.mae" ]; then echo -e "\e[91magentes.mae\e[0m"; echo "agentes.mae" >> "$CONFDIR/AFRAINST.log"; agentes_inst=false; fi
	if ! [ -f "$MAEDIR/tllama.tab" ]; then echo -e "\e[91mtllama.tab\e[0m"; echo "tllama.tab" >> "$CONFDIR/AFRAINST.log"; tllama_inst=false; fi
	if ! [ -f "$MAEDIR/umbral.tab" ]; then echo -e "\e[91mumbral.tab\e[0m"; echo "umbral.tab" >> "$CONFDIR/AFRAINST.log"; umbral_inst=false; fi

	if $AFRAINIC_inst && $AFRARECI_inst && $AFRAUMBR_inst && $AFRALIST_inst && $MoverA_inst && $GraLog_inst && $Arrancar_inst && $Detener_inst && $CdP_inst && $CdA_inst && $CdC_inst && $agentes_inst && $tllama_inst && $umbral_inst
	then	echo "No hay."; echo "No hay." >> "$CONFDIR/AFRAINST.log";
	fi

	echo
	echo >> "$CONFDIR/AFRAINST.log"

	# Resumir completitud de instalacion
	if $BINDIR_inst && $MAEDIR_inst && $NOVEDIR_inst && $ACEPDIR_inst && $PROCDIR_inst && $REPODIR_inst && $LOGDIR_inst && $RECHDIR_inst && $AFRAINIC_inst && $AFRARECI_inst && $AFRAUMBR_inst && $AFRALIST_inst && $MoverA_inst && $GraLog_inst && $Arrancar_inst && $Detener_inst && $CdP_inst && $CdA_inst && $CdC_inst && $agentes_inst && $tllama_inst && $umbral_inst
	then	instalacion_completa=true
	else	instalacion_completa=false
	fi
}

completarInstalacion() {
# Rutina que completa la instalacion
	if $instalacion_completa
	then
		echo -e "Estado de la instalacion: \e[92mCOMPLETA\e[0m"
		echo "Proceso de instalacion finalizado."
		echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Estado de la instalacion: COMPLETA\n" >> "$CONFDIR/AFRAINST.log"
		echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Proceso de instalacion finalizado.\n" >> "$CONFDIR/AFRAINST.log"
	else
		echo -e "Estado de la instalacion: \e[91mINCOMPLETA\e[0m"
		echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-WAR-Estado de la instalacion: INCOMPLETA\n" >> "$CONFDIR/AFRAINST.log"
		echo -e "Desea completar instalacion? (ingresa 1 o 2)"
		echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Desea completar instalacion?\n" >> "$CONFDIR/AFRAINST.log"
		select completar in "Si" "No"
		do
			case $completar in
			"Si")	completar=true; break;;
			"No")	completar=false; break;;
			esac
		done

		if $completar
		then

			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Se decidio completar la instalacion.\n" >> "$CONFDIR/AFRAINST.log"
			clear

			echo -e "Directorio de configuracion: \e[93m$CONFDIR"
			list=$( ls -1 "$CONFDIR" )
			ls -1 "$CONFDIR"; echo -e "\e[0m";
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de configuracion: $CONFDIR\n$list\n" >> "$CONFDIR/AFRAINST.log"

			if ! $BINDIR_inst
			then
				if [ -n "$BINDIR" ]
				then
					mkdir -p "$BINDIR"
				else
					BINDIR="$GRUPO/bin"
					mkdir -p "$BINDIR" 2>/dev/null
					echo "BINDIR=$BINDIR=$USER=$( date +%d/%m/%Y_%T )" >> "$CONFDIR/AFRAINST.conf"
				fi
			fi

			if ! $AFRAINIC_inst; then cp ":setup/bin/AFRAINIC.bash" "$BINDIR"; fi
			if ! $AFRARECI_inst; then cp ":setup/bin/AFRARECI.bash" "$BINDIR"; fi
			if ! $AFRAUMBR_inst; then cp ":setup/bin/AFRAUMBR.bash" "$BINDIR"; fi
			if ! $AFRALIST_inst; then cp ":setup/bin/AFRALIST.pl" "$BINDIR"; fi
			if ! $MoverA_inst; then cp ":setup/bin/MoverA.bash" "$BINDIR"; fi
			if ! $GraLog_inst; then cp ":setup/bin/GraLog.bash" "$BINDIR"; fi
			if ! $Arrancar_inst; then cp ":setup/bin/Arrancar.bash" "$BINDIR"; fi
			if ! $Detener_inst; then cp ":setup/bin/Detener.bash" "$BINDIR"; fi

			echo -e "Directorio de ejecutables: \e[93m$BINDIR"
			list=$( ls -1 "$BINDIR" )
			ls -1 "$BINDIR"; echo -e "\e[0m";
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de ejecutables: $BINDIR\n$list\n" >> "$CONFDIR/AFRAINST.log"

			if ! $MAEDIR_inst
			then
				if [ -n "$MAEDIR" ]
				then
					mkdir -p "$MAEDIR"
				else
					MAEDIR="$GRUPO/mae"
					mkdir -p "$MAEDIR" 2>/dev/null
					echo "MAEDIR=$MAEDIR=$USER=$( date +%d/%m/%Y_%T )" >> "$CONFDIR/AFRAINST.conf"
				fi
			fi

			if ! $CdP_inst; then cp ":setup/mae/CdP.mae" "$MAEDIR"; fi
			if ! $CdA_inst; then cp ":setup/mae/CdA.mae" "$MAEDIR"; fi
			if ! $CdC_inst; then cp ":setup/mae/CdC.mae" "$MAEDIR"; fi
			if ! $agentes_inst; then cp ":setup/mae/agentes.mae" "$MAEDIR"; fi
			if ! $tllama_inst; then cp ":setup/mae/tllama.tab" "$MAEDIR"; fi
			if ! $umbral_inst; then cp ":setup/mae/umbral.tab" "$MAEDIR"; fi

			echo -e "Directorio de maestros y tablas: \e[93m$MAEDIR"
			list=$( ls -1 "$MAEDIR" )
			ls -1 "$MAEDIR"; echo -e "\e[0m";
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de maestros y tablas: $MAEDIR\n$list\n" >> "$CONFDIR/AFRAINST.log"

			if ! $NOVEDIR_inst
			then
				if [ -n "$NOVEDIR" ]
				then
					mkdir -p "$NOVEDIR"
				else
					NOVEDIR="$GRUPO/novedades"
					mkdir -p "$NOVEDIR" 2>/dev/null
					echo "NOVEDIR=$NOVEDIR=$USER=$( date +%d/%m/%Y_%T )" >> "$CONFDIR/AFRAINST.conf"
				fi
			fi

			echo -e "Directorio de recepcion de archivos de llamadas: \e[93m$NOVEDIR\e[0m"
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de recepcion de archivos de llamadas: $NOVEDIR\n" >> "$CONFDIR/AFRAINST.log"

			if ! $ACEPDIR_inst
			then
				if [ -n "$ACEPDIR" ]
				then
					mkdir -p "$ACEPDIR"
				else
					ACEPDIR="$GRUPO/aceptadas"
					mkdir -p "$ACEPDIR" 2>/dev/null
					echo "ACEPDIR=$ACEPDIR=$USER=$( date +%d/%m/%Y_%T )" >> "$CONFDIR/AFRAINST.conf"
				fi
			fi

			echo -e "Directorio de archivos de llamadas aceptadas: \e[93m$ACEPDIR\e[0m"
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de archivos de llamadas aceptadas: $ACEPDIR\n" >> "$CONFDIR/AFRAINST.log"

			if ! $PROCDIR_inst
			then
				if [ -n "$PROCDIR" ]
				then
					mkdir -p "$PROCDIR"
					mkdir "$PROCDIR/proc"
				else
					PROCDIR="$GRUPO/sospechosas"
					mkdir -p "$PROCDIR" 2>/dev/null
					echo "PROCDIR=$PROCDIR=$USER=$( date +%d/%m/%Y_%T )" >> "$CONFDIR/AFRAINST.conf"
				fi
			fi

			echo -e "Directorio de archivos de llamadas sospechosas: \e[93m$PROCDIR\e[0m"
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de archivos de llamadas sospechosas: $PROCDIR\n" >> "$CONFDIR/AFRAINST.log"

			if ! $REPODIR_inst
			then
				if [ -n "$REPODIR" ]
				then
					mkdir -p "$REPODIR"
				else
					REPODIR="$GRUPO/reportes"
					mkdir -p "$REPODIR" 2>/dev/null
					echo "REPODIR=$REPODIR=$USER=$( date +%d/%m/%Y_%T )" >> "$CONFDIR/AFRAINST.conf"
				fi
			fi

			echo -e "Directorio de reportes de llamadas: \e[93m$REPODIR\e[0m"
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de reportes de llamadas: $REPODIR\n" >> "$CONFDIR/AFRAINST.log"

			if ! $LOGDIR_inst
			then
				if [ -n "$LOGDIR" ]
				then
					mkdir -p "$LOGDIR"
				else
					LOGDIR="$GRUPO/log"
					mkdir -p "$LOGDIR" 2>/dev/null
					echo "LOGDIR=$LOGDIR=$USER=$( date +%d/%m/%Y_%T )" >> "$CONFDIR/AFRAINST.conf"
				fi
			fi

			echo -e "Directorio de archivos de log: \e[93m$LOGDIR"
			list=$( ls -1 "$LOGDIR" )
			ls -1 "$LOGDIR"; echo -e "\e[0m";
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de archivos de log: $LOGDIR\n$list\n" >> "$CONFDIR/AFRAINST.log"

			if ! $RECHDIR_inst
			then
				if [ -n "$RECHDIR" ]
				then
					mkdir -p "$RECHDIR"
					mkdir "$RECHDIR/llamadas"
				else
					RECHDIR="$GRUPO/rechazadas"
					mkdir -p "$RECHDIR" 2>/dev/null
					echo "RECHDIR=$RECHDIR=$USER=$( date +%d/%m/%Y_%T )" >> "$CONFDIR/AFRAINST.conf"
				fi
			fi

			echo -e "Directorio de archivos rechazados: \e[93m$RECHDIR\e[0m"
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de archivos rechazados: $RECHDIR\n" >> "$CONFDIR/AFRAINST.log"

			echo -e "Estado de la instalacion: \e[92mCOMPLETA\e[0m"
			echo "Proceso de instalacion finalizado."
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Estado de la instalacion: COMPLETA\n" >> "$CONFDIR/AFRAINST.log"
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Proceso de instalacion finalizado.\n" >> "$CONFDIR/AFRAINST.log"

		else
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Se decidio NO completar la instalacion.\n" >> "$CONFDIR/AFRAINST.log"
		fi
	fi
}

verificarPerl() {
# Rutina que detecta version de Perl instalada
	versionData=$( perl -v 2>/dev/null )
	if [ $? -eq 0 ]
	then
		versionCompleta=$( sed "s-\(^.*\)\(v[0-9]\.[0-9]*\.[0-9]*\)\(.*$\)-\2-" <<< $versionData )
		versionPrincipal=$( sed "s-\(^v\)\([0-9]\)\(\.[0-9]*\.[0-9]*$\)-\2-" <<< $versionCompleta )
		if [ $versionPrincipal -ge 5 ]
		then
			perl5_installed=true
		else
			perl5_installed=false
		fi	 
	else
		perl5_installed=false
	fi
}

setearInstalacion() {
# Rutina que obtiene datos ingresados por usuario
	memo=$( sed "s-\(^$GRUPO\)\(.*$\)-\2-" <<< "$BINDIR" )
	echo "Defina el directorio de ejecutables ($memo):"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Defina el directorio de ejecutables ($memo):\n" >> "$CONFDIR/AFRAINST.log"
	echo -e "\e[2mSe tomaran solo caracteres alfanumericos, _, -, /, espacio.\e[0m"	
	read var
	ajustarDirectorio
	simbolo1=$( sed "s-\(^.\)\(.*$\)-\1-" <<< $var )
	if [ "$simbolo1" == "/" ]
	then	BINDIR="$GRUPO$var"
	else	BINDIR="$GRUPO/$var"
	fi
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-$BINDIR\n" >> "$CONFDIR/AFRAINST.log"

	memo=$( sed "s-\(^$GRUPO\)\(.*$\)-\2-" <<< "$MAEDIR" )
	echo "Defina el directorio de maestros y tablas ($memo):"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Defina el directorio de maestros y tablas ($memo):\n" >> "$CONFDIR/AFRAINST.log"
	echo -e "\e[2mSe tomaran solo caracteres alfanumericos, _, -, /, espacio.\e[0m"
	read var
	ajustarDirectorio
	simbolo1=$( sed "s-\(^.\)\(.*$\)-\1-" <<< $var )
	if [ "$simbolo1" == "/" ]
	then	MAEDIR="$GRUPO$var"
	else	MAEDIR="$GRUPO/$var"
	fi
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-$MAEDIR\n" >> "$CONFDIR/AFRAINST.log"

	memo=$( sed "s-\(^$GRUPO\)\(.*$\)-\2-" <<< "$NOVEDIR" )
	echo "Defina el directorio de recepcion de archivos de llamadas ($memo):"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Defina el directorio de recepcion de archivos de llamadas ($memo):\n" >> "$CONFDIR/AFRAINST.log"
	echo -e "\e[2mSe tomaran solo caracteres alfanumericos, _, -, /, espacio.\e[0m"
	read var
	ajustarDirectorio
	simbolo1=$( sed "s-\(^.\)\(.*$\)-\1-" <<< $var )
	if [ "$simbolo1" == "/" ]
	then	NOVEDIR="$GRUPO$var"
	else	NOVEDIR="$GRUPO/$var"
	fi
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-$NOVEDIR\n" >> "$CONFDIR/AFRAINST.log"

	espacio_limite_kb=$( df -h -k . | tail -1 | awk '{print $4}' )
	espacio_limite_kb_len=$( expr length "$espacio_limite_kb" )
	espacio_limite_mb=$(( $espacio_limite_kb/1024 ))
	espacio_limite_mb_len=$( expr length "$espacio_limite_mb" )
	echo "Defina el espacio minimo libre para la recepcion de archivos de llamadas en MB ($DATASIZE), hasta $espacio_limite_mb:"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Defina el espacio minimo libre para la recepcion de archivos de llamadas en MB ($DATASIZE), hasta $espacio_limite_mb:\n" >> "$CONFDIR/AFRAINST.log"
	var=$(( $espacio_limite_mb+1 ))
	while [ $var -gt $espacio_limite_mb ] || [ "$var" -le 0 ]; do
		echo -e "\e[2mHay que ingresar numero positivo decimal <= $espacio_limite_mb\e[0m"
		read var
		if ! [[ $var == +([0-9]) ]]
		then	var=0
		fi
		varlen=$( expr length "$var" )
		if [ "$varlen" -gt "$espacio_limite_mb_len" ]
		then	var=0
		fi
	done
	DATASIZE=$var
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-$DATASIZE\n" >> "$CONFDIR/AFRAINST.log"

	memo=$( sed "s-\(^$GRUPO\)\(.*$\)-\2-" <<< "$ACEPDIR" )
	echo "Defina el directorio de archivos de llamadas aceptadas ($memo):"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Defina el directorio de archivos de llamadas aceptadas ($memo):\n" >> "$CONFDIR/AFRAINST.log"
	echo -e "\e[2mSe tomaran solo caracteres alfanumericos, _, -, /, espacio.\e[0m"
	read var
	ajustarDirectorio
	simbolo1=$( sed "s-\(^.\)\(.*$\)-\1-" <<< $var )
	if [ "$simbolo1" == "/" ]
	then	ACEPDIR="$GRUPO$var"
	else	ACEPDIR="$GRUPO/$var"
	fi
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-$ACEPDIR\n" >> "$CONFDIR/AFRAINST.log"

	memo=$( sed "s-\(^$GRUPO\)\(.*$\)-\2-" <<< "$PROCDIR" )
	echo "Defina el directorio de archivos de llamadas sospechosas ($memo):"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Defina el directorio de archivos de llamadas sospechosas ($memo):\n" >> "$CONFDIR/AFRAINST.log"
	echo -e "\e[2mSe tomaran solo caracteres alfanumericos, _, -, /, espacio.\e[0m"
	read var
	ajustarDirectorio
	simbolo1=$( sed "s-\(^.\)\(.*$\)-\1-" <<< $var )
	if [ "$simbolo1" == "/" ]
	then	PROCDIR="$GRUPO$var"
	else	PROCDIR="$GRUPO/$var"
	fi
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-$PROCDIR\n" >> "$CONFDIR/AFRAINST.log"

	memo=$( sed "s-\(^$GRUPO\)\(.*$\)-\2-" <<< "$REPODIR" )
	echo "Defina el directorio de reportes de llamadas ($memo):"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Defina el directorio de reportes de llamadas ($memo):\n" >> "$CONFDIR/AFRAINST.log"
	echo -e "\e[2mSe tomaran solo caracteres alfanumericos, _, -, /, espacio.\e[0m"
	read var
	ajustarDirectorio
	simbolo1=$( sed "s-\(^.\)\(.*$\)-\1-" <<< $var )
	if [ "$simbolo1" == "/" ]
	then	REPODIR="$GRUPO$var"
	else	REPODIR="$GRUPO/$var"
	fi
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-$REPODIR\n" >> "$CONFDIR/AFRAINST.log"

	memo=$( sed "s-\(^$GRUPO\)\(.*$\)-\2-" <<< "$LOGDIR" )
	echo "Defina el directorio de archivos de log ($memo):"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Defina el directorio de archivos de log ($memo):\n" >> "$CONFDIR/AFRAINST.log"
	echo -e "\e[2mSe tomaran solo caracteres alfanumericos, _, -, /, espacio.\e[0m"
	read var
	ajustarDirectorio
	simbolo1=$( sed "s-\(^.\)\(.*$\)-\1-" <<< $var )
	if [ "$simbolo1" == "/" ]
	then	LOGDIR="$GRUPO$var"
	else	LOGDIR="$GRUPO/$var"
	fi
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-$LOGDIR\n" >> "$CONFDIR/AFRAINST.log"

	echo "Defina la extencion de archivos de log ($LOGEXT):"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Defina la extencion de archivos de log ($LOGEXT):\n" >> "$CONFDIR/AFRAINST.log"
	echo -e "\e[2mSe tomaran hasta 5 primeros caracteres\e[0m"
	read var
	if [ -z "$var" ]
	then	LOGEXT=""
	else
		var="${var//\/}"
		var="${var//\ }"
		varlen=$( expr length "$var" )
		if [ $varlen -le 5 ]
		then	LOGEXT="$var"
		else	LOGEXT=$( sed "s-\(^.....\)\(.*\)-\1-" <<< "$var" )
		fi
	fi
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-$LOGEXT\n" >> "$CONFDIR/AFRAINST.log"

	echo "Defina el tamanio maximo para cada archivo de log en KB ($LOGSIZE), hasta $espacio_limite_kb:"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Defina el tamanio maximo para cada archivo de log en KB ($LOGSIZE), hasta $espacio_limite_kb:\n" >> "$CONFDIR/AFRAINST.log"
	var=0
	while [ $var -gt $espacio_limite_kb ] || [ $var -le 0 ]; do
		echo -e "\e[2mHay que ingresar numero positivo decimal <= $espacio_limite_kb\e[0m"
		read var
		if ! [[ $var == +([0-9]) ]]
		then	var=0
		fi
		varlen=$( expr length "$var" )
		if [ "$varlen" -gt "$espacio_limite_kb_len" ]
		then	var=0
		fi
	done
	LOGSIZE=$var
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-$LOGSIZE\n" >> "$CONFDIR/AFRAINST.log"

	memo=$( sed "s-\(^$GRUPO\)\(.*$\)-\2-" <<< "$RECHDIR" )
	echo "Defina el directorio de archivos rechazados ($memo):"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Defina el directorio de archivos rechazados ($memo):\n" >> "$CONFDIR/AFRAINST.log"
	echo -e "\e[2mSe tomaran solo caracteres alfanumericos, _, -, /, espacio.\e[0m"
	read var
	ajustarDirectorio
	simbolo1=$( sed "s-\(^.\)\(.*$\)-\1-" <<< $var )
	if [ "$simbolo1" == "/" ]
	then	RECHDIR="$GRUPO$var"
	else	RECHDIR="$GRUPO/$var"
	fi
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-$RECHDIR\n" >> "$CONFDIR/AFRAINST.log"

	clear
	echo -e "Directorio de ejecutables: \e[93m$BINDIR\e[0m"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de ejecutables: $BINDIR\n" >> "$CONFDIR/AFRAINST.log"
	echo -e "Directorio de maestros y tablas: \e[93m$MAEDIR\e[0m"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de maestros y tablas: $MAEDIR\n" >> "$CONFDIR/AFRAINST.log"
	echo -e "Directorio de recepcion de archivos de llamadas: \e[93m$NOVEDIR\e[0m"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de archivos de llamadas: $NOVEDIR\n" >> "$CONFDIR/AFRAINST.log"
	echo -e "Espacio minimo libre para la recepcion de archivos de llamadas: \e[93m$DATASIZE MB\e[0m"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Espacio minimo libre para la recepcion de archivos de llamadas: $DATASIZE MB\n" >> "$CONFDIR/AFRAINST.log"
	echo -e "Directorio de archivos de llamadas aceptadas: \e[93m$ACEPDIR\e[0m"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de archivos de llamadas aceptadas: $ACEPDIR\n" >> "$CONFDIR/AFRAINST.log"
	echo -e "Directorio de archivos de llamadas sospechosas: \e[93m$PROCDIR\e[0m"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de archivos de llamadas sospechosas: $PROCDIR\n" >> "$CONFDIR/AFRAINST.log"
	echo -e "Directorio de reportes de llamadas: \e[93m$REPODIR\e[0m"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de reportes de llamadas: $REPODIR\n" >> "$CONFDIR/AFRAINST.log"
	echo -e "Directorio de archivos de log: \e[93m$LOGDIR\e[0m"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de archivos de log: $LOGDIR\n" >> "$CONFDIR/AFRAINST.log"
	echo -e "Extencion de archivos de log: \e[93m$LOGEXT\e[0m"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Extencion de archivos de log: $LOGEXT\n" >> "$CONFDIR/AFRAINST.log"
	echo -e "Tamanio maximo para cada archivo de log: \e[93m$LOGSIZE KB\e[0m"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Tamanio maximo para cada archivo de log: $LOGSIZE\n" >> "$CONFDIR/AFRAINST.log"
	echo -e "Directorio de archivos rechazados: \e[93m$RECHDIR\e[0m"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Directorio de archivos rechazados: $RECHDIR\n" >> "$CONFDIR/AFRAINST.log"
	echo -e "Instalacion esta lista.\nDesea continuar? (ingresa 1 o 2)"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Instalacion esta lista.\nDesea continuar?\n" >> "$CONFDIR/AFRAINST.log"
}

instalar() {
	echo
	echo "Creando los directorios..."
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Creando los directorios...\n" >> "$CONFDIR/AFRAINST.log"
	mkdir -p "$BINDIR"
	mkdir -p "$MAEDIR" 2>/dev/null
	mkdir -p "$NOVEDIR" 2>/dev/null
	mkdir -p "$ACEPDIR" 2>/dev/null
	mkdir -p "$PROCDIR" 2>/dev/null
	mkdir -p "$PROCDIR/proc" 2>/dev/null
	mkdir -p "$REPODIR" 2>/dev/null
	mkdir -p "$LOGDIR" 2>/dev/null
	mkdir -p "$RECHDIR" 2>/dev/null
	mkdir -p "$RECHDIR/llamadas" 2>/dev/null

	echo "Instalando programas y funciones..."
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Instalando programas y funciones...\n" >> "$CONFDIR/AFRAINST.log"
	cp ":setup/bin/AFRAINIC.bash" "$BINDIR"
	cp ":setup/bin/AFRARECI.bash" "$BINDIR"
	cp ":setup/bin/AFRAUMBR.bash" "$BINDIR"
	cp ":setup/bin/AFRALIST.pl" "$BINDIR"
	cp ":setup/bin/MoverA.bash" "$BINDIR"
	cp ":setup/bin/GraLog.bash" "$BINDIR"
	cp ":setup/bin/Arrancar.bash" "$BINDIR"
	cp ":setup/bin/Detener.bash" "$BINDIR"

	echo "Instalando archivos maestros y tablas..."
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Instalando archivos maestros y tablas...\n" >> "$CONFDIR/AFRAINST.log"
	cp ":setup/mae/CdP.mae" "$MAEDIR"
	cp ":setup/mae/CdA.mae" "$MAEDIR"
	cp ":setup/mae/CdC.mae" "$MAEDIR"
	cp ":setup/mae/agentes.mae" "$MAEDIR"
	cp ":setup/mae/tllama.tab" "$MAEDIR"
	cp ":setup/mae/umbral.tab" "$MAEDIR"

	echo "Actualizando la configuracion del sistema..."
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Actualizando la configuracion del sistema...\n" >> "$CONFDIR/AFRAINST.log"
	echo "GRUPO=$GRUPO=$USER=$( date +%d/%m/%Y_%T )" > "$CONFDIR/AFRAINST.conf"
	echo "CONFDIR=$CONFDIR=$USER=$( date +%d/%m/%Y_%T )" >> "$CONFDIR/AFRAINST.conf"
	echo "BINDIR=$BINDIR=$USER=$( date +%d/%m/%Y_%T )" >> "$CONFDIR/AFRAINST.conf"
	echo "MAEDIR=$MAEDIR=$USER=$( date +%d/%m/%Y_%T )" >> "$CONFDIR/AFRAINST.conf"
	echo "NOVEDIR=$NOVEDIR=$USER=$( date +%d/%m/%Y_%T )" >> "$CONFDIR/AFRAINST.conf"
	echo "DATASIZE=$DATASIZE=$USER=$( date +%d/%m/%Y_%T )" >> "$CONFDIR/AFRAINST.conf"
	echo "ACEPDIR=$ACEPDIR=$USER=$( date +%d/%m/%Y_%T )" >> "$CONFDIR/AFRAINST.conf"
	echo "PROCDIR=$PROCDIR=$USER=$( date +%d/%m/%Y_%T )" >> "$CONFDIR/AFRAINST.conf"
	echo "REPODIR=$REPODIR=$USER=$( date +%d/%m/%Y_%T )" >> "$CONFDIR/AFRAINST.conf"
	echo "LOGDIR=$LOGDIR=$USER=$( date +%d/%m/%Y_%T )" >> "$CONFDIR/AFRAINST.conf"
	echo "LOGEXT=$LOGEXT=$USER=$( date +%d/%m/%Y_%T )" >> "$CONFDIR/AFRAINST.conf"
	echo "LOGSIZE=$LOGSIZE=$USER=$( date +%d/%m/%Y_%T )" >> "$CONFDIR/AFRAINST.conf"
	echo "RECHDIR=$RECHDIR=$USER=$( date +%d/%m/%Y_%T )" >> "$CONFDIR/AFRAINST.conf"

	echo "Instalacion CONCLUIDA."
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Instalacion CONCLUIDA.\n" >> "$CONFDIR/AFRAINST.log"
}



################
#     MAIN     #
################

GRUPO=$( echo $(pwd) )
CONFDIR=$( echo "$(pwd)/conf" )
clear

if ! [ -d "$CONFDIR" ]
then
	mkdir -p "$CONFDIR"
	echo "Carpeta conf no existe, se crea."
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-WAR-Carpeta conf no existe, se crea.\n" > "$CONFDIR/AFRAINST.log"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-NUEVA INSTALACION.\n" >> "$CONFDIR/AFRAINST.log"
else
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-NUEVA INSTALACION.\n" > "$CONFDIR/AFRAINST.log"
fi

chequearSetup
if ! $setupOK
then
	mensajePaquete="PAQUETE DE INSTALACION ESTA INCOMPLETO\nNo se puede seguir, obtiene paquete de instalacion de vuelta."
	echo -e "\e[91m$mensajePaquete\e[0m"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-ERR-\n$mensajePaquete\n" >> "$CONFDIR/AFRAINST.log"
	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Exit code: 1. Paquete incompleto.\n" >> "$CONFDIR/AFRAINST.log"
	exit 1
fi

if [ -f "$CONFDIR/AFRAINST.conf" ]
then
	verificarCompletitud
	completarInstalacion
else
	verificarPerl
	if [ $perl5_installed ]
	then
		echo -e "Perl version:\n$versionData"
		echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Perl version:\n$versionData\n" >> "$CONFDIR/AFRAINST.log"

		mensaje_aceptacion="*****************************************************************\n*\tProceso de instalacion de \"AFRA-I\"\t\t\t*\n*\tTema I Copyright © Grupo 11 - Segundo Cuatrimestre 2015\t*\n*****************************************************************\nA T E N C I O N: Al instalar Ud. expresa aceptar los terminos y condiciones del \"ACUERDO DE LICENCIA DE SOFTWARE\" incluido en este paquete.\nAcepta? (ingresa 1 o 2)"
		echo
		echo -e $mensaje_aceptacion
		echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-\n$mensaje_aceptacion\n" >> "$CONFDIR/AFRAINST.log"
		select aceptado in "Si" "No"
		do
			case $aceptado in
			"Si")	aceptado=true; break;;
			"No")	aceptado=false; break;;
			esac
		done

		if $aceptado
		then
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-ACEPTADO.\n" >> "$CONFDIR/AFRAINST.log"
			BINDIR="$GRUPO/bin"
			MAEDIR="$GRUPO/mae"
			NOVEDIR="$GRUPO/novedades"
			DATASIZE=100
			ACEPDIR="$GRUPO/aceptadas"
			PROCDIR="$GRUPO/sospechosas"
			REPODIR="$GRUPO/reportes"
			LOGDIR="$GRUPO/log"
			LOGEXT="log"
			LOGSIZE=400
			RECHDIR="$GRUPO/rechazadas"

			continuar=false
			while ! $continuar; do
				clear
				echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-NUEVO SETEO DE INSTALACION.\n" >> "$CONFDIR/AFRAINST.log"
				setearInstalacion
				select continuar in "Si" "No"
				do
					case $continuar in
					"Si")	continuar=true; break;;
					"No")	continuar=false; break;;
					esac
				done
			done
			
			echo "Confirma Ud. la instalacion? (ingresa 1 o 2)"
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Confirma Ud. la instalacion?\n" >> "$CONFDIR/AFRAINST.log"
			select confirmado in "Si" "No"
			do
				case $confirmado in
				"Si")	confirmado=true; break;;
				"No")	confirmado=false; break;;
				esac
			done

			if $confirmado
			then	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-CONFIRMADO\n" >> "$CONFDIR/AFRAINST.log"; instalar
			else	echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-NO CONFIRMADO\n" >> "$CONFDIR/AFRAINST.log"
			fi	
		
		else
			echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-NO ACEPTADO.\n" >> "$CONFDIR/AFRAINST.log"
		fi
	else
		mensaje_no_perl="Para ejecutar el sistema AFRA-I es necesario contar con Perl 5 o superior.\nEfectue su instalacion e intenten nuevamente.\nProceso de instalacion cancelado."
		echo -e $mensaje_no_perl
		echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-ERR-\n$mensaje_no_perl\n" >> "$CONFDIR/AFRAINST.log"
		echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Exit code: 2. Perl v5+ no esta instalado.\n" >> "$CONFDIR/AFRAINST.log"
		exit 2
	fi
fi

if [ -f "$BINDIR/AFRAINIC.bash" ]
then
chmod u+x "$BINDIR/AFRAINIC.bash"
fi

echo -e "$( date +%d/%m/%Y_%T )-$USER-AFRAINST-INFO-Exit code: 0. No hubo errores.\n" >> "$CONFDIR/AFRAINST.log"
exit 0
