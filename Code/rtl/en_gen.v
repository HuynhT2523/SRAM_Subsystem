module en_gen (
    input wire [31:0]   haddr, haddr_reg,
    input wire [2:0]    hsize, hsize_reg,
    input wire          rd_aphase,
    input wire          rd_dphase, wr_dphase,
    input wire          RW_conf_dphase,

    output wire         cen,
    output reg  [3:0]   wen,
    output wire [31:0]  SRAM_addr 
);
    wire [2:0]  SRAM_size;
    wire        active_access;

    // Use the stored address if this is the data phase of a write or a read that a RWconflict
    // Else assuming that it is a read, use the haddr
    assign SRAM_addr = (wr_dphase | (rd_dphase & RW_conf_dphase)) ? haddr_reg : haddr;
    assign SRAM_size = (wr_dphase | (rd_dphase & RW_conf_dphase)) ? hsize_reg : hsize;

    // Signal indicating valid access to this group - either data phase of WR or
    // DPHASE of a read that a RWconflict or addr phase of RD to this group
    assign active_access = (wr_dphase | (rd_dphase & RW_conf_dphase) | rd_aphase);
    assign cen = ~active_access;    // cen = 1 when not active access

    always @(SRAM_size or SRAM_addr or wr_phase) begin
        casez ({wr_dphase, SRAM_size, SRAM_addr[1:0]})
            6'b100000: wen = 4'b1110;
            6'b100001: wen = 4'b1101;
            6'b100010: wen = 4'b1011;
            6'b100011: wen = 4'b0111;
            6'b10010x: wen = 4'b1100;
            6'b10011x : wen = 4'b0011;
            6'b1010xx : wen = 4'b0000;
            default   : wen = 4'b1111;
        endcase
    end
endmodule