class env extends uvm_env;
    `uvm_component_utils(env) // Registra la clase en la fabrica

    // Constructor de la clase
    function new(string name = "env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Declara los componentes del entorno
    agent a0;       // Instancia el ambiente
    scoreboard sb0; // Instancia el scoreboard

    // Construye los componentes del entorno
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a0 = agent::type_id::create("a0", this);
        sb0 = scoreboard::type_id::create("sb0", this);
    endfunction

    // Conecta los puertos entre los componentes
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        a0.m0.mon_analysis_port.connect(sb0.m_analysis_imp);
    endfunction
endclass
