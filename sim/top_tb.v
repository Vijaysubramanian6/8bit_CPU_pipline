`timescale 1ns/1ps
module top_tb();
    reg clk, rst;

    top_piplined uut (.clk(clk), .rst(rst));

    always #0.005 clk = ~clk;
	
    initial begin
        clk = 0; rst = 0;
        repeat(1) @(posedge clk);
         rst = 1; // Release reset
    #200 $finish;
    end

    initial begin
        $dumpfile("cpu_sim.vcd");
        $dumpvars(0, top_tb);
        // $monitor("Time: %0t | PC: %h | Instr: %h | Reg0: %h", $time, uut.pc, uut.instruction, uut.reg_file.registers[0]);
    end
endmodule
