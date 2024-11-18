// Importa los archivos de UVM y del entorno desarrollado
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "multiplicador_32_bits_FP_IEEE.sv"
`include "interface.sv"
`include "sequence_item.sv"
`include "sequence.sv"
`include "monitor.sv"
`include "driver.sv"
`include "scoreboard.sv"
`include "agent.sv"
`include "ambiente.sv"
`include "test.sv"
module tb; 
    reg clk; // Reloj para el dut

    always #10 clk =~ clk; // Genera la sennal de reloj
    fpmul_if _if(clk); // Instancia la interfaz con el reloj

    top u0 
    (
        .clk(clk),
        .r_mode(_if.r_mode),
        .fp_X(_if.fp_X),
        .fp_Y(_if.fp_Y),
        .fp_Z(_if.fp_Z),
        .ovrf(_if.ovrf),
        .udrf(_if.udrf)
    );

    initial begin
        clk <= 0; // Inicializa la sennal del reloj
        uvm_config_db#(virtual fpmul_if)::set(null, "uvm_test_top", "fpmul_if", _if); // Configura la interfaz virtual en el configdb
        run_test(); // Para pasarle el nombre desde la consola
    end
endmodule
