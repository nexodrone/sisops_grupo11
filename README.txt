::::Booteo::::

1 Insertar el dispositivo externo en el puerto USB.

2 Iniciar la maquina, entrar en la interfaz de BIOS.

3 Setear arranque desde el dispositivo externo.

4 Guardar configuración y reiniciar la máquina.

5 En el menú seleccionar “Try Ubuntu” y esperar a que se inicie el sistema operativo.



::::Instalación::::

1 Extraer el contenido de “grupo11.tar.gz”, que se encuentra en el escritorio.

2 Acceder a la carpeta “grupo11” que se descomprimió.

3 Abrir una terminal (Ctrl+Atl+T) y posicionarse en ésta carpeta.
  Por ejemplo, si se descomprimió en el escritorio el comando sería:
	>cd /home/ubuntu/Desktop/grupo11

4 En caso de ser necesario, darle permiso de ejecución a AFRAINST.bash:
	>chmod u+x AFRAINST.bash

5 Invocar el instalador, sin parámetros:
	>./AFRAINST.bash

6 Seguir los pasos de instalación indicados.

7 Al confirmar y finalizar la instalación, se crearán los directorios indicados en el proceso de instalación y los archivos ejecutables junto con los archivos maestros y tablas en los directorios correspondientes:
	BINDIR
		AFRAINIC.bash
		AFRARECI.bash
		AFRALIST.pl
		Arrancar.bash
		Detener.bash
		AFRAUMBR.bash
	MAEDIR
		agentes.mae
		CdA.mae
		CdC.mae
		CdP.mae
		tllama.tab
		umbral.tab
	NOVEDIR
	ACEPDIR
	PROCDIR
	REPODIR
	LOGDIR
	RECHDIR



::::Iniciaclización::::

1 Posicionarse en consola dentro de la carpeta donde se instaló.

2 A partir del directorio de archivos binarios ( por ejemplo: binarios ) y el directorio de configuración que es /conf invocar al siguiente comando:
	>. ./binarios/AFRAINIC.bash “./conf/AFRAINST.conf”

3 En caso de no haber problema con la inicialización se brindará la posibilidad de iniciar el proceso AFRARECI, aparecerá un cartel preguntando esto y se debe ingresar:
	>1        si se quiere iniciarlo
	>2        si no.

4 Si no se inicia AFRARECI automáticamente, éste puede iniciarse en cualquier momento desde la línea de comandos escribiendo:
	>Arrancar.bash

5 Para detener el proceso desde la línea de comandos se debe escribir:
	>Detener.bash

6 En caso de tener problemas con la inicialización siga las instrucciones que le recomendará el programa luego de emitir el error.

