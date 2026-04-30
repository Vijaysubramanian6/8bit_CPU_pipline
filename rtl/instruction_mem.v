module instruction_mem(
    input [15:0] addr,
    output [15:0] ins_out
); 


reg [15:0] rom [255:0];

initial begin
    $readmemh("program.txt",rom);// loads the hex code
end

assign ins_out = rom[addr[7:0]]; // use the lower bit of pc




endmodule