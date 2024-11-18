class base_test extends uvm_test;
    `uvm_component_utils(base_test) // Registra la clase en la fabrica

    // Constructor de la clase
    function new(string name = "base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    env e0;               // Instancia del entorno de verificacion
    gen_item_seq seq;     // Instancia de la secuencia
    virtual fpmul_if vif; // Instancia de la interfaz virtual

    // Construccion de los componentes
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        e0 = env::type_id::create("e0", this); // Crea la instancia del entorno

        if (!uvm_config_db#(virtual fpmul_if)::get(this, "", "fpmul_if", vif))
            `uvm_fatal("TEST", "Did not get vif") // Error si no se encuentra la interfaz

        uvm_config_db#(virtual fpmul_if)::set(this, "e0.a0.*", "fpmul_if", vif); // Configura la interfaz
        
        // Crea y aleatoriza la secuencia
        seq = gen_item_seq::type_id::create("seq");
        seq.randomize();
    endfunction

    // Fase de corrida de la prueba
    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this); // Levanta la objecion para mantener la simulacion activa
        apply_reset(); // Reinicia el DUT
        seq.start(e0.a0.s0); // Inicia la secuencia de items
        #200; // Espera 200 unidades de tiempo
        phase.drop_objection(this); // Baja la objecion y termina la simulacion
    endtask

    virtual task apply_reset(); //Reinicia el DUT
        vif.rstn <= 0;
        vif.r_mode <= 0;
        vif.fp_X <= 0;
        vif.fp_Y <= 0;
        repeat(5) @(posedge vif.clk); // Mantiene el reset por 5 ciclos
        vif.rstn <= 1;
        repeat(10) @(posedge vif.clk);
    endtask
endclass

class test_fpmul extends base_test;
    `uvm_component_utils(test_fpmul) // Registra la clase en la fabrica

    // Constructor de la clase
    function new(string name = "test_fpmul", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq.randomize() with {num inside {[50: 80]};}; //Aleatoriza la secuencia
    endfunction
endclass

class test_ident extends base_test;
    `uvm_component_utils(test_ident)

    function new (string name = "test_fpmul", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq.randomize();
        seq.c_ident = 1; // Establece el valor de c_ident
    endfunction
endclass

class test_cero extends base_test;
    `uvm_component_utils(test_cero)

    function new (string name = "test_cero", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq.randomize();
        seq.c_cero = 1;
    endfunction
endclass

class test_numxinf extends base_test;
    `uvm_component_utils(test_numxinf)

    function new (string name = "test_numxinf", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq.randomize();
        seq.c_nxi = 1;
    endfunction
endclass

class test_nan extends base_test;
    `uvm_component_utils(test_nan)

    function new (string name = "test_nan", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq.randomize();
        seq.c_nan = 1;
    endfunction
endclass

class test_ovrf extends base_test;
    `uvm_component_utils(test_ovrf)

    function new (string name = "test_ovrf", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq.randomize();
        seq.c_ovrf = 1;
    endfunction
endclass

class test_udrf extends base_test;
    `uvm_component_utils(test_udrf)

    function new (string name = "test_udrf", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq.randomize();
        seq.c_udrf = 1;
    endfunction
endclass