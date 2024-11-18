class driver extends uvm_driver #(Item);
    // Macro para registrar la clase en la fábrica UVM
    `uvm_component_utils(driver)

    // Constructor de la clase "driver"
    // Inicializa la clase con un nombre predeterminado y un componente padre
    function new(string name = "driver", uvm_component parent = null);
        super.new(name, parent) // Llama al constructor de la clase base
    endfunction

    // Interfaz virtual utilizada para interactuar con el DUT
    virtual fpmul_if vif;

    // Función para construir los componentes del driver
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase) // Llama al build_phase de la clase base

        // Obtiene la referencia de la interfaz virtual desde la base de datos de configuración
        if(!uvm_config_db#(virtual fpmul_if)::get(this, "", "fpmul_if", vif))
            `uvm_fatal("DRV", "Could not get vif") // Lanza un error fatal si no encuentra la interfaz
    endfunction

    // Tarea para ejecutar el flujo principal del driver
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase) // Llama al run_phase de la clase base

        // Bucle infinito para manejar transacciones
        forever begin
            Item m_item; // Variable para almacenar la transacción recibida

            // Imprime un mensaje indicando que el driver está esperando un item del secuenciador
            `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_HIGH)

            // Espera y recibe la siguiente transacción desde el puerto del secuenciador
            seq_item_port.get_next_item(m_item);

            // Llama a la tarea para manejar la transacción recibida
            drive_item(m_item);

            // Notifica al secuenciador que el manejo de la transacción ha finalizado
            seq_item_port.item_done();
        end
    endtask

    // Tarea para manejar una transacción y conducirla hacia las señales del DUT
    virtual task drive_item(Item m_item);
        // Espera una señal de sincronización (callback) desde la interfaz virtual
        @(vif.cb);

        // Asigna los valores de la transacción a las señales del DUT
        vif.cb.r_mode <= m_item.r_mode;
        vif.cb.fp_X <= {m_item.sign_X, m_item.exp_X, m_item.frac_X};
        vif.cb.fp_Y <= {m_item.sign_Y, m_item.exp_Y, m_item.frac_Y};
    endtask
endclass
