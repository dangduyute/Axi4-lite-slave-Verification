class axi4lite_agent extends uvm_agent;

    `uvm_component_utils(axi4lite_agent)

    axi4lite_sequencer sqr;
    axi4lite_driver     drv;
    axi4lite_monitor    mon;

    function new(string name = "axi4lite_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        uvm_active_passive_enum is_active_cfg;
        super.build_phase(phase);

        if (uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active_cfg))
            is_active = is_active_cfg;

        mon = axi4lite_monitor::type_id::create("mon", this);

        if (get_is_active() == UVM_ACTIVE) begin
            sqr = axi4lite_sequencer::type_id::create("sqr", this);
            drv = axi4lite_driver::type_id::create("drv", this);
        end
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (get_is_active() == UVM_ACTIVE) begin
            drv.seq_item_port.connect(sqr.seq_item_export);
        end
    endfunction

endclass : axi4lite_agent