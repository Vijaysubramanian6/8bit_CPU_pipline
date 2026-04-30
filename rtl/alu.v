module alu(
    input [7:0] A,
    input [7:0] B,

    input [2:0] alu_op, // operation alu perfroms

    output reg [7:0] result,
    output reg carry,
    output reg zero_flag
);




always @(*) begin 

    case(alu_op)
    3'b000: {carry,result} <= A+B;
    3'b001: {carry,result} <= A-B;
    3'b010: result <= A&B;
    3'b011: result <= A|B;
    3'b100: result <= A*B;
    3'b101: result <= ~(A);
    3'b110: result <= A<<1;
    3'b111: result <= A>>1;
    default: result  = 8'h00;

    endcase

    zero_flag = (result == 8'h00); // zero flag if result is 00

end 





endmodule 