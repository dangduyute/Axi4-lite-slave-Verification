class axi4lite_driver extends uvm_driver #(axi4lite_seq_item);

    `uvm_component_utils(axi4lite_driver)

    virtual axi4lite_if vif;

    function new(string name = "axi4lite_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi4lite_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRIVER", "Virtual interface 'vif' not found in config_db")
    endfunction

    virtual task run_phase(uvm_phase phase);
        reset_signals();
        wait (vif.ARESETN === 1'b1);

        forever begin
            seq_item_port.get_next_item(req);
            drive_item(req);
            seq_item_port.item_done();
        end
    endtask

    virtual task reset_signals();
        vif.AWADDR  <= '0;
        vif.AWPROT  <= '0;
        vif.AWVALID <= 1'b0;
        vif.WDATA   <= '0;
        vif.WSTRB   <= '0;
        vif.WVALID  <= 1'b0;
        vif.BREADY  <= 1'b0;
        vif.ARADDR  <= '0;
        vif.ARPROT  <= '0;
        vif.ARVALID <= 1'b0;
        vif.RREADY  <= 1'b0;
    endtask

    virtual task drive_item(axi4lite_seq_item item);
        if (item.is_write)
            drive_write(item);
        else
            drive_read(item);
    endtask

    virtual task drive_write(axi4lite_seq_item item);
        fork
            begin : aw_channel
                repeat (item.addr_valid_delay) @(posedge vif.ACLK);
                vif.AWADDR  <= item.addr;
                vif.AWPROT  <= item.prot;
                vif.AWVALID <= 1'b1;
                @(posedge vif.ACLK);
                while (!vif.AWREADY) @(posedge vif.ACLK);
                vif.AWVALID <= 1'b0;
            end
            begin : w_channel
                repeat (item.data_valid_delay) @(posedge vif.ACLK);
                vif.WDATA  <= item.wdata;
                vif.WSTRB  <= item.wstrb;
                vif.WVALID <= 1'b1;
                @(posedge vif.ACLK);
                while (!vif.WREADY) @(posedge vif.ACLK);
                vif.WVALID <= 1'b0;
            end
        join

        repeat (item.bready_delay) @(posedge vif.ACLK);
        vif.BREADY <= 1'b1;
        @(posedge vif.ACLK);
        while (!vif.BVALID) @(posedge vif.ACLK);
        item.bresp = vif.BRESP;
        vif.BREADY <= 1'b0;

        `uvm_info("DRIVER", $sformatf("WRITE done: %s", item.convert2str()), UVM_HIGH)
    endtask

    virtual task drive_read(axi4lite_seq_item item);
        repeat (item.addr_valid_delay) @(posedge vif.ACLK);
        vif.ARADDR  <= item.addr;
        vif.ARPROT  <= item.prot;
        vif.ARVALID <= 1'b1;
        @(posedge vif.ACLK);
        while (!vif.ARREADY) @(posedge vif.ACLK);
        vif.ARVALID <= 1'b0;

        repeat (item.rready_delay) @(posedge vif.ACLK);
        vif.RREADY <= 1'b1;
        @(posedge vif.ACLK);
        while (!vif.RVALID) @(posedge vif.ACLK);
        item.rdata = vif.RDATA;
        item.rresp = vif.RRESP;
        vif.RREADY <= 1'b0;

        `uvm_info("DRIVER", $sformatf("READ done: %s", item.convert2str()), UVM_HIGH)
    endtask

endclass : axi4lite_driver