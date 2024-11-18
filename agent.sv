class agent extends uvm_agent;
    `uvm_component_utils(agent) // Registra la clase en la fabrica

    //Constructor de la clase
    function new(string name = "agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //Declaracion de los componentes internos
    driver d0;                // Instancia del driver
    monitor m0;               // Instancia del monitor
    uvm_sequencer #(Item) s0; // Instancia del secuenciador

    // Construye los componentes del agente usando la fabrica
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        s0 = uvm_sequencer #(Item)::type_id::create("s0", this);
        d0 = driver::type_id::create("d0", this);
        m0 = monitor::type_id::create("m0", this);
    endfunction

    // Conecta los puertos entre los componentes
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        d0.seq_item_port.connect(s0.seq_item_export);
    endfunction
endclass


