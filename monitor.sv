class monitor extends uvm_monitor;
    `uvm_component_utils(monitor)

    function new(string name = "monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    uvm_analysis_port #(Item) mon_analysis_port;
    virtual fpmul_if vif;

    Item item_anterior;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual fpmul_if)::get(this, "", "fpmul_if", vif))
            `uvm_fatal("MON", "Could not get vif")
        mon_analysis_port = new("mon_analysis_port", this);
    endfunction

    function bit comparar_items (Item actual, Item anterior);
        return (actual.r_mode == anterior.r_mode &&
                actual.sign_X == anterior.sign_X &&
                actual.exp_X == anterior.exp_X &&
                actual.frac_X == anterior.frac_X &&
                actual.sign_Y == anterior.sign_Y &&
                actual.exp_Y == anterior.exp_Y &&
                actual.frac_Y == anterior.frac_Y &&
                actual.fp_Z == anterior.fp_Z &&
                actual.ovrf == anterior.ovrf &&
                actual.udrf == anterior.udrf
            );
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever begin
            @(vif.cb);
                if(vif.rstn) begin
                    Item item = Item::type_id::create("item");
                    //Item item = new;/
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

                    if (item_anterior == null || !comparar_items(item, item_anterior)) begin
                        mon_analysis_port.write(item);
                        `uvm_info("MON", $sformatf("Saw item: %s", item.print()), UVM_HIGH)
                        item_anterior = item;
                    end
               end
        end
    endtask
endclass
