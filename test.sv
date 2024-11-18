class base_test extends uvm_test;
    // Macro para registrar la clase en la fábrica UVM
    `uvm_component_utils(base_test)

    // Constructor de la clase "base_test"
    function new(string name = "base_test", uvm_component parent = null);
        super.new(name, parent); // Llama al constructor de la clase base
    endfunction

    // Instancia del entorno de verificación
    env e0;
    
    // Instancia de la secuencia de generación de ítems
    gen_item_seq seq;
    
    // Interfaz virtual para las señales del DUT
    virtual fpmul_if vif;

    // Fase de construcción de los componentes
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase); // Llama al build_phase de la clase base

        // Crea la instancia del entorno "e0"
        e0 = env::type_id::create("e0", this);

        // Obtiene la referencia de la interfaz virtual desde la base de datos de configuración
        if (!uvm_config_db#(virtual fpmul_if)::get(this, "", "fpmul_if", vif))
            `uvm_fatal("TEST", "Did not get vif") // Lanza un error fatal si no encuentra la interfaz

        // Configura la interfaz para los componentes del entorno
        uvm_config_db#(virtual fpmul_if)::set(this, "e0.a0.*", "fpmul_if", vif);
        
        // Crea y aleatoriza la secuencia de ítems
        seq = gen_item_seq::type_id::create("seq");
        seq.randomize();
    endfunction

    // Fase de ejecución de la prueba
    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this); // Lanza una objeción para mantener la simulación activa
        apply_reset(); // Aplica el reset al DUT
        seq.start(e0.a0.s0); // Inicia la secuencia de ítems
        #200; // Espera 200 unidades de tiempo
        phase.drop_objection(this); // Libera la objeción para finalizar la simulación
    endtask

    // Tarea para aplicar el reset al DUT
    virtual task apply_reset();
        // Inicializa las señales de reset
        vif.rstn <= 0;
        vif.r_mode <= 0;
        vif.fp_X <= 0;
        vif.fp_Y <= 0;
        // Mantiene el reset durante 5 ciclos de reloj
        repeat(5) @(posedge vif.clk);
        vif.rstn <= 1; // Levanta el reset
        // Espera 10 ciclos de reloj después del reset
        repeat(10) @(posedge vif.clk);
    endtask
endclass

class test_fpmul extends base_test;
    // Macro para registrar la clase en la fábrica UVM
    `uvm_component_utils(test_fpmul)

    // Constructor de la clase "test_fpmul"
    function new(string name = "test_fpmul", uvm_component parent = null);
        super.new(name, parent); // Llama al constructor de la clase base
    endfunction

    // Fase de construcción de la prueba
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase); // Llama al build_phase de la clase base
        // Aleatoriza la secuencia con un rango de valores para "num"
        seq.randomize() with {num inside {[50: 80]};};
        seq.test = 1; // Establece el valor de "test"
    endfunction
endclass

class test_ident extends base_test;
    // Macro para registrar la clase en la fábrica UVM
    `uvm_component_utils(test_ident)

    // Constructor de la clase "test_ident"
    function new (string name = "test_ident", uvm_component parent = null);
        super.new(name, parent); // Llama al constructor de la clase base
    endfunction

    // Fase de construcción de la prueba
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase); // Llama al build_phase de la clase base
        seq.randomize(); // Aleatoriza la secuencia
        seq.c_ident = 1; // Establece el valor de "c_ident"
    endfunction
endclass

class test_cero extends base_test;
    // Macro para registrar la clase en la fábrica UVM
    `uvm_component_utils(test_cero)

    // Constructor de la clase "test_cero"
    function new (string name = "test_cero", uvm_component parent = null);
        super.new(name, parent); // Llama al constructor de la clase base
    endfunction

    // Fase de construcción de la prueba
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase); // Llama al build_phase de la clase base
        seq.randomize(); // Aleatoriza la secuencia
        seq.c_cero = 1; // Establece el valor de "c_cero"
    endfunction
endclass

class test_numxinf extends base_test;
    // Macro para registrar la clase en la fábrica UVM
    `uvm_component_utils(test_numxinf)

    // Constructor de la clase "test_numxinf"
    function new (string name = "test_numxinf", uvm_component parent = null);
        super.new(name, parent); // Llama al constructor de la clase base
    endfunction

    // Fase de construcción de la prueba
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase); // Llama al build_phase de la clase base
        seq.randomize(); // Aleatoriza la secuencia
        seq.c_nxi = 1; // Establece el valor de "c_nxi"
    endfunction
endclass

class test_nan extends base_test;
    // Macro para registrar la clase en la fábrica UVM
    `uvm_component_utils(test_nan)

    // Constructor de la clase "test_nan"
    function new (string name = "test_nan", uvm_component parent = null);
        super.new(name, parent); // Llama al constructor de la clase base
    endfunction

    // Fase de construcción de la prueba
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase); // Llama al build_phase de la clase base
        seq.randomize(); // Aleatoriza la secuencia
        seq.c_nan = 1; // Establece el valor de "c_nan"
    endfunction
endclass

class test_ovrf extends base_test;
    // Macro para registrar la clase en la fábrica UVM
    `uvm_component_utils(test_ovrf)

    // Constructor de la clase "test_ovrf"
    function new (string name = "test_ovrf", uvm_component parent = null);
        super.new(name, parent); // Llama al constructor de la clase base
    endfunction

    // Fase de construcción de la prueba
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase); // Llama al build_phase de la clase base
        seq.randomize(); // Aleatoriza la secuencia
        seq.c_ovrf = 1; // Establece el valor de "c_ovrf"
    endfunction
endclass

class test_udrf extends base_test;
    // Macro para registrar la clase en la fábrica UVM
    `uvm_component_utils(test_udrf)

    // Constructor de la clase "test_udrf"
    function new (string name = "test_udrf", uvm_component parent = null);
        super.new(name, parent); // Llama al constructor de la clase base
    endfunction

    // Fase de construcción de la prueba
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase); // Llama al build_phase de la clase base
        seq.randomize(); // Aleatoriza la secuencia
        seq.c_udrf = 1; // Establece el valor de "c_udrf"
    endfunction
endclass