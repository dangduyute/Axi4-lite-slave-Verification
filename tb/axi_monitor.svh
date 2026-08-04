class axi4lite_monitor extends uvm_monitor;

    `uvm_component_utils(axi4lite_monitor)

    virtual axi4lite_if vif;
    uvm_analysis_port #(axi4lite_seq_item) ap;

    function new(string name = "axi4lite_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi4lite_if)::get(this, "", "vif", vif))
            `uvm_fatal("MONITOR", "Virtual interface 'vif' not found in config_db")
    endfunction

    virtual task run_phase(uvm_phase phase);
        fork
            monitor_write();
            monitor_read();
        join
    endtask

    virtual task monitor_write();
        axi4lite_seq_item tr;
        bit aw_seen, w_seen;
        bit [3:0]  addr;
        bit [2:0]  prot;
        bit [31:0] data;
        bit [3:0]  strb;

        forever begin
            aw_seen = 0; w_seen = 0;
            fork
                begin
                    do @(posedge vif.ACLK); while (!(vif.AWVALID && vif.AWREADY));
                    addr = vif.AWADDR; prot = vif.AWPROT;
                    aw_seen = 1;
                end
                begin
                    do @(posedge vif.ACLK); while (!(vif.WVALID && vif.WREADY));
                    data = vif.WDATA; strb = vif.WSTRB;
                    w_seen = 1;
                end
            join

            do @(posedge vif.ACLK); while (!(vif.BVALID && vif.BREADY));

            tr = axi4lite_seq_item::type_id::create("tr");
            tr.is_write = 1'b1;
            tr.addr     = addr;
            tr.prot     = prot;
            tr.wdata    = data;
            tr.wstrb    = strb;
            tr.bresp    = vif.BRESP;
            `uvm_info("MONITOR", $sformatf("Observed %s", tr.convert2str()), UVM_HIGH)
            ap.write(tr);
        end
    endtask

    virtual task monitor_read();
        axi4lite_seq_item tr;
        bit [3:0] addr;
        bit [2:0] prot;

        forever begin
            do @(posedge vif.ACLK); while (!(vif.ARVALID && vif.ARREADY));
            addr = vif.ARADDR;
            prot = vif.ARPROT;

            do @(posedge vif.ACLK); while (!(vif.RVALID && vif.RREADY));

            tr = axi4lite_seq_item::type_id::create("tr");
            tr.is_write = 1'b0;
            tr.addr     = addr;
            tr.prot     = prot;
            tr.rdata    = vif.RDATA;
            tr.rresp    = vif.RRESP;
            `uvm_info("MONITOR", $sformatf("Observed %s", tr.convert2str()), UVM_HIGH)
            ap.write(tr);
        end
    endtask

endclass : axi4lite_monitor