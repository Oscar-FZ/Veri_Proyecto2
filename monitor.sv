class monitor extends uvm_monitor;
    `uvm_component_utils(monitor)

    function new(string name = "monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    uvm_analysis_port #(Item) mon_analysis_port;
    virtual fpmul_if vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual fpmul_if)::get(this, "", "fpmul_if", vif))
            `uvm_fatal("MON", "Could not get vif")
        mon_analysis_port = new("mon_analysis_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever begin
            @(vif.cb);
                if(vif.rstn) begin
                    Item item = Item::type_id::create("item");
                    //Item item = new;
                    item.r_mode = vif.r_mode;
                    item.sign_X = vif.fp_X[31];
                    item.exp_X = vif.fp_X[30:23];
                    item.frac_X = vif.fp_X[22:0];
                    item.sign_Y = vif.fp_Y[31];
                    item.exp_Y = vif.fp_Y[30:23];
                    item.frac_Y = vif.fp_Y[22:0];
                    
                    //item.fp_X = vif.fp_X;
                    //item.fp_Y = vif.fp_Y;
                    item.fp_Z = vif.fp_Z;
                    item.ovrf = vif.ovrf;
                    item.udrf = vif.udrf;
                    mon_analysis_port.write(item);
                    `uvm_info("MON", $sformatf("Saw item: %s", item.print()), UVM_HIGH)
               end
        end
    endtask
endclass
