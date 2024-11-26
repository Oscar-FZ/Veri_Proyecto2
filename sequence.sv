class gen_item_seq extends uvm_sequence;
    `uvm_object_utils(gen_item_seq) //Registra la clase en la fabrica

    // Variables de control para los casos de prueba
    bit c_ident;
    bit c_cero;
    bit c_nxi;
    bit c_nan;
    bit c_ovrf;
    bit c_udrf;

    // Constructor de la clase
    function new (string name = "gen_item_seq");
        super.new(name);
    endfunction

    // Variables para aleatorizar el numero de items y el retardo en el envio
    rand int num;

    constraint c1 {soft num inside {[100:200]};} // Constraint del numero de pruebas

    virtual task body();
        for (int i = 0; i < num; i++) begin // Genera num items
            Item m_item = Item::type_id::create("m_item"); // Crea un nuevo item
            // Asigna los valores de control 
            m_item.c_ident = c_ident;
            m_item.c_cero = c_cero;
            m_item.c_nxi = c_nxi;
            m_item.c_nan = c_nan;
            m_item.c_ovrf = c_ovrf;
            m_item.c_udrf = c_udrf;

            start_item(m_item); // Inicia el item para enviarlo al secuenciador
            m_item.randomize(); // Aleatoriza el item
            `uvm_info("SEQ", $sformatf("Generate new item: "), UVM_HIGH)
            m_item.print();
            finish_item(m_item); // Finaliza el item
        end
        `uvm_info("SEQ", $sformatf("Done generation of %0d items", num), UVM_LOW)
    endtask
endclass


