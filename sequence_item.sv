class Item extends uvm_sequence_item;
    `uvm_object_utils(Item) // Registra la clase en la fabrica

    //Inputs
    rand bit [2:0] r_mode;          // Modo de redondeo
    rand bit sign_X, sign_Y;        // Signo de X y Y
    rand bit [7:0] exp_X, exp_Y;    // Exponente de X y Y
    rand bit [22:0] frac_X, frac_Y; // Fraccion de X y Y

    // Variables para el control de los constraints
    bit c_ident;
    bit c_cero;
    bit c_nxi;
    bit c_nan;
    bit c_ovrf;
    bit c_udrf;

    //Outputs
    bit [31:0] fp_Z; // Resultado de la multiplicacion
    bit ovrf, udrf;  // Overflow, Underflow

    // Funcion para imprimir el contenido del item
    virtual function string print();
        return $sformatf("fp_X = %h, fp_Y = %h, fp_Z = %h, R_mode = %h, Ovrf = %h, Udrf = %h", {sign_X, exp_X, frac_X}, {sign_Y, exp_Y, frac_Y}, fp_Z, r_mode, ovrf, udrf);
    endfunction

    // Constructor de la clase
    function new(string name = "Item");
        super.new(name);
    endfunction
    
    constraint c2 {r_mode inside{[0:4]};} // Restriccion para el r_mode

    // Restricciones para los casos de prueba
    // Se multiplican los valores generados aleatoriamente por 1
    constraint test_ident {
        if (c_ident) {
            sign_X dist {1'b0 := 50, 1'b1 := 50};
            exp_X dist {8'b01111111 := 50, [8'b0:8'b01111110] :/ 100};

            sign_Y dist {1'b0 := 50, 1'b1 := 50};
            exp_Y dist {8'b01111111 := 50, [8'b0:8'b01111110] :/ 100};

            if (exp_X == 8'b01111111) {
                frac_X == 23'b0;
                exp_Y != 8'b01111111;
            }

            else if (exp_X != 8'b01111111) {
                frac_Y == 23'b0;
                exp_Y == 8'b01111111;
            }
        }
    }

    // El valor de Y es 0
    constraint test_cero { 
        if (c_cero) {
            exp_Y dist {8'b00000000 := 50, [8'b0000_0001:8'b1111_1110] :/ 50};
            //exp_Y == 8'b0;
            frac_Y dist {23'b0 := 50, [23'h1:23'h7fffff] :/ 50};
            //frac_Y == 23'b0;

            exp_X dist {8'b00000000 := 50, [8'b0000_0001:8'b1111_1110] :/ 50};
            frac_X dist {23'b0 := 50, [23'h1:23'h7fffff] :/ 50};

            if (exp_Y == 8'b00000000) {
                frac_Y == 23'b0;
                exp_X != 8'b00000000;
            }

            if (exp_Y != 8'b00000000) {
                frac_X == 23'b0;
                exp_X == 8'b00000000;
            }
        }
    }

    // El valor de X es infinito
    constraint test_nxi { 
        if (c_nxi) {
            exp_X == 8'hFF;
            frac_X == 23'b0;
        }
    }

    // El valor de Y es NaN
    constraint test_nan {
        if (c_nan) {
            exp_Y == 8'hFF;
            frac_Y > 0;
        }
    }

    // ExpX + ExpY causa overflow
    constraint test_ovrf {
        if (c_ovrf) {
            exp_X >= 8'b10111111;
            exp_X < 8'hFF;
            exp_Y >= 8'b10111111;
            exp_Y < 8'hFF;
        }
    }

    // ExpX + ExpY causa underflow
    constraint test_udrf{
        if (c_udrf) {
            exp_X >= 0;
            exp_X <= 8'b00111111;
            exp_Y >= 0;
            exp_Y <= 8'b00111111;
        }
    }
    
endclass
