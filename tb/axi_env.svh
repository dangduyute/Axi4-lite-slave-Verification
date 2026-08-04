class axi4lite_env extends uvm_env;

    `uvm_component_utils(axi4lite_env)

    axi4lite_agent      agent;
    axi4lite_scoreboard sb;

    function new(string name = "axi4lite_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        uvm_config_db#(uvm_active_passive_enum)::set(this, "agent", "is_active", UVM_ACTIVE);
        agent = axi4lite_agent::type_id::create("agent", this);

        sb = axi4lite_scoreboard::type_id::create("sb", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.mon.ap.connect(sb.item_export);
    endfunction

    virtual task run_phase(uvm_phase phase);
        localparam time DRAIN_TIME = 200ns;
        phase.phase_done.set_drain_time(this, DRAIN_TIME);
    endtask

endclass : axi4lite_env