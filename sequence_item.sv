class Item extends uvm_sequence_item;
    `uvm_object_utils(Item)

    //Inputs
    rand bit [2:0] r_mode;
    rand bit sign_X, sign_Y;
    rand bit [7:0] exp_X, exp_Y;
    rand bit [22:0] frac_X, frac_Y;
    //bit [31:0] fp_X, fp_Y;

    bit test_s;

    //fp_X = {sign_X, exp_X, frac_X};
    //fp_Y = {sign_Y, exp_Y, frac_Y};
    //Outputs
    bit [31:0] fp_Z;
    bit ovrf, udrf;

    //Registro de los atributos para usar las funciones de los macros de campo
    /*`uvm_object_utils_begin(Item)
        `uvm_field_int (r_mode, UVM_DEFAULT)
        `uvm_field_int (fp_X, UVM_DEFAULT)
        `uvm_field_int (fp_Y, UVM_DEFAULT)
        `uvm_field_int (fp_Z, UVM_DEFAULT)
        `uvm_field_int (ovrf, UVM_DEFAULT)
        `uvm_field_int (udrf, UVM_DEFAULT)
    `uvm_object_utils_end*/

    if (test_s) begin
        $display("It keeps working, lol");
    end

    virtual function string print();
        return $sformatf("fp_X = %h, fp_Y = %h, fp_Z = %h, R_mode = %h, Ovrf = %h, Udrf = %h", {sign_X, exp_X, frac_X}, {sign_Y, exp_Y, frac_Y}, fp_Z, r_mode, ovrf, udrf);
    endfunction

    //Funcion constructora
    function new(string name = "Item");
        super.new(name);
    endfunction

    //Constraints
    //TODO No se como aleatorizar datos punto flotante xd
    //constraint c1 {(exp_X + exp_Y - 127) < 128;
    //                (exp_X + exp_Y -127) > -126;
    //                solve exp_X before exp_Y;}
    //constraint c1 {(exp_X + exp_Y - 127) > 128;}
    constraint c2 {r_mode inside{[0:4]};}
endclass
