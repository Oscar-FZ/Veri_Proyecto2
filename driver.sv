class driver extends uvm_driver #(Item);
    `uvm_component_utils(driver) //Registra la clase en la fabrica

    // Constructor de la clase
    function new(string name = "driver", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    virtual fpmul_if vif; // Interfaz virtual para interactuar con el dut

    // Construye los componentes del driver
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual fpmul_if)::get(this, "", "fpmul_if", vif))
            `uvm_fatal("DRV", "Could not get vif") // Error si no encuentra la interfaz
    endfunction

    // Empieza a correr el driver
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        // Bucle infinito
        forever begin
            Item m_item;
            `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_HIGH)
            seq_item_port.get_next_item(m_item); // Espera la transaccion
            drive_item(m_item);                  // Envia la transaccion
            seq_item_port.item_done();           // Finaliza la transaccion
        end
    endtask

    // Envía la transacción a las entradas del dut
    virtual task drive_item(Item m_item);
        @(vif.cb); // Usa el reloj como sincronizacion
            #(m_item.delay); // Aplica el retardo aleatorio entre transacciones
            vif.cb.r_mode <= m_item.r_mode;
            vif.cb.fp_X <= {m_item.sign_X, m_item.exp_X, m_item.frac_X};
            vif.cb.fp_Y <= {m_item.sign_Y, m_item.exp_Y, m_item.frac_Y};
    endtask
endclass
