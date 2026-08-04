
`timescale 1ns / 1ps
`include "package.svh"
`include "interface.svh"
import uvm_pkg::*;
`include "uvm_macros.svh"
import axi4lite_pkg::*;

module tb_top;

    localparam int C_S_AXI_DATA_WIDTH = 32;
    localparam int C_S_AXI_ADDR_WIDTH = 4;
    localparam time CLK_PERIOD = 10ns;

    logic ACLK;

    initial ACLK = 1'b0;
    always #(CLK_PERIOD/2) ACLK = ~ACLK;

    axi4lite_if #(
        .C_S_AXI_DATA_WIDTH (C_S_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH (C_S_AXI_ADDR_WIDTH)
    ) vif (
        .ACLK (ACLK)
    );

    myip_v1_0_S00_AXI #(
        .C_S_AXI_DATA_WIDTH (C_S_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH (C_S_AXI_ADDR_WIDTH)
    ) dut (
        .S_AXI_ACLK    (vif.ACLK),
        .S_AXI_ARESETN (vif.ARESETN),

        .S_AXI_AWADDR  (vif.AWADDR),
        .S_AXI_AWPROT  (vif.AWPROT),
        .S_AXI_AWVALID (vif.AWVALID),
        .S_AXI_AWREADY (vif.AWREADY),

        .S_AXI_WDATA   (vif.WDATA),
        .S_AXI_WSTRB   (vif.WSTRB),
        .S_AXI_WVALID  (vif.WVALID),
        .S_AXI_WREADY  (vif.WREADY),

        .S_AXI_BRESP   (vif.BRESP),
        .S_AXI_BVALID  (vif.BVALID),
        .S_AXI_BREADY  (vif.BREADY),

        .S_AXI_ARADDR  (vif.ARADDR),
        .S_AXI_ARPROT  (vif.ARPROT),
        .S_AXI_ARVALID (vif.ARVALID),
        .S_AXI_ARREADY (vif.ARREADY),

        .S_AXI_RDATA   (vif.RDATA),
        .S_AXI_RRESP   (vif.RRESP),
        .S_AXI_RVALID  (vif.RVALID),
        .S_AXI_RREADY  (vif.RREADY)
    );

    initial begin
        uvm_config_db#(virtual axi4lite_if)::set(null, "*", "vif", vif);
        run_test();
    end

    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);
    end

endmodule : tb_top