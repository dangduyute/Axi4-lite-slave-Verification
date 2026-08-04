interface axi4lite_if #(
    parameter int C_S_AXI_DATA_WIDTH = 32,
    parameter int C_S_AXI_ADDR_WIDTH = 4
) (
    input logic ACLK
);

    logic ARESETN = 1'b0;

    task automatic assert_reset();
        ARESETN = 1'b0;
    endtask

    task automatic deassert_reset();
        ARESETN = 1'b1;
    endtask

    task automatic pulse_reset(int unsigned cycles = 5);
        assert_reset();
        repeat (cycles) @(posedge ACLK);
        deassert_reset();
    endtask

    logic [C_S_AXI_ADDR_WIDTH-1:0]     AWADDR;
    logic [2:0]                        AWPROT;
    logic                              AWVALID;
    logic                              AWREADY;

    logic [C_S_AXI_DATA_WIDTH-1:0]     WDATA;
    logic [(C_S_AXI_DATA_WIDTH/8)-1:0] WSTRB;
    logic                              WVALID;
    logic                              WREADY;

    logic [1:0]                        BRESP;
    logic                              BVALID;
    logic                              BREADY;

    logic [C_S_AXI_ADDR_WIDTH-1:0]     ARADDR;
    logic [2:0]                        ARPROT;
    logic                              ARVALID;
    logic                              ARREADY;

    logic [C_S_AXI_DATA_WIDTH-1:0]     RDATA;
    logic [1:0]                        RRESP;
    logic                              RVALID;
    logic                              RREADY;

    property p_valid_stable(valid, ready);
        @(posedge ACLK) disable iff (!ARESETN)
        (valid && !ready) |=> valid;
    endproperty

    a_awvalid_stable: assert property (p_valid_stable(AWVALID, AWREADY))
        else $error("AWVALID de-asserted before AWREADY");
    a_wvalid_stable:  assert property (p_valid_stable(WVALID, WREADY))
        else $error("WVALID de-asserted before WREADY");
    a_bvalid_stable:  assert property (p_valid_stable(BVALID, BREADY))
        else $error("BVALID de-asserted before BREADY");
    a_arvalid_stable: assert property (p_valid_stable(ARVALID, ARREADY))
        else $error("ARVALID de-asserted before ARREADY");
    a_rvalid_stable:  assert property (p_valid_stable(RVALID, RREADY))
        else $error("RVALID de-asserted before RREADY");

endinterface : axi4lite_if