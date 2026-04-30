module control_unit(

    input [15:0] instr,
    input status_z,

    // now this control unit, based on input generates 
    // all the values of the signals to all the other modules 

    output reg [2:0] reg_sel_a,
    output reg [2:0] reg_sel_b, // to register file reading register number
    output reg en_write, // to register file write enable

    output reg [2:0] write_reg, // register choosen to be written in the register file
    output reg [2:0] alu_op,

    output reg [15:0] data_in, // jump address to program counter
    output reg [7:0] addr, // address to be read from memeory 

    output reg en, // enable to pc
    output reg load, // pc for jump commnad 
    output reg write_en // enable to write in the memory 

);

// 15-12 is opcode
// 11-9 register number (destination)
// 8-6 register number for source 
// 7-0  immediate data


always @(*) begin
    en_write =0;
    en =1;
    load =0;

    alu_op = 3'b000;
    write_en =0;


    case(instr[15:12])
        4'h0: begin // load: Reg[Dest] = Immediate(7:0)
            write_reg = instr[11:9];
            en_write=1;
        end 

        4'h1: begin // ADD: Reg[Dest] = Reg[Dest] + Reg[Src]
            reg_sel_a = instr[11:9];
            reg_sel_b = instr[8:6];
            alu_op = 3'b000;
            write_reg = instr[11:9];
            en_write =1;
        end 



        4'h2: begin // SUB: Reg[Dest] = Reg[Dest] - Reg[Src]
            reg_sel_a = instr[11:9];
            reg_sel_b = instr[8:6];
            alu_op = 3'b001;
            write_reg = instr[11:9];
            en_write =1;
        end 

        4'h3: begin // MOV: Reg[Dest] = Reg[Src]
            reg_sel_a = instr[8:6];
            write_reg = instr[11:9];
            en_write =1;
        end 

         4'h4: begin // READ: Reg[Dest] = RAM[Addr]
           addr = instr[7:0];
           write_reg = instr[11:9];
           en_write=1;
        end 

         4'h5: begin // Write: RAM[Addr] = Reg[Dest]
            
           reg_sel_a = instr[11:9];
           write_en=1;
           addr = instr[7:0];
        end


        4'h6: begin // JMP
            load =1;
            data_in  = {8'h00, instr[7:0]};
        
        end 

        4'h7: begin // JZ: Jump if not Zero
            if (!status_z) begin
                load = 1;
                data_in = {8'h00, instr[7:0]};
            end
        end

        4'h8: begin // MUL
            reg_sel_a = instr[11:9];
            reg_sel_b = instr[8:6];
            alu_op = 3'b100;
            write_reg = instr[11:9];
            en_write =1;
        end

        4'hE: begin // HALT
            en =0;        
        end 




    endcase

end 


endmodule