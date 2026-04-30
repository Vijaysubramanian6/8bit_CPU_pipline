// program counter max address 8 bits (256) only 

module program_counter(
    input clk,
    input rst, // reset
    input en, // enable the pc
    input load, // jump enable 
    input [15:0]d_in, // address to jump at
    
    output reg [15:0] pc // output address to reach at 
);


always @(posedge clk or negedge rst) begin
    if(!rst) begin
        pc <= 16'h0000;
    end    

    else if (load) begin
        pc <= d_in; // jump
    end

    else if (en) begin
        
        if(pc == 255) begin  // limiting pc till 255
            pc <=0; 
        end

        else begin 
        pc <= pc+1; // next address
    end 
    end 

end 



endmodule 