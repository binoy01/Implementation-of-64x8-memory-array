// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module simple #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    //input wb_rst_i,
    //input wbs_stb_i,
    //input wbs_cyc_i,
    //input wbs_we_i,
    //input [3:0] wbs_sel_i,
    //input [31:0] wbs_dat_i,
    //input [31:0] wbs_adr_i,
    //output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    //input  [127:0] la_data_in,
    //output [127:0] la_data_out,
    //input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out
    //output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    //output [2:0] irq
);
    wire clk;
    //wire rst;
    wire rd_en;
    wire wr_en;

    wire [`MPRJ_IO_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-1:0] io_out;
    //wire [`MPRJ_IO_PADS-1:0] io_oeb; 
    
    
    wire [7:0] rout_data; 
    wire [7:0] wdata;
    wire [2:0] addr;
    //wire [BITS-1:0] count;

    //wire valid;
    //wire [3:0] wstrb;
    //wire [31:0] la_write;

    // WB MI A
    //assign valid = wbs_cyc_i && wbs_stb_i; 
    //assign wstrb = wbs_sel_i & {4{wbs_we_i}};
    
    assign clk=wb_clk_i;
     //assign wdata = wbs_dat_i;
    //assign addr= wbs_adr_i;
    //assign wdata = io_in[15:8];
    
    assign rd_en=io_in[0];
    assign wr_en=io_in[3];
    
    assign wdata=io_in[15:8];
    assign addr=io_in[7:5];
    //assign addr= wbs_adr_i;
    //assign wbs_dat_i=wdata;
   
    //assign io_in=wdata[7:0];
    assign io_out[23:16]=rout_data;
    assign wbs_dat_o = rout_data;
   

    // IO
    //assign io_out = count;
    //assign io_oeb = {(`MPRJ_IO_PADS-1){rst}};

    // IRQ
    //assign irq = 3'b000;	// Unused

    // LA
    //assign la_data_out = {{(127-BITS){1'b0}}, count};
    // Assuming LA probes [63:32] are for controlling the count register  
    //assign la_write = ~la_oenb[63:32] & ~{BITS{valid}};
    // Assuming LA probes [65:64] are for controlling the count clk & reset  
    //assign clk = (~la_oenb[64]) ? la_data_in[64]: wb_clk_i;
    //assign rst = (~la_oenb[65]) ? la_data_in[65]: wb_rst_i;

    mem_block #(
        .BITS(BITS)
    ) mem_block(
        .clk(clk),
        //.reset(rst),
        //.ready(wbs_ack_o)
        //.valid(valid),
        .addr(addr),
        .wdata(wdata),
        .rout_data(rout_data),
        .rd_en(rd_en),
        .wr_en(wr_en)
        
        //.wstrb(wstrb),
        //.la_write(la_write),
        //.la_input(la_data_in[63:32]),
        //.count(count)
    );

endmodule

module mem_block #(
    parameter BITS =32
)(
    input clk,
    input [2:0] addr,
    input rd_en,
    input wr_en,
    //input reset,
    //input valid,
    //input [3:0] wstrb, 
    input [7:0] wdata,
    //input [BITS-1:0] la_write,
    //input [BITS-1:0] la_input,
    //output ready,
    output [7:0] rout_data
    //output [BITS-1:0] count
);
    //reg ready;
    //reg [BITS-1:0] count;
    reg [7:0] rout_data;
    
    reg [7:0] mem [64:0];

    always @(posedge clk) begin
        
        if(wr_en==1'b1 && rd_en==1'b0)
        begin
         mem[addr]=wdata;
        end
        else if (wr_en==1'b0 && rd_en==1'b1)
        begin
         rout_data=mem[addr];
        end
        
 end

endmodule
`default_nettype wire
