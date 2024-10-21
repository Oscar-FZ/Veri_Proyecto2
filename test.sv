class base_test extends uvm_test;
    `uvm_component_utils(base_test)

    function new(string name = "base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    env e0;
    gen_item_seq seq;
    virtual fpmul_if vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        e0 = env::type_id::create("e0", this);

        if (!uvm_config_db#(virtual fpmul_if)::get(this, "", "fpmul_if", vif))
            `uvm_fatal("TEST", "Did not get vif")
        uvm_config_db#(virtual fpmul_if)::set(this, "e0.a0.*", "fpmul_if", vif);
        
        seq = gen_item_seq::type_id::create("seq");
        seq.randomize();
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        apply_reset();
        seq.start(e0.a0.s0);
        #200;
        phase.drop_objection(this);
    endtask

    virtual task apply_reset();
        vif.rstn <= 0;
        vif.r_mode <= 0;
        vif.fp_X <= 0;
        vif.fp_Y <= 0;
        repeat(5) @(posedge vif.clk);
        vif.rstn <= 1;
        repeat(10) @(posedge vif.clk);
    endtask
endclass

class test_fpmul extends base_test;
    `uvm_component_utils(test_fpmul)

    function new(string name = "test_fpmul", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq.randomize() with {num inside {[12: 22]};};
    endfunction
endclass

