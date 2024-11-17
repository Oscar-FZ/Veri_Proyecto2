class gen_item_seq extends uvm_sequence;
    `uvm_object_utils(gen_item_seq)

    bit test;

    function new (string name = "gen_item_seq");
        super.new(name);
    endfunction

    rand int num;
    rand int retardo_envio;

    constraint c1 {soft num inside {[50:100]};}
    //constraint c2 {soft retardo_envio inside {[100:300]};}

    virtual task body();
        if (test) begin
            $display("Test worked lmao");
        end

        for (int i = 0; i < num; i++) begin
            Item m_item = Item::type_id::create("m_item");
            m_item.test_s = test; // Control del sequence al sequence item

            if (!this.randomize() with {retardo_envio inside {[100:300]};}) begin
                `uvm_error("SEQ", "Error al aleatorizar el tiempo de retraso")
            end

            start_item(m_item);
            m_item.randomize();
            `uvm_info("SEQ", $sformatf("Generate new item: "), UVM_HIGH)
            m_item.print();
            finish_item(m_item);
            #retardo_envio;
            $display("retardo:%d", retardo_envio);
        end
        `uvm_info("SEQ", $sformatf("Done generation of %0d items", num), UVM_LOW)
    endtask
endclass


