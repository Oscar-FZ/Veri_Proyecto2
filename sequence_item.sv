class Item extends uvm_sequence_item;
    //`uvm_object_utils(Item)

    //Inputs
    rand bit [2:0] r_mode;
    rand bit [31:0] fp_X, fp_Y;
    //Outputs
    bit [31:0] fp_Z;
    bit ovrf, udrf;

    //Registro de los atributos para usar las funciones de los macros de campo
    `uvm_object_utils_begin(Item)
        `uvm_field_int (r_mode, UVM_DEFAULT)
        `uvm_field_int (fp_X, UVM_DEFAULT)
        `uvm_field_int (fp_Y, UVM_DEFAULT)
        `uvm_field_int (fp_Z, UVM_DEFAULT)
        `uvm_field_int (ovrf, UVM_DEFAULT)
        `uvm_field_int (udrf, UVM_DEFAULT)
    `uvm_object_utils_end

    //Funcion constructora
    function new(string name = "Item");
        super.new(name);
    endfunction

    //Constraints
    //TODO No se como aleatorizar datos punto flotante xd
    constraint c2 {r_mode inside{[0:4]};}
endclass
