class monitor extends uvm_monitor;
    // Macro para registrar la clase en la fábrica UVM
    `uvm_component_utils(monitor)

    // Constructor de la clase "monitor"
    // Inicializa la clase con un nombre predeterminado y un componente padre
    function new(string name = "monitor", uvm_component parent = null);
        super.new(name, parent) // Llama al constructor de la clase base
    endfunction

    // Puerto de análisis para enviar transacciones observadas hacia otros componentes
    uvm_analysis_port #(Item) mon_analysis_port;

    // Interfaz virtual para observar las señales del DUT
    virtual fpmul_if vif;

    // Variable para almacenar el último item observado
    Item item_anterior;

    // Función para construir los componentes del monitor
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase) // Llama al build_phase de la clase base

        // Obtiene la referencia de la interfaz virtual desde la base de datos de configuración
        if (!uvm_config_db#(virtual fpmul_if)::get(this, "", "fpmul_if", vif))
            `uvm_fatal("MON", "Could not get vif") // Lanza un error fatal si no encuentra la interfaz

        // Crea el puerto de análisis
        mon_analysis_port = new("mon_analysis_port", this)
    endfunction

    // Función para comparar dos items y determinar si son iguales
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
            )
    endfunction

    // Tarea para ejecutar el flujo principal del monitor
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase) // Llama al run_phase de la clase base

        // Bucle infinito para capturar y analizar transacciones
        forever begin
            @(vif.cb); // Espera una señal de sincronización (callback) desde la interfaz virtual

            if(vif.rstn) begin // Verifica que el DUT no esté en reset
                Item item = Item::type_id::create("item") // Crea un nuevo item utilizando la fábrica UVM

                // Captura las señales relevantes del DUT y las almacena en el item
                item.r_mode = vif.r_mode;
                item.sign_X = vif.fp_X[31];
                item.exp_X = vif.fp_X[30:23];
                item.frac_X = vif.fp_X[22:0];
                item.sign_Y = vif.fp_Y[31];
                item.exp_Y = vif.fp_Y[30:23];
                item.frac_Y = vif.fp_Y[22:0];
                item.fp_Z = vif.fp_Z;
                item.ovrf = vif.ovrf;
                item.udrf = vif.udrf;

                // Envía el item al puerto de análisis si es diferente del último observado
                if (item_anterior == null || !comparar_items(item, item_anterior)) begin
                    mon_analysis_port.write(item) // Escribe el item en el puerto de análisis
                    `uvm_info("MON", $sformatf("Saw item: %s", item.print()), UVM_HIGH) // Mensaje informativo
                    item_anterior = item // Actualiza el último item observado
                end
            end
        end
    endtask
endclass