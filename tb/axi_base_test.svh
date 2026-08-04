class axi4lite_base_test extends uvm_test;

    `uvm_component_utils(axi4lite_base_test)

    axi4lite_env       env;
    virtual axi4lite_if vif;

    function new(string name = "axi4lite_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual axi4lite_if)::get(this, "", "vif", vif))
            `uvm_fatal("BASE_TEST", "Virtual interface 'vif' not found in config_db")

        env = axi4lite_env::type_id::create("env", this);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "axi4lite_base_test running");
        `uvm_info("BASE_TEST", "No sequence started in base test - override run_phase", UVM_LOW)
        #100;
        phase.drop_objection(this, "axi4lite_base_test done");
    endtask

    virtual task global_timeout_watchdog(uvm_phase phase, time timeout = 100_000ns);
        #timeout;
        `uvm_fatal("BASE_TEST", $sformatf("Global timeout of %0t reached - possible hang", timeout))
    endtask

endclass : axi4lite_base_test