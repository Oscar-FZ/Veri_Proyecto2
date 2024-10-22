class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //TODO Definir variables que seran usadas para el checkeo

    uvm_analysis_imp #(Item, scoreboard) m_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        m_analysis_imp = new("m_analysis_imp", this);
    endfunction

    virtual function write(Item item);
        `uvm_info("SCBD", $sformatf("r mode=%0d X=%0f Y=%0f Z=%0f Overflow=%b Underflow=%b",
            item.r_mode, item.fp_X, item.fp_Y, item.fp_Z, item.ovrf, item.udrf), UVM_LOW)
        
        //TODO Hacer checker

    endfunction
endclass

