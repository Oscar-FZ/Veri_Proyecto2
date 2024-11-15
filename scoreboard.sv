class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //TODO Definir variables que seran usadas para el checkeo
    shortreal exp_result;
    // Variables para la simulacion
    // Signo
    bit fp_X_sign;
    bit fp_Y_sign;
    bit result_sign;

    // Exponente
    bit [7:0] fp_X_exp;
    bit [7:0] fp_Y_exp;
    bit [7:0] exp_Z;

    // Fraccion
    bit [22:0] fp_X_frac;
    bit [22:0] fp_Y_frac;
    bit [47:0] frc_Z_full;

    // Normalizador
    bit norm_n;
    bit [25:0] frc_Z_norm;
    bit sticky_bit;
    bit [47:0] frc_Z_mux;
    bit [26:0] frc_Z_norm_o;

    // Redondeador
    bit [22:0] frc_Z;
    bit [23:0] Z_data;
    bit [23:0] Z_data_p;
    bit round_bit;
    bit guardVsticky;
    bit norm_r;

    // Exponente
    bit [7:0] fp_X_exp;
    bit [7:0] fp_Y_exp;
    bit [7:0] exp_Z;
    bit norm;
    bit [8:0] status;
    bit underflow;
    bit overflow;

    uvm_analysis_imp #(Item, scoreboard) m_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        m_analysis_imp = new("m_analysis_imp", this);
    endfunction

    virtual function write(Item item);
        shortreal fp_X_float = $bitstoshortreal(item.fp_X);
        shortreal fp_Y_float = $bitstoshortreal(item.fp_Y);
        shortreal fp_Z_float = $bitstoshortreal(item.fp_Z);

        // Variables para simular la multiplicacion en punto flotante
        // Para determinar el signo
        fp_X_sign = item.fp_X[31];
        fp_Y_sign = item.fp_Y[31];

        // Para calcular el exponente
        fp_X_exp = item.fp_X[30:23];
        fp_Y_exp = item.fp_Y[30:23];

        // Para hacer la multiplicacion fraccional
        fp_X_frac = item.fp_X[22:0];
        fp_Y_frac = item.fp_Y[22:0];

        `uvm_info("SCBD", $sformatf("r mode=%0d X=%e Y=%e Z=%e Overflow=%b Underflow=%b", 
        item.r_mode, fp_X_float, fp_Y_float, fp_Z_float, item.ovrf, item.udrf), UVM_LOW)
        
        //TODO Hacer checker
        
        // 1. Determinar el signo
        result_sign = fp_X_sign ^ fp_Y_sign;
        //`uvm_info("SCBD", $sformatf("result_sign=%b", result_sign), UVM_LOW) // Seems to be working

        // 2. Determinar el exponente 
        //exp_Z = ((fp_X_exp + fp_Y_exp) - 127);
        //`uvm_info("SCBD", $sformatf("Exponente=%b", exp_Z), UVM_LOW) // Seems to be working

        // 3. Multiplicador fraccional
        frc_Z_full = {1'b1, fp_X_frac} * {1'b1, fp_Y_frac};
        //`uvm_info("SCBD", $sformatf("Mul frac=%b", frc_Z_full), UVM_LOW) // Seems to be working

        // 4. Normalizador
        norm_n = frc_Z_full[47]; //Esto se ocupa para otra cosa despues

        if (norm_n == 1) begin
            frc_Z_mux = frc_Z_full;
        end
        else begin
            frc_Z_mux = {frc_Z_full[46:0], 1'b0};
        end

        frc_Z_norm = frc_Z_mux[47:22];

        if (frc_Z_mux[21:0] == 0) begin
            sticky_bit = 0;
        end
        else begin
            sticky_bit = 1;
        end

        frc_Z_norm_o = {frc_Z_norm, sticky_bit};
        //`uvm_info("SCBD", $sformatf("frc_Z_norm_o=%b", frc_Z_norm_o), UVM_LOW) // Seems to be working

        // 5. Rounder I'm making a mess out of this BTW
        // Separar los bits en componentes
        Z_data = frc_Z_norm_o[26:3];
        Z_data_p = Z_data + 1;
        round_bit = frc_Z_norm_o[2];
        guardVsticky = (frc_Z_norm_o[1] | frc_Z_norm_o[0]);

        // Analizar Z_data_p para ver si va a ocurrir un overflow
        if (Z_data == 24'b1) begin
            norm_r = 1'b1;
            Z_data_p = Z_data_p >> 1;
            Z_data_p = Z_data_p[22:0];
        end
        else begin
            norm_r = 1'b0;
            Z_data_p = Z_data_p;
        end

        case (item.r_mode)
            3'b000: begin
                if (round_bit == 0) begin
                    frc_Z = Z_data;
                end
                else if (round_bit && guardVsticky == 1) begin
                    frc_Z = Z_data_p;
                end
                else if (round_bit == 1 & guardVsticky == 0) begin
                    if (Z_data[0] == 0) begin
                        frc_Z = Z_data;
                    end
                    else begin
                        frc_Z = Z_data_p;
                    end
                end
            end

            3'b001: begin
                frc_Z = Z_data;
            end

            3'b010: begin
                if (result_sign == 0) begin
                    frc_Z = Z_data;
                end
                else begin
                    frc_Z = Z_data_p;
                end
            end

            3'b011: begin
                if (result_sign == 1) begin
                    frc_Z = Z_data;
                end
                else begin
                    frc_Z = Z_data_p;
                end
            end

            3'b100: begin
                if (round_bit == 0) begin
                    frc_Z = Z_data;
                end
                else begin
                    frc_Z = Z_data_p;
                end
            end

            default: begin
                frc_Z = 'bx;
            end
        endcase
    
        //`uvm_info("SCBD", $sformatf("fraccion=%h", frc_Z), UVM_LOW) // Seems to be working

        //Biased exponent adder
        // Check for over/underflow

        norm = (norm_n | norm_r);
        if (norm == 0) begin
            exp_Z = ((fp_X_exp + fp_Y_exp) - 127);
            if (fp_X_exp + fp_Y_exp <= 127) begin
                underflow = 1;
                overflow = 0;
            end
            else if (fp_X_exp + fp_Y_exp >= 255 + 127) begin
                overflow = 1;
                underflow = 0;
            end
            else begin
                underflow = 0;
                overflow = 0;
            end
        end
        else begin
            exp_Z = ((fp_X_exp + fp_Y_exp) - 126);
            if (fp_X_exp + fp_Y_exp <= 126) begin
                underflow = 1;
                overflow = 0;
            end
            else if (fp_X_exp + fp_Y_exp >= 255 + 126) begin
                overflow = 1;
                underflow = 0;
            end
            else begin
                underflow = 0;
                overflow = 0;
            end
        end
        `uvm_info("SCBD", $sformatf("norm=%b, underflow=%b, overflow=%b", norm, underflow, overflow), UVM_LOW) // Seems to be working

    endfunction
endclass

