class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //TODO Definir variables que seran usadas para el checkeo
    shortreal exp_result;

    uvm_analysis_imp #(Item, scoreboard) m_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        m_analysis_imp = new("m_analysis_imp", this);
    endfunction

    virtual function write(Item item);
        shortreal fp_X_float = $bitstoshortreal(item.fp_X);
        shortreal fp_Y_float = $bitstoshortreal(item.fp_Y);
        shortreal fp_Z_float = $bitstoshortreal(item.fp_Z);
        

        `uvm_info("SCBD", $sformatf("r mode=%0d X=%e Y=%e Z=%e Overflow=%b Underflow=%b",
            item.r_mode, fp_X_float, fp_Y_float, fp_Z_float, item.ovrf, item.udrf), UVM_LOW)
        
        //TODO Hacer checker
        
        if (fp_Z_float != exp_result) begin
            `uvm_error("SCBD", $sformatf("ERROR! fp_Z_float=%0e exp=%0e", fp_Z_float, exp_result))
        end
        
        
        
        case(item.r_mode) 
            3'b001: exp_result = fp_X_float * fp_Y_float;
            default: exp_result = 'bx;
        endcase

    endfunction
endclass

