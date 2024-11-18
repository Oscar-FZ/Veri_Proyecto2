class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    // Constructor de la clase "scoreboard"
    // Inicializa la clase con un nombre predeterminado y un componente padre
    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction


    shortreal X, Y; //Variables tipo short real donde se guardaran los valores enviados al DUT para ser multiplicados.

    int archivo_csv; //Variable para poder abrir el archivo .csv donde se registraran los resultados de las pruebas.
    int cuenta = 0;

    //Se definen las variables que van a contener el signo de cada valor.
    bit sign_X; 
    bit sign_Y;
    bit sign_Z;

    //Se definen las variables que van a contener el exponente de cada valor.
    bit [7:0] exp_X;
    bit [7:0] exp_Y;
    bit [7:0] exp_Z;

    //Se definen las variables que van a contener la fraccion de cada valor.
    bit [22:0] frac_X;
    bit [22:0] frac_Y;
    bit [22:0] frac_Z;

    //Se definen las variables necesarias para el calculo de redondeo de la multiplicacion
    bit [47:0] mul_frac;    //Se guarda el resultado completo de la multiplicacion de las fracciones de X y Y
    int msb;                //Se usa para guardar cual es el bit mas significatico con un valor de 1 de la multiplicacion //Ya no se usa
    bit round;              //Se usa para guardar el valor del round bit
    bit guard;              //Se usa para guardar el valor del guard bit
    bit sticky;             //Se usa para guardar el vaor del sticky bit
    bit [26:0] Z;           //Se usa para guardar los los 24 bits mas significativos de la multiplicacion mas el round, guard y sticky bit
    bit [23:0] Z_plus;      //Se usa para guardar el bit de Z + 1 //Ya no se usa
    bit [23:0] Z_round;     //Se usa para guardar el valor de Z redondeado //Ya no se usa

    bit [31:0] Z_aux;       //Se usa para guardar el resultado de la multiplicacion calculado por el scoreboard.
    bit ovrf_aux;           //Se usa para guardar el valor del overflow calculado por el scoreboard
    bit udrf_aux;           //Se usa para guardar el valor del underflow calculado por el scoreboard

    //Definicion del puerto de analisis que usa el monitor para enviarle informacion al scoreboard.
    uvm_analysis_imp #(Item, scoreboard) m_analysis_imp; 
    
    //Función para construir los componentes del monitor
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_analysis_imp = new("m_analysis_imp", this);

        archivo_csv = $fopen("resultados.csv", "w");
        if (archivo_csv == 0) begin
            `uvm_error("SCBD", "Failed to create CSV file for writing")
        end
        else begin
            $fwrite(archivo_csv, "%-12s %-8s %-14s %-16s %-16s %-16s %-15s %-15s %-15s %-15s\n", 
            "Tiempo", "r_mode", "fp_X", "fp_Y", "fp_Z_esperado", "fp_Z_recibido", 
            "ovrf_esperado", "ovrf_recibido", "udrf_esperado", "udrf_recibido"
        );
        end
    endfunction

    
    //Funcion utilizada para calcular si el resultado de la multiplicacion va a generar un over o under flow.
    function void obtener_flow (bit [7:0] exp1, bit [7:0] exp2);
        if (exp_X+exp_Y >= 382) begin //Overflow 
            ovrf_aux = 1'b1;
            udrf_aux = 1'b0;
        end
        
        else if (exp_X+exp_Y <= 127) begin //Underflow.
            udrf_aux = 1'b1;
            ovrf_aux = 1'b0;
        end
        else begin 
            udrf_aux = 1'b0;
            ovrf_aux = 1'b0;
        end
    endfunction

    //Fase que se usa para finalizar el funcionamiento del scoreboard y cerrar el archivo .csv
    virtual function void final_phase(uvm_phase phase); 
        super.final_phase(phase);
        $fclose(archivo_csv);
    endfunction

    //Funcion encargado de calcular los valores de Z, underflow y overflow los cuales se van a comparar con los resultados leidos del DUT.
    virtual function write(Item item);

        //Se guardan los signos, fracciones y exponentes de los valores que se van a multiplicar.
        sign_X = item.sign_X;
        sign_Y = item.sign_Y;

        frac_X = item.frac_X;
        frac_Y = item.frac_Y;

        exp_X = item.exp_X;
        exp_Y = item.exp_Y;

        
        //Se guardan los valores de X y Y en formato short real para poder definir si los valores de entrada del DUT se encuentran dentro del rango aceptado.
        //Esto se hace por que si el DUT recibe un valor por encima del rango lo va a tomar como si fuera infinito y si esta por debajo del rango lo toma como si fuera cero.
        X = $bitstoshortreal({sign_X, exp_X, frac_X});
        Y = $bitstoshortreal({sign_Y, exp_Y, frac_Y});

        //Verifica si el valor de X se encuentra dentro del rango aceptado.
        if ((X > 3.4028235e38) || (X < -3.4028235e38)) begin
            exp_X = 8'hFF;
            frac_X = 23'b0;
        end

        else if (((X < 1.1754942e-38) && (X > 0)) || ((X > -1.1754942e-38) && (X < 0))) begin
            exp_X = 8'h00;
            frac_X = 23'b0;
        end

        //Verifica si el valor de Y se encuentra dentro del rango aceptado.
        if ((Y > 3.4028235e38) || (Y < -3.4028235e38)) begin
            exp_Y = 8'hFF;
            frac_Y = 23'b0;
        end

        else if (((Y < 1.1754942e-38) && (Y > 0)) || ((Y > -1.1754942e-38) && (Y < 0))) begin
            exp_Y = 8'h00;
            frac_Y = 23'b0;
        end

        //Definicion del signo de Z
        sign_Z = sign_X ^ sign_Y;
        
        //Definicion del exponente de Z
        exp_Z = exp_X + exp_Y - 127;

        //Definicion de la fraccion de Z
        mul_frac = {1'b1, frac_X} * {1'b1, frac_Y};

        //Si el primer bit de la fraccion es 1, se hace un corrimiento a la derecha.
        if (mul_frac[47] == 1) begin
            mul_frac = mul_frac >> 1;
            exp_Z = exp_Z + 1'b1;
        end

        else begin //Si el primer bit de la fraccion es 0, se hace un corrimiento a la izquierda.
            mul_frac = {mul_frac[46:1], 1'b0}; 
        end

        //Si todos los bits del 21 al 0 son 0 el sticky bit es 0, de lo contrario es un 1. En otras palabra el sticky bit es un or de los del 21 al 0.
        if (mul_frac[21:0] == 0) begin
            sticky = 1'b0;
        end

        else begin
            sticky = 1'b1;
        end

        //Define los valores del guard bit y guarda todos los bits importantes en Z
        guard = mul_frac[23];
        Z = {mul_frac[47:22], (guard | sticky)};
        
        //Z[0] = guard|sticky
        //Z[1] = round

        //Casos de Redondeo
        case(item.r_mode)
            3'b000: begin //Round to nearest, ties to even
                if (!Z[1]) Z = Z;

                else begin
                    if (Z[0]) Z[24:2] = Z[24:2] + 1'b1;

                    else begin
                        if (!Z[2]) Z = Z;
                        else Z[24:2] = Z[24:2] + 1'b1;
                    end
                end
            end

            3'b001: begin //Round to zero
                Z = Z;
            end

            3'b010: begin //Round towards -inf
                if (sign_Z) Z[24:2] = Z[24:2] + 1'b1;
                else Z = Z;
            end

            3'b011: begin //Round towards +inf
                if (sign_Z) Z = Z;
                else Z[24:2] = Z[24:2] + 1'b1;
            end

            3'b100: begin //Round to nearest, ties away from zero
                if (Z[1]) Z[24:2] = Z[24:2] + 1'b1;
                else Z = Z;
            end    
        endcase

        //Define l valor final de la fraccion de Z
        frac_Z = Z[24:2];
        //Define el valor final de Z
        Z_aux = {sign_Z, exp_Z, frac_Z};

        //Casos Especiales
        if ((exp_X == 8'h00 && frac_X == 23'h000000) || (exp_Y == 8'h00 && frac_Y == 23'h000000)) begin //Multiplicacion por cero
            Z_aux = {sign_Z, 31'b0000_0000_0000_0000_0000_0000_0000_000};
            obtener_flow(exp_X, exp_Y);
        end

        else if ((exp_X == 8'hFF) || (exp_Y == 8'hFF)) begin 
            if ((exp_X == 8'hFF && frac_X != 0) || (exp_Y == 8'hFF && frac_Y != 0) || 
                (exp_Y == 8'hFF && frac_Y != 0 && exp_X == 8'h00 && frac_X == 23'h000000) || 
                (exp_X == 8'hFF && frac_X != 0 && exp_Y == 8'h00 && frac_Y == 23'h000000)) begin // Multiplicacion por NaN
                Z_aux = {1'b0, 31'b1111_1111_1000_0000_0000_0000_0000_000}; //El DUT solo genera +NaN
                obtener_flow(exp_X, exp_Y);
            end

            else begin //Multiplicacion por infinito
                Z_aux = {sign_Z, 31'b1111_1111_0000_0000_0000_0000_0000_000};
                obtener_flow(exp_X, exp_Y);
            end
        end

        else if (exp_X+exp_Y >= 382) begin //Overflow 
            Z_aux = {sign_Z, 31'b1111_1111_0000_0000_0000_0000_0000_000};
            ovrf_aux = 1'b1;
            udrf_aux = 1'b0;
        end
        
        else if (exp_X+exp_Y <= 127) begin //Underflow.
            Z_aux = {sign_Z, 31'b0000_0000_0000_0000_0000_0000_0000_000};
            udrf_aux = 1'b1;
            ovrf_aux = 1'b0;
        end
        else begin 
            Z_aux = Z_aux;
            udrf_aux = 1'b0;
            ovrf_aux = 1'b0;
        end

        //Escribe toda la informacion relevante en un archivo .csv
        $fwrite(archivo_csv, "%-12t %-6b %-14g %-14g %-16g %-16g %-17g %-15g %-15g %-15g\n", 
                $time, 
                item.r_mode, 
                $bitstoshortreal({item.sign_X, item.exp_X, item.frac_X}), 
                $bitstoshortreal({item.sign_Y, item.exp_Y, item.frac_Y}),
                $bitstoshortreal(Z_aux),
                $bitstoshortreal(item.fp_Z),
                ovrf_aux,
                item.ovrf,
                udrf_aux,
                item.udrf
            );

        //Realiza la comparacion con los resultados obtenidos por el scoreboard en contra de los leidos por el monitor. En caso de ser diferentes genera un error.
        if ((Z_aux != item.fp_Z)||(ovrf_aux != item.ovrf)||(udrf_aux != item.udrf)) begin 
            `uvm_error("SCBD", $sformatf("ERROR Z recibido = %0g Z esperado = %0g", $bitstoshortreal(item.fp_Z), $bitstoshortreal(Z_aux)))
            `uvm_info("SCBD", $sformatf("r mode=%0d X=%g Y=%g Z=%g Overflow=%b Underflow=%b",
                item.r_mode, $bitstoshortreal({item.sign_X, item.exp_X, item.frac_X}), $bitstoshortreal({item.sign_Y, item.exp_Y, item.frac_Y}), $bitstoshortreal(item.fp_Z), item.ovrf, item.udrf), UVM_LOW)
            `uvm_info("SCBD", $sformatf("127 <= %d <= 382 --- X = %d Y = %d", exp_X+exp_Y, item.exp_X, item.exp_Y), UVM_LOW)

        end

        else begin
            `uvm_info("SCBD", $sformatf("CORRECTO Z recibido = %0g Z esperado = %0g", $bitstoshortreal(item.fp_Z), $bitstoshortreal(Z_aux)), UVM_HIGH)
            `uvm_info("SCBD", $sformatf("r mode=%0d X=%g Y=%g Z=%g Overflow=%b Underflow=%b",
                item.r_mode, $bitstoshortreal({item.sign_X, item.exp_X, item.frac_X}), $bitstoshortreal({item.sign_Y, item.exp_Y, item.frac_Y}), $bitstoshortreal(item.fp_Z), item.ovrf, item.udrf), UVM_HIGH)

        end

    endfunction
endclass
