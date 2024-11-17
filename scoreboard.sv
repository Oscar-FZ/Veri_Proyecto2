class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //TODO Definir variables que seran usadas para el checkeo

    shortreal X, Y;

    int archivo_csv;

    bit sign_X;
    bit sign_Y;
    bit sign_Z;

    bit [7:0] exp_X;
    bit [7:0] exp_Y;
    bit [7:0] exp_Z;

    bit [22:0] frac_X;
    bit [22:0] frac_Y;
    bit [22:0] frac_Z;

    bit [47:0] mul_frac;
    int msb;
    bit round;
    bit guard;
    bit sticky;
    bit [26:0] Z;
    bit [23:0] Z_plus;
    bit [23:0] Z_round;

    bit [31:0] Z_aux;
    bit ovrf_aux;
    bit udrf_aux;

    uvm_analysis_imp #(Item, scoreboard) m_analysis_imp;

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

    virtual function void final_phase(uvm_phase phase); 
        super.final_phase(phase);
        $fclose(archivo_csv);
    endfunction

    virtual function write(Item item);

        sign_X = item.sign_X;
        sign_Y = item.sign_Y;

        frac_X = item.frac_X;
        frac_Y = item.frac_Y;

        exp_X = item.exp_X;
        exp_Y = item.exp_Y;

        X = $bitstoshortreal({sign_X, exp_X, frac_X});
        Y = $bitstoshortreal({sign_Y, exp_Y, frac_Y});

        if ((X > 3.4028235e38) || (X < -3.4028235e38)) begin
            exp_X = 8'hFF;
            frac_X = 23'b0;
        end

        else if (((X < 1.1754942e-38) && (X > 0)) || ((X > -1.1754942e-38) && (X < 0))) begin
            exp_X = 8'h00;
            frac_X = 23'b0;
        end

        // Hacer lo de arriba pero con Y
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

        if (mul_frac[47] == 1) begin
            mul_frac = mul_frac >> 1;
            exp_Z = exp_Z + 1'b1;
        end

        else begin
            mul_frac = {mul_frac[46:1], 1'b0}; 
        end

        if (mul_frac[21:0] == 0) begin
            sticky = 1'b0;
        end

        else begin
            sticky = 1'b1;
        end
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
        
        frac_Z = Z[24:2];
        Z_aux = {sign_Z, exp_Z, frac_Z};

        //Casos Especiales

        if ((exp_X == 8'h00 && frac_X == 23'h000000) || (exp_Y == 8'h00 && frac_Y == 23'h000000)) begin //Multiplicacion por cero
            Z_aux = {sign_Z, 31'b0000_0000_0000_0000_0000_0000_0000_000};
        end

        else if ((exp_X == 8'hFF) || (exp_Y == 8'hFF)) begin 
            $display("Mjm");
            if ((frac_X != 0) || (frac_Y != 0)) begin // Multiplicacion por NaN
                Z_aux = {1'b0, 31'b1111_1111_1000_0000_0000_0000_0000_000}; //El DUT solo genera +NaN
            end

            else begin //Multiplicacion por infinito
                Z_aux = {sign_Z, 31'b1111_1111_0000_0000_0000_0000_0000_000};
            end

            //if (((item.frac_X == 23'h000000) || (item.frac_Y == 23'h000000)) && ((item.frac_X[22] != 1'b1) || (item.frac_Y[22] != 1'b1))) begin //Multiplicacion por infinito
                //Z_aux = {sign_Z, 31'b1111_1111_0000_0000_0000_0000_0000_000};
                //$display("Estamos en mul infinito mi gente");
                //$display("fracx:%0b, fracy:%0b", item.frac_X, item.frac_Y);
            //end

            //else if (((item.frac_X != 23'h000000) || (item.frac_Y != 23'h000000)) && ((item.frac_X[22] == 1'b1) || (item.frac_Y[22] == 1'b1))) begin //Multiplicacion por NaN
                //Z_aux = {1'b0, 31'b1111_1111_1000_0000_0000_0000_0000_000}; //El DUT solo genera +NaN
                //$display("Estamos en mul NaN mi gente");
            //end
        end

        // Separar esto en otro if/else
        if (exp_X+exp_Y >= 382) begin //Overflow 
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

        $fwrite(archivo_csv, "[%-10t] %-6b %-14g %-14g %-16g %-16g %-15b %-15b %-15b %-15b\n", 
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

        if (Z_aux != item.fp_Z) begin //TODO Evaluar caso NaN == -NaN // This seems to be fixed
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
