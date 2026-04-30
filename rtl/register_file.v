module register_file( // planned to have 8 register in one register file
    input clk,
    input rst,
    input en_write, // enable to right to register ( 3 bit value to code for a reg)
    input [2:0] write_reg, // which address to be written to
    input [7:0] write_data, 
    
    // which reg to read data from 
    input [2:0] read_reg1, // read port1
    input [2:0] read_reg2, // read port2

    output [7:0] read_data1,
    output [7:0] read_data2
);


// create 8 register  8 bit
reg [7:0] registers [7:0]; 


// asynchronous read  why ?
assign read_data1 = registers[read_reg1];
assign read_data2 = registers[read_reg2];


// now take care of rst and read 

integer i;
always @(posedge clk or negedge rst) begin

    if(!rst) begin
        for(i =0; i<8; i = i+1)begin
            registers[i] <= 8'h00; // clearing all the registers
        end 
    end 

    else if(en_write) begin
        registers[write_reg] <= write_data;

    end

end 






endmodule