// TC01: basic reset
class test_reset_basic extends axi4lite_base_test;
    `uvm_component_utils(test_reset_basic)

    function new(string name = "test_reset_basic", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_reset_basic");
        vif.assert_reset();
        repeat (5) @(posedge vif.ACLK);
        if (vif.AWREADY !== 1'b0 || vif.WREADY !== 1'b0 ||
            vif.BVALID  !== 1'b0 || vif.ARREADY !== 1'b0 || vif.RVALID !== 1'b0)
            `uvm_error("TEST_RESET_BASIC", "Outputs not idle during reset")
        vif.deassert_reset();
        repeat (2) @(posedge vif.ACLK);
        phase.drop_objection(this, "test_reset_basic");
    endtask
endclass : test_reset_basic

// TC02: reset during a write
class test_reset_mid_transaction extends axi4lite_base_test;
    `uvm_component_utils(test_reset_mid_transaction)

    tc04_single_write_all_regs_seq seq;

    function new(string name = "test_reset_mid_transaction", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_reset_mid_transaction");

        seq = tc04_single_write_all_regs_seq::type_id::create("seq");
        void'(seq.randomize());
        fork
            seq.start(env.agent.sqr);
        join_none

        repeat (2) @(posedge vif.ACLK);
        vif.assert_reset();
        repeat (3) @(posedge vif.ACLK);
        if (vif.AWREADY !== 1'b0 || vif.WREADY !== 1'b0 || vif.BVALID !== 1'b0)
            `uvm_error("TEST_RESET_MID", "Write-channel signal stuck high after reset assertion")
        vif.deassert_reset();

        seq.kill();

        phase.drop_objection(this, "test_reset_mid_transaction");
    endtask
endclass : test_reset_mid_transaction

// TC03: first write right after reset
class test_aw_en_after_reset extends axi4lite_base_test;
    `uvm_component_utils(test_aw_en_after_reset)

    tc04_single_write_all_regs_seq seq;

    function new(string name = "test_aw_en_after_reset", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_aw_en_after_reset");
        vif.assert_reset();
        repeat (3) @(posedge vif.ACLK);
        vif.deassert_reset();
        @(posedge vif.ACLK);

        seq = tc04_single_write_all_regs_seq::type_id::create("seq");
        void'(seq.randomize());
        seq.start(env.agent.sqr);

        phase.drop_objection(this, "test_aw_en_after_reset");
    endtask
endclass : test_aw_en_after_reset

// TC04: single write to all registers
class test_single_write_all_regs extends axi4lite_base_test;
    `uvm_component_utils(test_single_write_all_regs)

    tc04_single_write_all_regs_seq seq;

    function new(string name = "test_single_write_all_regs", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_single_write_all_regs");
        vif.pulse_reset(5);
        seq = tc04_single_write_all_regs_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_SINGLE_WRITE_ALL_REGS", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_single_write_all_regs");
    endtask
endclass : test_single_write_all_regs

// TC05: write response OKAY (bỏ)
class test_write_response_okay extends axi4lite_base_test;
    `uvm_component_utils(test_write_response_okay)

    tc05_write_response_okay_seq seq;

    function new(string name = "test_write_response_okay", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_write_response_okay");
        vif.pulse_reset(5);
        seq = tc05_write_response_okay_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_WRITE_RESPONSE_OKAY", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_write_response_okay");
    endtask
endclass : test_write_response_okay

// TC06: AWVALID before WVALID
class test_addr_before_data extends axi4lite_base_test;
    `uvm_component_utils(test_addr_before_data)

    tc06_addr_before_data_seq seq;

    function new(string name = "test_addr_before_data", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_addr_before_data");
        vif.pulse_reset(5);
        seq = tc06_addr_before_data_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_ADDR_BEFORE_DATA", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_addr_before_data");
    endtask
endclass : test_addr_before_data

// TC07: WVALID before AWVALID
class test_data_before_addr extends axi4lite_base_test;
    `uvm_component_utils(test_data_before_addr)

    tc07_data_before_addr_seq seq;

    function new(string name = "test_data_before_addr", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_data_before_addr");
        vif.pulse_reset(5);
        seq = tc07_data_before_addr_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_DATA_BEFORE_ADDR", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_data_before_addr");
    endtask
endclass : test_data_before_addr

// TC08: AWVALID and WVALID same cycle (bỏ)
class test_write_same_cycle extends axi4lite_base_test;
    `uvm_component_utils(test_write_same_cycle)

    tc08_write_same_cycle_seq seq;

    function new(string name = "test_write_same_cycle", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_write_same_cycle");
        vif.pulse_reset(5);
        seq = tc08_write_same_cycle_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_WRITE_SAME_CYCLE", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_write_same_cycle");
    endtask
endclass : test_write_same_cycle

// TC09: back-to-back writes (bỏ)
class test_back_to_back_write extends axi4lite_base_test;
    `uvm_component_utils(test_back_to_back_write)

    tc09_back_to_back_write_seq seq;

    function new(string name = "test_back_to_back_write", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_back_to_back_write");
        vif.pulse_reset(5);
        seq = tc09_back_to_back_write_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_BACK_TO_BACK_WRITE", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_back_to_back_write");
    endtask
endclass : test_back_to_back_write

// TC10: BREADY held low
class test_write_bready_low extends axi4lite_base_test;
    `uvm_component_utils(test_write_bready_low)

    tc10_write_bready_low_seq seq;

    function new(string name = "test_write_bready_low", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_write_bready_low");
        vif.pulse_reset(5);
        seq = tc10_write_bready_low_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_WRITE_BREADY_LOW", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_write_bready_low");
    endtask
endclass : test_write_bready_low

// TC11: single byte WSTRB
class test_wstrb_single_byte extends axi4lite_base_test;
    `uvm_component_utils(test_wstrb_single_byte)

    tc11_wstrb_single_byte_seq seq;

    function new(string name = "test_wstrb_single_byte", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_wstrb_single_byte");
        vif.pulse_reset(5);
        seq = tc11_wstrb_single_byte_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_WSTRB_SINGLE_BYTE", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_wstrb_single_byte");
    endtask
endclass : test_wstrb_single_byte

// TC12: partial WSTRB combo
class test_wstrb_partial_combo extends axi4lite_base_test;
    `uvm_component_utils(test_wstrb_partial_combo)

    tc12_wstrb_partial_combo_seq seq;

    function new(string name = "test_wstrb_partial_combo", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_wstrb_partial_combo");
        vif.pulse_reset(5);
        seq = tc12_wstrb_partial_combo_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_WSTRB_PARTIAL_COMBO", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_wstrb_partial_combo");
    endtask
endclass : test_wstrb_partial_combo

// TC13: WSTRB all zero
class test_wstrb_all_zero extends axi4lite_base_test;
    `uvm_component_utils(test_wstrb_all_zero)

    tc13_wstrb_all_zero_seq seq;

    function new(string name = "test_wstrb_all_zero", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_wstrb_all_zero");
        vif.pulse_reset(5);
        seq = tc13_wstrb_all_zero_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_WSTRB_ALL_ZERO", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_wstrb_all_zero");
    endtask
endclass : test_wstrb_all_zero

// TC14: single read from all registers
class test_single_read_all_regs extends axi4lite_base_test;
    `uvm_component_utils(test_single_read_all_regs)

    tc14_single_read_all_regs_seq seq;

    function new(string name = "test_single_read_all_regs", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_single_read_all_regs");
        vif.pulse_reset(5);
        seq = tc14_single_read_all_regs_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_SINGLE_READ_ALL_REGS", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_single_read_all_regs");
    endtask
endclass : test_single_read_all_regs

// TC15: delayed ARVALID (bỏ)
class test_ar_arvalid_delayed extends axi4lite_base_test;
    `uvm_component_utils(test_ar_arvalid_delayed)

    tc15_ar_arvalid_delayed_seq seq;

    function new(string name = "test_ar_arvalid_delayed", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_ar_arvalid_delayed");
        vif.pulse_reset(5);
        seq = tc15_ar_arvalid_delayed_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_AR_ARVALID_DELAYED", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_ar_arvalid_delayed");
    endtask
endclass : test_ar_arvalid_delayed

// TC16: RREADY held low
class test_read_rready_low extends axi4lite_base_test;
    `uvm_component_utils(test_read_rready_low)

    tc16_read_rready_low_seq seq;

    function new(string name = "test_read_rready_low", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_read_rready_low");
        vif.pulse_reset(5);
        seq = tc16_read_rready_low_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_READ_RREADY_LOW", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_read_rready_low");
    endtask
endclass : test_read_rready_low

// TC17: back-to-back reads (cần chỉnh sửa, arvalid phải liên tiếp)(bỏ)
class test_back_to_back_read extends axi4lite_base_test; 
    `uvm_component_utils(test_back_to_back_read)

    tc17_back_to_back_read_seq seq;

    function new(string name = "test_back_to_back_read", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_back_to_back_read");
        vif.pulse_reset(5);
        seq = tc17_back_to_back_read_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_BACK_TO_BACK_READ", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_back_to_back_read");
    endtask
endclass : test_back_to_back_read

// TC18: write then read same address (đổi chỗ với tc14)
class test_write_then_read_same_addr extends axi4lite_base_test;
    `uvm_component_utils(test_write_then_read_same_addr)

    tc18_write_then_read_same_addr_seq seq;

    function new(string name = "test_write_then_read_same_addr", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_write_then_read_same_addr");
        vif.pulse_reset(5);
        seq = tc18_write_then_read_same_addr_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_WRITE_THEN_READ_SAME_ADDR", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_write_then_read_same_addr");
    endtask
endclass : test_write_then_read_same_addr

// TC19: concurrent write and read (bỏ)
class test_concurrent_write_read extends axi4lite_base_test;
    `uvm_component_utils(test_concurrent_write_read)

    tc19_concurrent_write_read_seq seq;

    function new(string name = "test_concurrent_write_read", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_concurrent_write_read");
        vif.pulse_reset(5);
        seq = tc19_concurrent_write_read_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_CONCURRENT_WRITE_READ", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_concurrent_write_read");
    endtask
endclass : test_concurrent_write_read

// TC20: random write/read mix
class test_random_write_read extends axi4lite_base_test;
    `uvm_component_utils(test_random_write_read)

    tc20_random_write_read_seq seq;

    function new(string name = "test_random_write_read", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_random_write_read");
        vif.pulse_reset(5);
        seq = tc20_random_write_read_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_RANDOM_WRITE_READ", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_random_write_read");
    endtask
endclass : test_random_write_read

// TC21: PROT signal ignored (bỏ)
class test_prot_ignored extends axi4lite_base_test;
    `uvm_component_utils(test_prot_ignored)

    tc21_prot_ignored_seq seq;

    function new(string name = "test_prot_ignored", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_prot_ignored");
        vif.pulse_reset(5);
        seq = tc21_prot_ignored_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_PROT_IGNORED", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_prot_ignored");
    endtask
endclass : test_prot_ignored

// TC22: outstanding transaction block
class test_outstanding_txn_block extends axi4lite_base_test;
    `uvm_component_utils(test_outstanding_txn_block)
 
    function new(string name = "test_outstanding_txn_block", uvm_component parent = null);
        super.new(name, parent);
    endfunction
 
    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_outstanding_txn_block");
        vif.pulse_reset(5);
 
        @(posedge vif.ACLK);
        vif.AWADDR  <= 4'h0;
        vif.AWVALID <= 1'b1;
        vif.WDATA   <= 32'hAAAA_5555;
        vif.WSTRB   <= 4'hF;
        vif.WVALID  <= 1'b1;
        vif.BREADY  <= 1'b0;
 
        @(posedge vif.ACLK);
        while (!(vif.AWREADY && vif.WREADY)) @(posedge vif.ACLK);
        vif.AWVALID <= 1'b0;
        vif.WVALID  <= 1'b0;
 
        repeat (2) @(posedge vif.ACLK);
 
        vif.AWADDR  <= 4'h4;
        vif.AWVALID <= 1'b1;
        vif.WDATA   <= 32'h1234_5678;
        vif.WSTRB   <= 4'hF;
        vif.WVALID  <= 1'b1;
 
        repeat (3) @(posedge vif.ACLK);
        if (vif.AWREADY !== 1'b0)
            `uvm_error("TEST_OUTSTANDING_TXN_BLOCK", "AWREADY asserted while previous BVALID was still pending")
 
        vif.BREADY <= 1'b1;
        @(posedge vif.ACLK);
        while (!vif.BVALID) @(posedge vif.ACLK);
        vif.BREADY <= 1'b0;
 
        @(posedge vif.ACLK);
      while (!(vif.AWREADY && vif.WREADY)) begin 
        vif.BREADY <= 1'b1;
        @(posedge vif.ACLK);
        
      end
        vif.AWVALID <= 1'b0;
        vif.WVALID  <= 1'b0;
 		
        
        @(posedge vif.ACLK);
        while (!vif.BVALID) @(posedge vif.ACLK);
        vif.BREADY <= 1'b0;
 
        phase.drop_objection(this, "test_outstanding_txn_block");
    endtask
endclass : test_outstanding_txn_block
  // TC23: random stress test
class test_random_stress extends axi4lite_base_test;
    `uvm_component_utils(test_random_stress)

    tc23_random_stress_seq seq;

    function new(string name = "test_random_stress", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_random_stress");
        vif.pulse_reset(5);
        fork
            global_timeout_watchdog(phase, 2_000_000ns);
            begin
                seq = tc23_random_stress_seq::type_id::create("seq");
                void'(seq.randomize() with { num_transactions == 1000; });
                seq.start(env.agent.sqr);
            end
        join_any
        disable fork;
        phase.drop_objection(this, "test_random_stress");
    endtask
endclass : test_random_stress