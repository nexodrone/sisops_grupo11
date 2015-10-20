#!/usr/bin/perl -w
use strict;
use warnings;
use Fcntl qw(:flock);
use feature qw/switch/; 
use Switch;

our %posCamposCentrales = (
			'codigo' => 0,
			'descripcion' => 1,	
			);

 our %posCamposAgentes = (
			'id' =>0,
	                 'oficina'=>3,
			 'email'=>4
			     

			);

  our %posCamposPaises =(
			'id' => 0,
			'nombre' => 1,
                          
		        );
our %posCamposCodigosArea=(
		         'codigoArea' => 1,
			'area' => 0,

);

our %posCamposLlamadasSospechosa= (
				   'idCentral' => 0,
				   'idAgente' => 1,
				    'idUmbral'=>2,
			            'tipoLlamada'=>3,
				    'inicioLlamada'=>4,
				    'tConv'=>5,
				    'nroArea'=>6,
			            'nroAlinea'=>7,
                                    'nroBcdp'=>8,
                                    'nroBcda'=>9,
                                    'nroBlinea'=>10,
                                    'FechaArchivo'=>11,
	
);
our $pidioGuardar = 0;
our %centralesDesc;
our %agentesMail;
our %agentesOficina;
our %paisesDesc;
our %codigosAreaDesc;
our %rankingOficinas;
our %rankingCentrales;

###### Se valida que el comando no este en ejecución#####
open(my $script_fh, '<', $0)
   or die("No se pudo abrir el archivo: $!\n");

unless (flock($script_fh, LOCK_EX|LOCK_NB)) {
    print "$0 ya se encuentra en ejecución.\n";
    exit(1);
}

###### Se valida ejecucion de AFRAINIC######
# Si no existen las variables de ambiente sabemos que Afranic no se ejecuto
if (!exists($ENV{"MAEDIR"}) && !exists($ENV{"PROCDIR"})  && !exists($ENV{"NOVEDIR"}))
{
	 print "Previamente debe inicializar el ambiente\n";
     exit(1);	  
} 


###### MENU ##############################
###### Si no ingresa ningún parametro se mostrará la ayuda
my $num_parametros = $#ARGV + 1;
#cargarMapaGestiones();
#cargarMapaEmisores();
#cargarMapaNormas();

if ($num_parametros < 1) {
    print "Debe ingresar una opción.\n";
    mostrarAyuda();
    exit;
}else{
	my $primero=$ARGV[0];
	if($primero eq "-h") { mostrarAyuda(); }
	elsif($primero eq "-r") { consultar();}
	elsif($primero eq "-i") { informar(); }
	elsif($primero eq "-s") { estadisticas();}
	else { 
		print "Opción incorrecta.\n";
    		mostrarAyuda();
    		exit;
    	}
}




sub mostrarAyuda {

print "Ayuda: AFRALIST [opción] [argumentos] 
	  -h                  			Muestra esta ayuda.
	  -w                  			Grabar. 
	  -r[palabra clave]   			Consulta .
	  -i[lista de archivos resultado]   	Información
	  -s                  			Estadísticas\n";
}

sub consultar {


}


sub informar {

}


sub estadisticas {

       
	validarGuardarInforme();
	menu_estadistica();


}

sub validarGuardarInforme
{
	my $ultimaEntrada = $ARGV[$#ARGV];
	#print "ultima entrada: $ultimaEntrada";
	if(defined $ultimaEntrada and $ultimaEntrada eq "-w"){
		$pidioGuardar = 1;	
	}

}

# esta función determina si hay que procesar el archivo que se está leyendo. 
sub hayQueProcesar {

return 1; 

}

#*******************************
#métodos de cargas iniciales

sub cargarMapaCentrales
{
	#my $ruta ='./MAEDIR';
	my $ruta = $ENV{"MAEDIR"};
	my $filename = $ruta.'/CdC.mae';
	open(my $fh,"<$filename")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $filename \n";
		#Leo cada linea 
		while (my $row = <$fh>) {
			chomp $row;
			my @data = split(";",$row);
			my $descripcion = $data[$posCamposCentrales{'descripcion'}];
			my $codigo = $data[$posCamposCentrales{'codigo'}];
			$centralesDesc{$codigo} = $descripcion;
                        $rankingCentrales{$codigo}=0;
		}
	close ($fh);
                                 # print $centralesDesc{'BEL'};
}


sub cargarMapaAgentes
{
        #my $ruta ='./MAEDIR';
	my $ruta = $ENV{"MAEDIR"};
        #print "$ruta";
	my $filename = $ruta.'/agentes.mae';

       

	open(my $fh,"<$filename")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $filename \n";
		#Leo cada linea 
		while (my $row = <$fh>) {
			chomp $row;
			my @data = split(";",$row);
			my $id = $data[$posCamposAgentes{'id'}];
			my $oficina = $data[$posCamposAgentes{'oficina'}];
			my $email=$data[$posCamposAgentes{'email'}];
			
                        $agentesOficina{$id}=$oficina;
			$agentesMail{$id}=$email;
			$rankingOficinas{$oficina}=0;
                        #print "$rankingOficinas{$oficina}, $oficina \n";

		}
	close ($fh);
            
                      #print "$agentesOficina{'CARRO'},' ' ,$agentesMail{'CARRO'} \n";


	
}

sub cargarCodigoPaises
{

   #my $ruta ='./MAEDIR';
	my $ruta = $ENV{"MAEDIR"};
	my $filename = $ruta.'/CdP.mae';
	open(my $fh,"<$filename")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $filename \n";
		#Leo cada linea 
		while (my $row = <$fh>) {
			chomp $row;
			my @data = split(";",$row);
			my $id = $data[$posCamposPaises{'id'}];
			my $nombrePais = $data[$posCamposPaises{'nombre'}];
			
			
                        $paisesDesc{$id}=$nombrePais;
			

		}
	close ($fh);

                
}

sub cargarCodigoArea
{

        #my $ruta ='./MAEDIR';
	my $ruta =$ENV{"MAEDIR"};
        
	my $filename = $ruta.'/CdA.mae';
	open(my $fh,"<$filename")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $filename \n";
		#Leo cada linea 
		while (my $row = <$fh>) {
			chomp $row;
			my @data = split(";",$row);
			my $codigoArea = $data[$posCamposCodigosArea{'codigoArea'}];
			my $nombrePais = $data[$posCamposCodigosArea{'area'}];
			
			
                        $codigosAreaDesc{$codigoArea}=$nombrePais;
			

		}
	close ($fh);

                       
}




#******************** calculo estadísticas**************
# se carga el rankings de centrales, previamente tiene que ser inicializado en cero. 
sub leerPorCentrales
{

        limpiarRankingCentrales();
        #my $dir= './PROCDIR';
	my $dir = $ENV{"PROCDIR"};
	

	opendir(DIR,$dir) || die "# buscador : no puedo abrir $dir\n";
        my @nodos = grep(!/^\./, (sort(readdir(DIR)))); # esquiva archivos ocultos, . y ..
        closedir(DIR); 
	
	

	foreach my $nodo (@nodos)  
	{
		  
		 my $nombreArchivo = $nodo;
                 
                my $filename = $dir.'/'.$nombreArchivo;
		open(ENT,"<$filename")|| die "NO SE PUEDE REALIZAR LA ACCIÓN. No se encontro el archivo $filename \n";
		#Leo cada linea 
          	
          	while( my $row = <ENT> ) { 
                        #print "$row \n";
			chomp($row);
			my @data = split(";",$row);
			my $idCentral = $data[$posCamposLlamadasSospechosa{'idCentral'}];

                        my $idAgente=$data[$posCamposLlamadasSospechosa{'idAgente'}];

                	$rankingCentrales{$idCentral}=$rankingCentrales{$idCentral}+1;

                         #print "$rankingCentrales{$idCentral}, ' ',$idAgente,' ',$idCentral \n";
		}
                close(ENT);
		
	  }
          #print "cantidad de registros $count \n";
	
          
       
}

sub leerPorOficinas
{
        limpiarRankingOficinas();
	#limpiarRankingCentrales();
        #my $dir= './PROCDIR';
	my $dir = $ENV{"PROCDIR"};
	

	opendir(DIR,$dir) || die "# buscador : no puedo abrir $dir\n";
        my @nodos = grep(!/^\./, (sort(readdir(DIR)))); # esquiva archivos ocultos, . y ..
        closedir(DIR); 
	

	foreach my $nodo (@nodos)  
	{
		  
		 my $nombreArchivo = $nodo;
                 
                my $filename = $dir.'/'.$nombreArchivo;
		open(ENT,"<$filename")|| die "NO SE PUEDE REALIZAR LA ACCIÓN. No se encontro el archivo $filename \n";
		#Leo cada linea 
          	
               
		my @fields = split /_/, $nombreArchivo;
		my $oficina = $fields[0];
		$rankingOficinas{$oficina}=$rankingOficinas{$oficina} +1;

		#print "$oficina,$rankingOficinas{$oficina}\n";


          	#print "$nombreArchivo \n";


                close(ENT);
		
	  }




}


sub limpiarRankingCentrales{
           
          foreach my $name (keys %rankingCentrales) {
	    	 $rankingCentrales{$name}=0;
	}
		 
                 

             
}

sub limpiarRankingOficinas
{
      foreach my $name (keys %rankingOficinas) {
	    	 $rankingOficinas{$name}=0;
                  print ""
	}



}

#************impresión**************************


sub imprimirRankingCentrales
{
	 my $resultadoArchivo = ""; 
	
          
         
my @keys = sort {$rankingCentrales{$b}  <=> $rankingCentrales{$a} } keys %rankingCentrales;

foreach my $key ( @keys ) {
    
          $resultadoArchivo .= "$rankingCentrales{$key}  $key  $centralesDesc{$key}\n";
}


           print $resultadoArchivo;
	if($pidioGuardar == 1){
		grabar($resultadoArchivo,"resultado");	
	}

}

sub imprimirRankingOficinas
{

		my $resultadoArchivo = ""; 
		my @keys = sort {$rankingOficinas{$b}  <=> $rankingOficinas{$a} } keys %rankingOficinas;

		foreach my $key ( @keys ) {
    
          		$resultadoArchivo .= "$rankingOficinas{$key}  $key \n";
		}


           print $resultadoArchivo;
	if($pidioGuardar == 1){
		grabar($resultadoArchivo,"resultado");	
	}



}

sub grabar 
{
	my $resultado = $_[0];
	my $nombre = $_[1];
	my $ruta = $ENV{"GRUPO"}.'/'.'reportes';
	
	
	my $epoc = time();
	my $nombreArchivo = $ruta."/".$nombre."_".$epoc.".txt";
	
	if(defined $resultado){
		open FILE, ">".$nombreArchivo or die $!; 
		print FILE "$resultado\n"; 
		close FILE;
		print "Se generó el archivo $nombreArchivo\n";
	}else{
		print "La consulta no produjo resultados.\n";
	}

}


sub clear_screen
{
    system("clear");
}
#*****************Estadisticas*********************
sub menu_estadistica
{ 
cargarMapaAgentes();
cargarMapaCentrales();
cargarCodigoPaises();
cargarCodigoArea();
leerPorCentrales();
leerPorOficinas();
#clear_screen();

	my $input = '';

	while ($input ne '6')
	{
	    
	    print " \n";
 	    print "************MENÚ Estadisticas************ \n";		
	    print "1. Ranking de centrales con llamadas sospechosas\n". 
		  "2. Ranking de oficinas con llamadas sospechosas\n". 
                  "3. Ranking de agentes con llamadas sospechosas \n".
                  "4. Ranking de destinos con llamadas sospechosas \n".
                  "5. Ranking de umbrales con mas de una llamada sospechosa \n".
		  "6. Salir\n";

	    print "Ingrese su opción: ";
	    $input = <STDIN>;
	    chomp($input);

	    switch ($input)
	    {
		case '1'
		{
		    imprimirRankingCentrales();

		}
		case '2'
		{
                    imprimirRankingOficinas();
		    	
		}
		case '3'{}
		
                case '4'{}
                
                case '5'{}
               
                case '6'{}


		else{
			print "Opción Incorrecta! \n";
		}

	    }#del switch
	}#del while

	exit(0);             
}
