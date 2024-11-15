class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //TODO Definir variables que seran usadas para el checkeo

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

    uvm_analysis_imp #(Item, scoreboard) m_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        m_analysis_imp = new("m_analysis_imp", this);
    endfunction

    virtual function write(Item item);

        //Definicion de Valores de X y Y
        /*sign_X = item.fp_X[31];
        sign_Y = item.fp_Y[31];

        exp_X = item.fp_X[30:23];
        exp_Y = item.fp_Y[30:23];

        frac_X = item.fp_X[22:0];
        frac_Y = item.fp_Y[22:0];*/

        sign_X = item.sign_X;
        sign_Y = item.sign_Y;

        exp_X = item.exp_X;
        exp_Y = item.exp_Y;

        frac_X = item.frac_X;
        frac_Y = item.frac_Y;

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
        
        Z = {mul_frac[47:22], (mul_frac[23] | sticky)};

        //Casos de Redondeo
        case(item.r_mode)
            3'b000: begin
                $display("Hola");
            end

            3'b001: begin 
                Z = Z;
            end

            3'b010: begin
                $display("Hola");
            end

            3'b011: begin
                $display("Hola");
            end

            3'b100: begin
                $display("Hola");
            end    
        endcase
        
        frac_Z = Z[24:2];
        Z_aux = {sign_Z, exp_Z, frac_Z};

        //Casos Especiales

        if ((exp_X == 8'h00 && frac_X == 23'h000000) || (exp_Y == 8'h00 && frac_Y == 23'h000000)) begin //Multiplicacion por cero
            Z_aux = 32'h00000000;
        end

        else if ((exp_X == 8'hFF) || (exp_Y == 8'hFF)) begin 
            if ((frac_X == 23'h800000) || (frac_Y == 23'h800000)) begin //Multiplicacion de un NaN
                Z_aux = {sign_Z, 31'b1111_1111_1000_0000_0000_0000_0000_000};
            end

            else if ((frac_X == 23'h000000) || (frac_Y == 23'h000000)) begin //Multiplicacion por infinito
                Z_aux = {sign_Z, 31'b1111_1111_0000_0000_0000_0000_0000_000};
            end

            else begin
                Z_aux = Z_aux;  
            end
        end

        else begin 
            Z_aux = Z_aux;
        end

    

        if (Z_aux != item.fp_Z) begin 
            `uvm_error("SCBD", $sformatf("ERROR Z recibido = %0g Z esperado = %0g", $bitstoshortreal(item.fp_Z), $bitstoshortreal(Z_aux)))
        end

        else begin
            `uvm_info("SCBD", $sformatf("CORRECTO Z recibido = %0g Z esperado = %0g", $bitstoshortreal(item.fp_Z), $bitstoshortreal(Z_aux)), UVM_LOW)
        end
        
        

        `uvm_info("SCBD", $sformatf("r mode=%0d X=%g Y=%g Z=%g Overflow=%b Underflow=%b",
            item.r_mode, $bitstoshortreal({item.sign_X, item.exp_X, item.frac_X}), $bitstoshortreal({item.sign_Y, item.exp_Y, item.frac_Y}), $bitstoshortreal(item.fp_Z), item.ovrf, item.udrf), UVM_LOW)
    endfunction
endclass

