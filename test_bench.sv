import uvm_pkg::*; // Importa la biblioteca UVM para utilizar los componentes y macros de UVM
`include "uvm_macros.svh" // Incluye las macros de UVM
`include "multiplicador_32_bits_FP_IEEE.sv" // Incluye el archivo con el modelo del multiplicador de 32 bits en formato IEEE FP
`include "interface.sv" // Incluye la interfaz que conecta el banco de pruebas con el DUT
`include "sequence_item.sv" // Incluye el archivo que define el tipo de transacción (sequence item)
`include "sequence.sv" // Incluye el archivo que define la secuencia de prueba
`include "monitor.sv" // Incluye el archivo que define el monitor para observar el DUT
`include "driver.sv" // Incluye el archivo que define el driver que maneja las transacciones
`include "scoreboard.sv" // Incluye el archivo que define el scoreboard para verificar la corrección de los resultados
`include "agent.sv" // Incluye el archivo que define el agente UVM, que agrupa driver, monitor y secuenciador
`include "ambiente.sv" // Incluye el archivo que define el entorno de verificación que contiene todos los agentes
`include "test.sv" // Incluye el archivo que define el banco de pruebas UVM

module tb; 
    reg clk; // Señal de reloj para el DUT

    // Generación del reloj, invierte cada 10 unidades de tiempo
    always #10 clk =~ clk;

    // Instancia de la interfaz para el DUT, con el reloj como señal de sincronización
    fpmul_if _if(clk);

    // Instancia del DUT (Device Under Test), conectando las señales del DUT a la interfaz
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
        // Inicializa la señal de reloj en 0
        clk <= 0;

        // Configura la interfaz virtual en la base de datos de configuración de UVM
        uvm_config_db#(virtual fpmul_if)::set(null, "uvm_test_top", "fpmul_if", _if);

        // Llama a la función para ejecutar la prueba UVM
        run_test(); // Para pasarle el nombre desde la consola
    end
endmodule
