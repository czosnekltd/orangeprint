###===========================================================###
# Esquema de Comandos Instalación Orangeprint.					#
# Desc: Instalación Octoprint de cero, con entorno virtual.		#
# by Carlymx - 06-02-2018										#
# carlymx@gmail.com												#
###===========================================================###

'Inicio del sitema por primera vez'
	# Pregunta por la contraseña de root '1234' y luego pide que la cambies por una nueva 'orangeprint'.
	# Pide el nombre para un nuevo usuario que llamaremos 'orangeprint' y contraseña 'orangeprint'.
	# Indica que 'orangeprint' es super usuario y pide reiniciar.


'Configuración del Sistema'
	
	'Conexion WIFI'
		sudo nmtui
		 > Activate a Connection > Sellecionar red WIFI > Contraseña
			
		nmcli d		# Comprobar correcta conexión.
		watch -n 1 cat /proc/net/wireless	# Calidad de la señal WIFI
		
	'Zona Horaria'
		sudo armbian-config
		 > Personal > Time Zone
		
	'Nombre del Dominio'
	sudo armbian-config
	 > Personal > Hostname > "orangeprint"

	'Idioma'
		sudo armbian-config
		 > Personal > Locales > [es_ES.UTF-8 UTF-8] > [es_ES.UTF-8]
		
		# Añadir al final del archivo
		sudo nano /etc/environment
			# File generated by update-locale
			LC_ALL="es_ES.UTF-8"
			LC_MESSAGES="es_ES.UTF-8"
			LANGUAGE="es_ES"
			LANG="es_ES.UTF-8"

		# Sustituir contenido archivo por:
		sudo nano /etc/default/locale
			# File generated by update-locale
			LC_ALL="es_ES.UTF-8"
			LC_MESSAGES="es_ES.UTF-8"
			LANGUAGE="es_ES"
			LANG="es_ES.UTF-8"

		# Crear archivo en '/var/lib/locales/supported.d/local' y poner:
		sudo mkdir /var/lib/locales/
		sudo mkdir /var/lib/locales/supported.d/
		sudo nano /var/lib/locales/supported.d/local
			es_ES.UTF-8 UTF-8
			en_US.UTF-8 UTF-8

	'Configurar Teclado'
		"IMPORTANTE: Conectar un Teclado Físico o no funcionara"
		sudo dpkg-reconfigure keyboard-configuration
		 > PC GENERICO 105 TECLAS > ESPAÑOL > ESPAÑOL > ALT DERECHO (AltGr) > CONTROL DERECHO
	 

	#### Notas del Sistema:
	#
	#	Solución a problemas conexión SSH por WIFI en Windows:
	#	Desactivar el uso de IPv6 en la OPI
		sudo nano /boot/cmdline.txt
			ipv6.disable = 1
		sudo /etc/init.d/networking restart
	#
	#	Temperatura CPU
		cat /sys/devices/virtual/thermal/thermal_zone0/temp
		cat /etc/armbianmonitor/datasources/soctemp
		armbianmonitor -m
	#	
	####


'Configurar Usuario'
	
	'Agregar usuario `orangeprint´ a Administradores'
	sudo usermod -a -G tty orangeprint
	sudo usermod -a -G dialout orangeprint
	sudo adduser orangeprint sudo

	'Activar el reinicio para este usuario'
	su orangeprint
	systemctl reboot -i
	
	'Cambiar privilegios'
	sudo visudo
		# Especificar privilegios de usuario al final del archivo.
		orangeprint ALL=(ALL:ALL) ALL
		orangeprint ALL=NOPASSWD: /sbin/shutdown
		orangeprint ALL=(ALL) NOPASSWD:ALL
	
	# O Activar (si no lo esta).
		>> #includedir /etc/sudoers.d
	# y añadir privilegios en:
	sudo nano /etc/sudoers.d/orangeprint
		
	'Agregar Nuevo Usuario'
	# En caso que se quiera o se necesite tener un tercer usuario, vasta con agregarlo:
	sudo adduser usuario
	
'Dependencias'

	'Instalar Dependencias'
	sudo apt-get update
	sudo apt-get upgrade
	sudo apt-get install python-pip python-dev python-setuptools python-virtualenv virtualenv git libyaml-dev build-essential psmisc
	sudo pip install -U pip
	
	'Acceder como usuario orangeprint'
	su orangeprint
	cd					# accedes al directorio personal directamente

	'Dependencia PySerial'
	wget https://pypi.python.org/packages/source/p/pyserial/pyserial-2.7.tar.gz
	tar -zxf pyserial-2.7.tar.gz
	cd pyserial-2.7
	sudo python setup.py install
	
	
'Instalacion Octoprint (servidor de impresión)'

	'Descarga Octoprint'
	cd
	git clone https://github.com/foosel/OctoPrint.git
	cd OctoPrint
	virtualenv venv		# Crear entorno Virtual
	sudo ./venv/bin/python setup.py install
	mkdir ~/.octoprint

		'**EXTRA: Actualizar octoprint (solo cuando proceda)**'
		cd ~/OctoPrint/
		git pull
		sudo ./venv/bin/python setup.py clean
		sudo ./venv/bin/python setup.py install

	'Iniciar por primera vez el Octoprint'
	~/OctoPrint/venv/bin/octoprint serve
	# Una vez comprobado que funciona accediendo por el navegador web a la IP de la OPI ( ej: xx.xx.xx.xx:5000)
	# puede cerrarse el servidor octoprint para desbloquear el terminal pulsando 'CTrl+Z'
	
	'Inicio del Servidor Automaticamente'
	sudo cp ~/OctoPrint/scripts/octoprint.init /etc/init.d/octoprint
	sudo chmod +x /etc/init.d/octoprint
	sudo update-rc.d /etc/init.d/octoprint defaults
	
	sudo cp ~/OctoPrint/scripts/octoprint.default /etc/default/octoprint
		`Editar Ruta binario Octoprint`
			sudo nano /etc/default/octoprint
				# CUIDADO hay que activar (descomentar) y modificar las siguientes lineas
				# o si nos, no funcionara.
				OCTOPRINT_USER=orangeprint
				BASEDIR=/home/orangeprint/.octoprint
				CONFIGFILE=/home/orangeprint/.octoprint/config.yaml
				DAEMON=/home/orangeprint/OctoPrint/venv/bin/octoprint	
		
	reboot
	
	#### Notas sobre Octoprint:
	#
	# Comando control del servicio octoprint:
		sudo service octoprint start|stop|restart

	# Comando para saber el estado del servicio:
		systemctl status octoprint.service
		journalctl -xe
	
	# DEPENDENCIAS OCTOPRINT 1.3.6 
		FUTURES 3.1.1
		https://pypi.python.org/packages/cc/26/b61e3a4eb50653e8a7339d84eeaa46d1e93b92951978873c220ae64d0733/futures-3.1.1.tar.gz#md5=77f261ab86cc78efa2c5fe7be27c3ec8
		
		WRAPT 1.10.11
		https://pypi.python.org/simple/wrapt/
		https://pypi.python.org/packages/a0/47/66897906448185fcb77fc3c2b1bc20ed0ecca81a0f2f88eda3fc5a34fc3d/wrapt-1.10.11.tar.gz#md5=e1346f31782d50401f81c2345b037076
	
	#
	#####	
	

'Instalacion de Motion (servidor para WebCam)'

	'Previo'
	sudo apt-get update
	sudo apt-get upgrade
	lsusb					# Para saber si la WebCam esta conectada

	'Instalar Motion'
	sudo apt-get install motion
	
	'Configurar Motion'
	sudo nano /etc/motion/motion.conf
		
		`Daemon`
			daemon on # --------------------------- Permite la auto-ejecución en el arranque del sistema 
		
		`Capture device options`
			v4l2_palette 15 # --------------------- Tipo de paleta de color soportada por tu WebCam, usar 'v4l2-ctl --list-formats-ext'
			width 640 # --------------------------- Resolucion (Ancho) usar 'uvcdynctrl -f'
			height 360 # -------------------------- Resolucion (Alto) usar 'uvcdynctrl -f'
			framerate 15 # ------------------------ Fps de la captura del video
			
		`Image File Ouput`
			output_pictures = off # --------------- No Guardes imagenes
		
		`FFMPEG related options`
			ffmpeg_output_movies = off # ---------- No Guardes Videos

		`Live Stream Server`
			stream_motion on #--------------------- Cuando no detecta movimiento ir a 1 fps
			stream_maxrate 12 #-------------------- Cuando detecta movimiento ir max 12 fps
			stream_localhost off #----------------- No restringir el streaming a equipo local

		`HTTP Based Control`
			webcontrol_port 8080 # ---------------- Puerto de acceso
			webcontrol_localhost off # ------------ Para poder acceder desde cualquier 
			webcontrol_html_output on # ----------- Para poder controlar y configurar el Motion por Web
	
	
	'Configurar inicio del servicio'
	sudo nano /etc/default/motion

		# Para que el servicio pueda iniciarse debemos cambiar esta opción a 'yes'
		start_motion_daemon = yes
	
	sudo service motion start


	#### Notas sobre Motion:
	#
	# Control del Servicio Motion
		sudo service motion start|stop|restart
	
	# Motion guarda por defecto vídeos e imágenes en /var/bin/motion/motion
	# Para saber el tamaño que ocupa ese directorio:
		du -shc /var/lib/motion/
	
	# Para borrar el contenido:
		sudo rm -r /var/lib/motion/

	# Para configurar y controlar el Motion acceder por web:
		http://192.168.0.105:8080
	
	# Utilidades para saber los formatos y Resoluciones soportadas por nuestra Webcam:
		sudo apt-get install v4l-utils libv4l-0
			v4l2-ctl
			v4l2-ctl --all
			v4l2-ctl --list-formats
			v4l2-ctl --list-formats-ext
	
		sudo apt-get install uvcdynctrl
			uvcdynctrl -f	# Lista Resoluciones soportadas por la WebCam de manera nativa (por Hardware)
			uvcdynctrl -l
	#
	####
	
'Servidor SAMBA (compartir directorios con la Red)'
	
	'Instalar Samba'
	sudo apt-get install samba samba-common-bin
		
	'Crear directorios a compartir'	
	mkdir /home/orangeprint/share
		
	'Configurar Samba'
	sudo nano /etc/samba/smb.conf
		
		`Global`
		wins support = yes
		
		`Share Definitions`		# Al final del archivo:
		[opiz_share]
		comment= Carpeta compartida
		path= /home/orangeprint/share
		browseable= Yes
		writeable= Yes
		read only = no
		guest ok = Yes
		only guest= no
		create mask= 0777
		directory mask= 0777
		public= no
		write list = root, orangeprint

		[opiz_upload]
		comment= Carpeta Upload STLs
		path= /home/orangeprint/.octoprint/uploads
		browseable= Yes
		writeable= Yes
		read only = no
		guest ok = Yes
		only guest= no
		create mask= 0777
		directory mask= 0777
		public= no
		write list = root, orangeprint

		[timelapse]
		comment= camara timelapses
		path= /home/orangeprint/.octoprint/timelapse
		browseable= Yes
		writeable= Yes
		read only = no
		guest ok = Yes
		only guest= no
		create mask= 0777
		directory mask= 0777
		public= no
		write list = root, orangeprint
			
	'Poner una contraseña al usuario'
	sudo smbpasswd -a root
	sudo smbpasswd -a orangeprint
	
	'Reiniciar servidor Samba'
	sudo /etc/init.d/samba restart
	

'Acceder a directorio externo'	
	
	sudo apt-get install cifs-utils nfs-common
	
	mkdir /home/orangeprint/.octoprint/uploads/shared
	chmod 777 /home/orangeprint/.octoprint/uploads/shared
	
	'Modo simple'
	sudo nano /etc/fstab
		//192.168.0.000/directorio_compartido /home/orangeprint/.octoprint/uploads/shared cifs user=USERNAME,password=PASSWORD,noexec,user,rw,nounix,iocharset=utf8 0 0


'GPIO: control de Relés para encender y apagar la Impresora'

	'WIRINGOP (MPU H3 y H5)'
	# https://github.com/kazukioishi/WiringOP
	
		`Instalacion`
		"OPI H3:"	git clone https://github.com/kazukioishi/WiringOP.git -b h3
		"OPI H5:"	git clone https://github.com/kazukioishi/WiringOP.git -b h5
				
			cd WiringOP
			chmod +x ./build
			sudo ./build

	'WIRINGOP-Zero (MPU H2)'
	# https://github.com/xpertsavenue/WiringOP-Zero
		`Instalacion`
		"OPI H2 (Zero):"	git clone https://github.com/xpertsavenue/WiringOP-Zero.git
			
			cd WiringOP-Zero
			chmod +x ./build
			sudo ./build
					
	'Test'
	# Muestra tabla ASCII GPIO
	gpio readall
	# Activar Led Rojo de la Placa
	gpio write 30 1

		 ###===========Ejemplo de la respuesta del comando 'gpio readall'=============###
		 #						Para una Orange Pi Zero H2+								#
		 +																				+
		 +-----+-----+----------+------+--Orange Pi Zero--+---+------+---------+-----+--+
		 | H2+ | wPi |   Name   | Mode | V | Physical | V | Mode | Name     | wPi | H2+ |
		 +-----+-----+----------+------+---+----++----+---+------+----------+-----+-----+
		 |     |     |     3.3v |      |   |  1 || 2  |   |      | 5v       |     |     |
		 |  12 |   8 |    SDA.0 | ALT5 | 0 |  3 || 4  |   |      | 5V       |     |     |
		 |  11 |   9 |    SCL.0 | ALT5 | 0 |  5 || 6  |   |      | 0v       |     |     |
		 |   6 |   7 |   GPIO.7 | ALT3 | 0 |  7 || 8  | 0 | ALT5 | TxD3     | 15  | 198 |
		 |     |     |       0v |      |   |  9 || 10 | 0 | ALT5 | RxD3     | 16  | 199 |
		 |   1 |   0 |     RxD2 | ALT5 | 0 | 11 || 12 | 0 | ALT3 | GPIO.1   | 1   | 7   |
		 |   0 |   2 |     TxD2 | ALT5 | 0 | 13 || 14 |   |      | 0v       |     |     |
		 |   3 |   3 |     CTS2 | ALT3 | 0 | 15 || 16 | 0 | ALT4 | GPIO.4   | 4   | 19  |
		 |     |     |     3.3v |      |   | 17 || 18 | 0 | ALT4 | GPIO.5   | 5   | 18  |
		 |  15 |  12 |     MOSI | ALT5 | 0 | 19 || 20 |   |      | 0v       |     |     |
		 |  16 |  13 |     MISO | ALT5 | 0 | 21 || 22 | 0 | ALT3 | RTS2     | 6   | 2   |
		 |  14 |  14 |     SCLK | ALT5 | 0 | 23 || 24 | 0 | ALT5 | CE0      | 10  | 13  |
		 |     |     |       0v |      |   | 25 || 26 | 0 | ALT3 | GPIO.11  | 11  | 10  |
		 +-----+-----+----------+------+---+---LEDs---+---+------+----------+-----+-----+
		 |  17 |  30 | STAT-LED |  OUT | 0 | 27 || 28 |   |      | PWR-LED  |     |     |
		 +-----+-----+----------+------+---+-----+----+---+------+----------+-----+-----+
		 | H2+ | wPi |   Name   | Mode | V | Physical | V | Mode | Name     | wPi | H2+ |
		 +-----+-----+----------+------+--Orange Pi Zero--+---+------+---------+-----+--+
		 
		 
		 ###===========Ejemplo de la respuesta del comando 'gpio readall'=============###
		 #						Para una Orange Pi PC+ (H3)								#
		 +																				+		 
		 +-----+-----+----------+------+---+-Orange Pi+---+---+------+---------+-----+--+
		 | BCM | wPi |   Name   | Mode | V | Physical | V | Mode | Name     | wPi | BCM |
		 +-----+-----+----------+------+---+----++----+---+------+----------+-----+-----+
		 |     |     |     3.3v |      |   |  1 || 2  |   |      | 5v       |     |     |
		 |  12 |   8 |    SDA.0 | ALT3 | 0 |  3 || 4  |   |      | 5V       |     |     |
		 |  11 |   9 |    SCL.0 | ALT3 | 0 |  5 || 6  |   |      | 0v       |     |     |
		 |   6 |   7 |   GPIO.7 |  OUT | 0 |  7 || 8  | 0 | ALT3 | TxD3     | 15  | 13  |
		 |     |     |       0v |      |   |  9 || 10 | 0 | ALT3 | RxD3     | 16  | 14  |
		 |   1 |   0 |     RxD2 | ALT3 | 0 | 11 || 12 | 0 | ALT3 | GPIO.1   | 1   | 110 |
		 |   0 |   2 |     TxD2 | ALT3 | 0 | 13 || 14 |   |      | 0v       |     |     |
		 |   3 |   3 |     CTS2 | ALT3 | 0 | 15 || 16 | 0 | ALT3 | GPIO.4   | 4   | 68  |
		 |     |     |     3.3v |      |   | 17 || 18 | 0 | ALT3 | GPIO.5   | 5   | 71  |
		 |  64 |  12 |     MOSI | ALT3 | 0 | 19 || 20 |   |      | 0v       |     |     |
		 |  65 |  13 |     MISO | ALT3 | 0 | 21 || 22 | 0 | ALT3 | RTS2     | 6   | 2   |
		 |  66 |  14 |     SCLK | ALT3 | 0 | 23 || 24 | 0 | ALT3 | CE0      | 10  | 67  |
		 |     |     |       0v |      |   | 25 || 26 | 0 | ALT3 | GPIO.11  | 11  | 21  |
		 |  19 |  30 |    SDA.1 | ALT3 | 0 | 27 || 28 | 0 | ALT3 | SCL.1    | 31  | 18  |
		 |   7 |  21 |  GPIO.21 | ALT3 | 0 | 29 || 30 |   |      | 0v       |     |     |
		 |   8 |  22 |  GPIO.22 | ALT3 | 0 | 31 || 32 | 0 | ALT3 | RTS1     | 26  | 200 |
		 |   9 |  23 |  GPIO.23 | ALT3 | 0 | 33 || 34 |   |      | 0v       |     |     |
		 |  10 |  24 |  GPIO.24 | ALT3 | 0 | 35 || 36 | 0 | ALT3 | CTS1     | 27  | 201 |
		 |  20 |  25 |  GPIO.25 | ALT3 | 0 | 37 || 38 | 0 | ALT3 | TxD1     | 28  | 198 |
		 |     |     |       0v |      |   | 39 || 40 | 0 | ALT3 | RxD1     | 29  | 199 |
		 +-----+-----+----------+------+---+----++----+---+------+----------+-----+-----+
		 | BCM | wPi |   Name   | Mode | V | Physical | V | Mode | Name     | wPi | BCM |
		 +-----+-----+----------+------+---+-Orange Pi+---+------+----------+-----+-----+


		 
	'Configurar estado inicial de los pins'	 
	# El pin usado para conectar el relé sera el pin 7 dado que nace en estado bajo (0.03v).
	# Con el comando 'gpio readall' en la columna 'wpi' nos indicara el numero del gpio a usar, por ejemplo el (gpio 7)
	# Editar archivo '/etc/rc.local' y agregar siguiente texto antes de la linea 'exit 0' y editarlo según convenga:
	sudo nano /etc/rc.local
	
		#====================#
		#    GPIO CONFIG     #
		#====================#

		# INSTRUCCIONES:
		# 1. INSTALA DEL REPOSITORIO CORRESPONDIENTE A TU MPU (H2,, H3 O H5)
		#    H2+   = https://github.com/xpertsavenue/WiringOP-Zero
		#    H3-H5 = https://github.com/kazukioishi/WiringOP
		#
		# 2. USA COMANDO 'gpio readall' PARA SABER QUE GPIO ESTA ASIGNADO A CADA PIN
		#
		# 3. INDICA EL NUMERO DEL GPIO QUE VAS A USAR TAL COMO INDICA EL EJEMPLO
		#    COPIA LA ESTRUCTURA POR CADA UNO DE LOS PINES QUE QUIERES USAR.
		#
		# 4. SI NECESITAS CAMBIAR EL ESTADO INICIAL DE UN PIN PUEDES AGREGAR LINEA
		#    SIGUIENTE. DONDE 'X' ES EL PIN E 'Y' ES EL ESTADO.
		#    sudo gpio write x y
		
		sudo gpio mode 7 out

		#--FIN--#

		
'Plugins Octoprint'

	'Cambiar permisos directorio ./venv'
	# Si en la sección 'Plugin Manager' aparece un mensaje de error de acceso al comando `pip` debemos
	# dar acceso total así:
	sudo chmod -R 777 ./venv/


	'Firmware Updater'			https://plugins.octoprint.org/plugins/firmwareupdater/
		`Preinstalar`
		sudo apt-get install avrdude		
		`Configurar`
			Path to avrdude:	/usr/bin/avrdude

	'GCODE System Commands'		https://github.com/kantlivelong/OctoPrint-GCodeSystemCommands
		`Configurar`
		OCTO80	gpio write 7 0
		OCTO81	gpio write 7 1
		
	'GcodeEditor'				https://github.com/ieatacid/OctoPrint-GcodeEditor
	
	'Navbar Temp'				https://github.com/imrahil/OctoPrint-NavbarTemp
	
	'OctoPrint-FloatingNavbar'	https://plugins.octoprint.org/plugins/floatingnavbar/

	'PSU CONTROL'				https://plugins.octoprint.org/plugins/psucontrol/
		`Configurar`
			`Switching`
			Switching Method:	System Command
			On System Command:	gpio write 7 1
			Off System Command:	gpio write 7 0
			Enable switching with G-Code commands.	CHECK
			On G-Code Command: 	OCTO81
			Off G-code Command	OCTO80


			`Power Off Options`
			Automatically turn PSU OFF when idle 	CHECK
			Idle TimeOut	10

	'Preheat Button'			https://github.com/marian42/octoprint-preheat
		`Configurar`
		Fallback temperature for tool preheating	200		# Para PLA
		Fallback temperature for bed preheating		 50		# "		"
		
	'Simple Emergency Stop'		https://github.com/BrokenFire/OctoPrint-SimpleEmergencyStop	
		`Configurar`
		Emergency GCODE:	OCTO80
		
	'System Command Editor'		https://github.com/Salandora/OctoPrint-SystemCommandEditor
		`Configurar`
		Name:		Impresora On
		Action:		Activar Rele de la Fuente
		Command:	gpio write 7 1
		
		Name:		Impresora OFF
		Action:		Desactivar Rele de la Fuente
		Command:	gpio write 7 0
		
		Name:		WebCam ON
		Action:		Iniciar Servidor Motion
		Command:	sudo service motion start

		Name:		WebCam OFF
		Action:		Detener Servidor Motion
		Command:	sudo service motion stop|restart
		
		Name:		WebCam Restart
		Action:		Reiniciar Servidor Motion
		Command:	sudo service motion restart
		
	'TouchUI'					http://plugins.octoprint.org/plugins/touchui/
	

		
'LIMPIAR HISTORIAL Y CACHES'


	'Borrar paquetes parciales'
	sudo apt-get autoclean
	
	'Eliminar paquetes *.deb de las instalaciones'
	sudo apt-get clean
		
	'Eliminar Paquetes y dependencias que el sistema ya no necesita'
	sudo apt-get autoremove
	sudo apt-get purge
		
	'Eliminar datos locales innecesarios'
	sudo apt-get install localepurge
	
	'Historial de comandos'
	history -c
		
	*Borrar a mano:
	sudo nano /home/usuario/.bash_history


'========UTILIDADES=========='

'Cambiar contraseña Usuario'
	sudo passwd usuario

'Eliminar contraseña Usuario'
	sudo passwd usuario -d
	
'Ejecutar para el proximo arranque la adaptacion automatica de tamaño de la particion'
	sudo systemctl enable resize2fs
	reboot

	# Si no funciona probar:
	sudo systemctl enable resize2fs
	sudo update-rc.d resize2fs defaults 	
	reboot
	
'Copia Seguridad SD por USB'
	# Conectar PEN o HDD al USB
	# Para Saber si lo detecto y ver la partición 
	fDisk -l
	
	# Crear Directorio
	mkdir /media/USB
	# Montar USB
	mount /dev/sda1	/media/USB		# Donde sda1 el la partición que queremos montar que vimos en el fdisk -l
	
	# Desmontar Unidades a copiar
	sudo umount /dev/mmcblk0p1
	
	# Iniciar Copia de Seguridad
	sudo dd if=/dev/mmcblk0 of=/media/USB/mibackup.img bs=1M
	
'Cambiar Tamaño Particion dentro de una *.img'	
https://softwarebakery.com/shrinking-images-on-linux

	# En una maquina Linux, cargar la imagen "*.img":
	sudo modprobe loop
	sudo losetup -f
	sudo losetup /dev/loop0 myimage.img
	sudo partprobe /dev/loop0
	
	# Contraer partición con GParted
	sudo gparted /dev/loop0
	https://softwarebakery.com/shrinking-images-on-linux/gparted-01.png
	
	# Desmontar la imagen
	sudo losetup -d /dev/loop0
	
	# Saber los bloque y el tamaño de bloques del espacio particionado
	sudo losetup -d /dev/loop0
	
	# Recortar el espacio sin particionar de la imagen
	truncate --size=$[(????????+1)*512] myimage.img
	
'=========FIN=========='	
	
'URLs de Información:'

	`Octoprint:` 	https://github.com/foosel/OctoPrint/wiki/Setup-on-a-Raspberry-Pi-running-Raspbian
	
	`Motion:`		https://github.com/Motion-Project/motion
					https://goo.gl/18E1GA
					http://www.orangepi.org/Docs/Webcams.html
	
	`WebCam Format`	https://github.com/raspberrypi/firmware/issues/347
					https://superuser.com/questions/639738/how-can-i-list-the-available-video-modes-for-a-usb-webcam-in-linux
					
	`Samba y cifs`	https://help.ubuntu.com/community/Samba/SambaClientGuide
					https://help.ubuntu.com/community/MountWindowsSharesPermanently
					https://www.upv.es/contenidos/INFOACCESO/infoweb/infoacceso/dat/724147normalc.html
					
	`GPIO`			http://www.orangepi.org/orangepibbsen/forum.php?mod=viewthread&tid=1308&highlight=gpio
					https://diyprojects.io/orange-pi-armbian-install-wiringop-library-wiringpi-equivalent/#.WZf5iuntbRZ
					
	`resize2fs`		https://forum.armbian.com/topic/487-reinitiate-sd-card-resize-on-boot/?do=findComment&comment=28814
					https://forum.armbian.com/topic/3783-orange-pi-lite-freezes/?do=findComment&comment=27487
					
					
					
					
					
					
	