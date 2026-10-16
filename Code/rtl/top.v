`include "en_gen.sv"
`include "generic_sram.sv"
`include "sram_response_gen.sv"

module sram_subsystem(
    input wire          hclk,
    input wire          n_hreset,
    input wire          hsel,
    input wire [31:0]   haddr,
    input wire [1:0]    htrans,
    input wire [2:0]    hsize,
    input wire [31:0]   hwdata,
    input wire          hwrite,

    output wire [31:0]  hrdata,
    output wire         hready,
    output wire         hresp
);
    wire [31:0] r_data; //Read data from voltage island 0
    wire        valid_access;
    wire        cen; //chip enable
    wire [31:0] addr;
    wire [3:0]  wen;
    wire        rd_aphase, wr_aphase;
    wire [31:0] haddr_reg_nxt;
    wire [2:0]  hsize_reg_nxt;

    reg [31:0]  haddr_reg;
    reg [2:0]   hsize_reg;
    reg         reg_cen;
    reg         RW_conf_dphase;
    reg         rd_dphase;
    reg         wr_dphase;

    // Detect when there is a Read conflicting with the second cycle of a write
    assign RWconflict = ~hwrite & valid_access & wr_dphase;

    // Delay the RWconflict signal by one cycle so that it corresponds to the Dphase of the Read
    always @(posedge hclk or negedge n_hreset) begin
        if (~n_hreset) begin
            RW_conf_dphase <= 1'b0;
        end else begin    // Register valid read accesses to a group
            RW_conf_dphase <= RWconflict;
        end
    end

    // Detect valid reads to the memory groups
    assign rd_aphase = ~hwrite & valid_access;
    assign wr_aphase =  hwrite & valid_access;

    // Indicate Dphase of reads & writes to various groups
    always @(posedge hclk or negedge n_hreset) begin
        if (~n_hreset) begin
            rd_dphase <= 1'b0;
            wr_dphase <= 1'b0;
        end else begin    // Register valid read accesses to a group
            rd_dphase <= rd_aphase;
            wr_dphase <= wr_aphase;
        end
    end

    // Store access Addr and Size info
    // Always store in Aphase of a write
    // Also store in Aphase of a read that has a RWconflict
    assign haddr_reg_nxt = (valid_access & (hwrite | RWconflict)) ? haddr : haddr_reg;
    assign hsize_reg_nxt = (valid_access & (hwrite | RWconflict)) ? hsize : hsize_reg;

    always @(posedge hclk or negedge n_hreset) begin
        if (~n_hreset) begin
            haddr_reg <= 32'b0;
            hsize_reg <= 3'b0;
        end else begin
            haddr_reg <= haddr_reg_nxt;
            hsize_reg <= hsize_reg_nxt;
        end
    end

    // Register cens various groups
    always @(posedge hclk or negedge n_hreset) begin
        if (~n_hreset) begin
            reg_cen <= 1'b1;
        end else begin  // Register read CENs to drive the output mux in the Data phase of reads
            reg_cen <= cen;
        end
    end

    // AHB read data
    assign hrdata = (reg_cen | wr_phase) ? 32'b0 : r_data;

        haddr_reg <= haddr_reg_nxt;
        hsize_reg <= hsize_reg_nxt;
      end
    end 

    // Register cens various groups
    always @(posedge hclk or negedge n_hreset) begin
      if (~n_hreset) begin
        reg_cen <= 1'b1;
      end else begin    // Register read CENs to drive the output mux in the Data phase of reads
        reg_cen <= cen | wr_dphase;
      end
    end

    // AHB read data
    assign hrdata = (reg_cen | wr_dphase) ? 32'h0 : r_data;

    en_gen i_en_gen(
        //inputs
        .haddr(haddr),
        .haddr_reg(haddr_reg),
        .hsize(hsize),
        .hsize_reg(hsize_reg),
        .wr_dphase(wr_dphase),
        .rd_aphase(rd_aphase),
        .rd_dphase(rd_dphase),
        .RW_conf_dphase(RW_conf_dphase),
        //Outputs
        .cen(cen),
        .wen(wen),
        .SRAM_addr(addr)
    );

    sram_response_gen i_sram_response_gen(
        //Inputs
        .hclk(hclk),         		// AHB Clock
        .n_hreset(n_hreset),     	// AHB reset - Active low
        .hsel(hsel),         		// AHB select
        .htrans(htrans),       		// Transfer type
        .hsize(hsize),        		// AHB Access type - byte, half-word, word
        .RWconflict(RWconflict),
        // Outputs
        .hready(hready),       		// Ready for new bus cycle from target slave
        .hresp(hresp),       		// Response from the bridge
        .valid_access(valid_access)
    ); 

    generic_sram #(32, 262144, 18) i_sram(
        .clk  (hclk),
        .n_cs (cen),
        .n_we ((cen | (&wen))),
        .n_oe (1'b0),
        .mask ( {{8 {wen[3]}},{8{wen[2]}},{8{wen[1]}},{8{wen[0]}}} ),
        .ad   (addr[19:2]),
        .din  (hwdata),
        .dout (r_data)
    );
endmodule