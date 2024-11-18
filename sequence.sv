class gen_item_seq extends uvm_sequence;
    // Macro para registrar la clase en la fábrica UVM
    `uvm_object_utils(gen_item_seq)

    // Variables de control para los diferentes casos de prueba
    bit test;
    bit c_ident;
    bit c_cero;
    bit c_nxi;
    bit c_nan;
    bit c_ovrf;
    bit c_udrf;

    // Constructor de la secuencia de ítems
    function new (string name = "gen_item_seq");
        super.new(name); // Llama al constructor de la clase base
    endfunction

    // Variables aleatorias para controlar el número de ítems a generar y el retardo de envío
    rand int num;
    rand int retardo_envio;

    // Restricciones de aleatorización
    constraint c1 {soft num inside {[100:200]};} // Genera un número aleatorio entre 100 y 200 para "num"
    // constraint c2 {soft retardo_envio inside {[100:300]};} // (comentado) Genera un retardo aleatorio entre 100 y 300

    // Cuerpo de la secuencia
    virtual task body();
        // Genera "num" ítems
        for (int i = 0; i < num; i++) begin
            // Crea un nuevo ítem
            Item m_item = Item::type_id::create("m_item");

            // Asigna los valores de control de la secuencia al ítem
            m_item.test_s = test;
            m_item.c_ident = c_ident;
            m_item.c_cero = c_cero;
            m_item.c_nxi = c_nxi;
            m_item.c_nan = c_nan;
            m_item.c_ovrf = c_ovrf;
            m_item.c_udrf = c_udrf;

            // Aleatoriza el tiempo de retardo antes de enviar el ítem
            if (!this.randomize() with {retardo_envio inside {[100:300]};}) begin
                `uvm_error("SEQ", "Error al aleatorizar el tiempo de retraso") // Informa si no se puede aleatorizar
            end

            // Inicia el ítem para enviarlo al secuenciador
            start_item(m_item);
            // Aleatoriza el ítem antes de enviarlo
            m_item.randomize();
            `uvm_info("SEQ", $sformatf("Generate new item: "), UVM_HIGH)
            m_item.print(); // Imprime los detalles del ítem generado
            // Finaliza el envío del ítem al secuenciador
            finish_item(m_item);
            // Aplica el retardo antes de enviar el siguiente ítem
            #retardo_envio;
        end
        // Informa que se ha completado la generación de los ítems
        `uvm_info("SEQ", $sformatf("Done generation of %0d items", num), UVM_LOW)
    endtask
endclass


