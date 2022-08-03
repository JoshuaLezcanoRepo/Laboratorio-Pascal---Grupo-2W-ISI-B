Program ESC7;
Uses crt;

Type
    lan_traffic = record // Formato del registro
		Clave: record
			Prot_Red: 1..3;
			Prot_Transp: 1..2;
		end;
		Puerto_Origen: 1..65535;
		Puerto_Dest: 1..65535;
		Horario: record
			hh: 8..15;
			mm: 1..59;
			ss: 1..59;
		end;
		Dia: record
			dd: 4..6;
			mm: string[7];
			aaaa: string[22];
		end;
		IPOrigen: string[15];
		IPDestino: string[15];
	end;

const
	valido = [80, 21, 25];

Var
	arch: file of lan_traffic; // Archivo
	reg: lan_traffic; // Variable para Leer registros
	
	ResRed: 1..3; // Resguardo para Red
	ResTransp: 1..2; // Resguardo para Transporte

	TotRed80, TotRed21, TotRed25: longint; // Totalizadores para Redes (80, 21, 25)
	TotTransp80, TotTransp21, TotTransp25: longint; // Totalizadores para Transporte (80, 21, 25)
	TotRedGral, TotTranspGral: longint; // Totalizadores Generales para Red y Transporte

	procedure CORTE_1; // Subaccion para Corte 1
    begin
        writeln('Total de paquetes enviados al puerto destino 80 correspondientes al Protocolo de Red ', ResRed, ' y al Protocolo de Transporte ', ResTransp, ' es de: ', TotTransp80);
		writeln('Total de paquetes enviados al puerto destino 21 correspondientes al Protocolo de Red ', ResRed, ' y al Protocolo de Transporte ', ResTransp, ' es de: ', TotTransp21);
		writeln('Total de paquetes enviados al puerto destino 25 correspondientes al Protocolo de Red ', ResRed, ' y al Protocolo de Transporte ', ResTransp, ' es de: ', TotTransp25);
		TotTranspGral:= TotTransp80 + TotTransp21 + TotTransp25;
		writeln('Total de paquetes enviados correspondientes al Protocolo de Red ', ResRed, ' y al protocolo de Transporte ', ResTransp, ' es de: ', TotTranspGral);
		TotRed80:= TotRed80 + TotTransp80;
		TotRed21:= TotRed21 + TotTransp21;
		TotRed25:= TotRed25 + TotTransp25;
		TotTransp80:= 0;
		TotTransp21:= 0;
		TotTransp25:= 0;
		ResTransp:= reg.Clave.Prot_Transp;
		writeln(' ');
		writeln('Presione cualquier tecla para continuar');
		ReadKey;
		writeln(' ');
    end;
    
    procedure CORTE_2; // Subaccion para Corte 2
    begin
        CORTE_1;
        writeln('Total de paquetes enviados al puerto destino 80 correspondientes al Protocolo de Red ', ResRed, ' es de: ', TotRed80);
		writeln('Total de paquetes enviados al puerto destino 21 correspondientes al Protocolo de Red ', ResRed, ' es de: ', TotRed21);
		writeln('Total de paquetes enviados al puerto destino 25 correspondientes al Protocolo de Red ', ResRed, ' es de: ', TotRed25);
		TotRedGral:= TotRed80 + TotRed25 + TotRed21;
		writeln('Total de paquetes enviados correspondientes al Protocolo de Red ', ResRed, ' es de: ', TotRedGral);
		TotRed80:= 0;
		TotRed21:= 0;
		TotRed25:= 0;
		ResRed:= reg.Clave.Prot_Red;
		writeln(' ');
		writeln('Presione cualquier tecla para continuar');
		ReadKey;
		writeln(' ');
    end;

	procedure VER_CORTE; // Subaccion para Ver Corte
    begin
        if reg.Clave.Prot_Red <> ResRed then
			begin
            	CORTE_2;
			end
            else if reg.Clave.Prot_Transp <> ResTransp then
			begin
                CORTE_1;
			end
    end;

	procedure TRATAR_REGISTRO; // Subaccion para Tratar Registro
    begin
        case reg.Puerto_Dest of
            80: TotTransp80:= TotTransp80 + 1;
		    21: TotTransp21:= TotTransp21 + 1;
		    25: TotTransp25:= TotTransp25 + 1;
        end;

        if reg.Puerto_Dest in valido then
            begin
                writeln('Existe una posibilidad de escaneo para ataques');
			    writeln('Protocolo de Red: ', reg.Clave.Prot_Red);
		    	writeln('Protocolo de Transporte: ', reg.Clave.Prot_Transp);
			    writeln('Puerto de origen: ', reg.Puerto_Origen);
			    writeln('Puerto de destino: ', reg.Puerto_Dest);
			    writeln('Hora: ', reg.Horario.hh, ':', reg.Horario.mm, ':', reg.Horario.ss);
			    writeln('Fecha: ', reg.Dia.dd, '/', reg.Dia.mm, '/', reg.Dia.aaaa);
			    writeln('IP de Origen: ', reg.IPOrigen);
			    writeln('IP de Destino: ', reg.IPDestino);
				writeln(' ');
				writeln('Presione cualquier tecla para continuar');
				ReadKey;
				writeln(' ');
            end;
    end;

begin
	assign(arch, 'archivo.dat');
    {$I-}
    reset(arch);
    {$I+}
    read(arch, reg);

	ResRed:= reg.Clave.Prot_Red; ResTransp:= reg.Clave.Prot_Transp; // Asignamos los Resguardos de Red y Transporte a sus elementos en el Registro

	TotRed80:= 0; TotRed21:= 0; TotRed25:= 0; // Inicializo Totalizadores Red
	TotTransp80:= 0; TotTransp21:= 0; TotTransp25:= 0; // Inicializo Totalizadores Transporte
	TotRedGral:= 0; TotTranspGral:= 0; // Inicializo Totalizadores Red y Transporte

	while not EOF(arch) do
	begin
        VER_CORTE;
		TRATAR_REGISTRO;
		read(arch, reg);
    end;
	CORTE_2;
	writeln(' ');
	writeln('El Archivo ha finalizado');
	ReadKey;
	close(arch);
end.