class env extends uvm_env;
    // Macro para registrar la clase en la fábrica UVM
    `uvm_component_utils(env)

    // Constructor de la clase "env"
    // Inicializa la clase con un nombre predeterminado y un componente padre
    function new(string name = "env", uvm_component parent = null);
    super.new(name, parent) // Llama al constructor de la clase base
    endfunction

    // Declaración de componentes del entorno
    agent a0;         // Instancia del agente
    scoreboard sb0;   // Instancia del scoreboard

    // Función para construir los componentes del entorno
    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase) // Llama al build_phase de la clase base

    // Crea la instancia del agente utilizando la fábrica UVM
    a0 = agent::type_id::create("a0", this)

    // Crea la instancia del scoreboard utilizando la fábrica UVM
    sb0 = scoreboard::type_id::create("sb0", this)
    endfunction

    // Función para conectar los puertos entre los componentes
    virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase) // Llama al connect_phase de la clase base

    // Conecta el puerto de análisis del monitor del agente al
    // puerto de análisis del scoreboard
    a0.m0.mon_analysis_port.connect(sb0.m_analysis_imp)
    endfunction
endclass
