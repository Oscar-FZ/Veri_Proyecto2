class agent extends uvm_agent;
    // Macro para registrar la clase en la fábrica
    `uvm_component_utils(agent)

    // Constructor de la clase "agent"
    function new(string name = "agent", uvm_component parent = null);
        super.new(name, parent); // Llama al constructor de la clase base
    endfunction

    // Declaración de componentes internos del agente
    driver d0;                       // Instancia del driver
    monitor m0;                      // Instancia del monitor
    uvm_sequencer #(Item) s0;        // Secuenciador parametrizado con la clase "Item"

    // Función para construir los componentes del agente
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase); // Llama al build_phase de la clase base

        // Crea el secuenciador utilizando el factory UVM
        s0 = uvm_sequencer #(Item)::type_id::create("s0", this);

        // Crea el controlador utilizando el factory UVM
        d0 = driver::type_id::create("d0", this);

        // Crea el monitor utilizando el factory UVM
        m0 = monitor::type_id::create("m0", this);
    endfunction

    // Función para conectar los puertos entre los componentes
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase); // Llama al connect_phase de la clase base

        // Conecta el puerto "seq_item_port" del controlador al
        // exportador "seq_item_export" del secuenciador
        d0.seq_item_port.connect(s0.seq_item_export);
    endfunction
endclass