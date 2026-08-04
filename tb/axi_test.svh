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

// TC05: AWVALID before WVALID
class test_addr_before_data extends axi4lite_base_test;
    `uvm_component_utils(test_addr_before_data)

    tc05_addr_before_data_seq seq;

    function new(string name = "test_addr_before_data", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_addr_before_data");
        vif.pulse_reset(5);
        seq = tc05_addr_before_data_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_ADDR_BEFORE_DATA", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_addr_before_data");
    endtask
endclass : test_addr_before_data

// TC06: WVALID before AWVALID
class test_data_before_addr extends axi4lite_base_test;
    `uvm_component_utils(test_data_before_addr)

    tc06_data_before_addr_seq seq;

    function new(string name = "test_data_before_addr", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_data_before_addr");
        vif.pulse_reset(5);
        seq = tc06_data_before_addr_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_DATA_BEFORE_ADDR", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_data_before_addr");
    endtask
endclass : test_data_before_addr

// TC07: BREADY held low
class test_write_bready_low extends axi4lite_base_test;
    `uvm_component_utils(test_write_bready_low)

    tc07_write_bready_low_seq seq;

    function new(string name = "test_write_bready_low", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_write_bready_low");
        vif.pulse_reset(5);
        seq = tc07_write_bready_low_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_WRITE_BREADY_LOW", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_write_bready_low");
    endtask
endclass : test_write_bready_low

// TC08: single byte WSTRB
class test_wstrb_single_byte extends axi4lite_base_test;
    `uvm_component_utils(test_wstrb_single_byte)

    tc08_wstrb_single_byte_seq seq;

    function new(string name = "test_wstrb_single_byte", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_wstrb_single_byte");
        vif.pulse_reset(5);
        seq = tc08_wstrb_single_byte_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_WSTRB_SINGLE_BYTE", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_wstrb_single_byte");
    endtask
endclass : test_wstrb_single_byte

// TC09: partial WSTRB combo
class test_wstrb_partial_combo extends axi4lite_base_test;
    `uvm_component_utils(test_wstrb_partial_combo)

    tc09_wstrb_partial_combo_seq seq;

    function new(string name = "test_wstrb_partial_combo", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_wstrb_partial_combo");
        vif.pulse_reset(5);
        seq = tc09_wstrb_partial_combo_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_WSTRB_PARTIAL_COMBO", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_wstrb_partial_combo");
    endtask
endclass : test_wstrb_partial_combo

// TC10: WSTRB all zero
class test_wstrb_all_zero extends axi4lite_base_test;
    `uvm_component_utils(test_wstrb_all_zero)

    tc10_wstrb_all_zero_seq seq;

    function new(string name = "test_wstrb_all_zero", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_wstrb_all_zero");
        vif.pulse_reset(5);
        seq = tc10_wstrb_all_zero_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_WSTRB_ALL_ZERO", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_wstrb_all_zero");
    endtask
endclass : test_wstrb_all_zero

// TC11: single read from all registers
class test_single_read_all_regs extends axi4lite_base_test;
    `uvm_component_utils(test_single_read_all_regs)

    tc11_single_read_all_regs_seq seq;

    function new(string name = "test_single_read_all_regs", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_single_read_all_regs");
        vif.pulse_reset(5);
        seq = tc11_single_read_all_regs_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_SINGLE_READ_ALL_REGS", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_single_read_all_regs");
    endtask
endclass : test_single_read_all_regs

// TC12: RREADY held low
class test_read_rready_low extends axi4lite_base_test;
    `uvm_component_utils(test_read_rready_low)

    tc12_read_rready_low_seq seq;

    function new(string name = "test_read_rready_low", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_read_rready_low");
        vif.pulse_reset(5);
        seq = tc12_read_rready_low_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_READ_RREADY_LOW", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_read_rready_low");
    endtask
endclass : test_read_rready_low

// TC13: write then read same address
class test_write_then_read_same_addr extends axi4lite_base_test;
    `uvm_component_utils(test_write_then_read_same_addr)

    tc13_write_then_read_same_addr_seq seq;

    function new(string name = "test_write_then_read_same_addr", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_write_then_read_same_addr");
        vif.pulse_reset(5);
        seq = tc13_write_then_read_same_addr_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_WRITE_THEN_READ_SAME_ADDR", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_write_then_read_same_addr");
    endtask
endclass : test_write_then_read_same_addr

// TC14: random write/read mix
class test_random_write_read extends axi4lite_base_test;
    `uvm_component_utils(test_random_write_read)

    tc14_random_write_read_seq seq;

    function new(string name = "test_random_write_read", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_random_write_read");
        vif.pulse_reset(5);
        seq = tc14_random_write_read_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_RANDOM_WRITE_READ", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_random_write_read");
    endtask
endclass : test_random_write_read

// TC15: overwrite same register (write twice, read back)
class test_write_overwrite extends axi4lite_base_test;
    `uvm_component_utils(test_write_overwrite)

    tc15_write_overwrite_seq seq;

    function new(string name = "test_write_overwrite", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_write_overwrite");
        vif.pulse_reset(5);
        seq = tc15_write_overwrite_seq::type_id::create("seq");
        if (!seq.randomize())
            `uvm_warning("TEST_WRITE_OVERWRITE", "Sequence randomize failed, using defaults")
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "test_write_overwrite");
    endtask
endclass : test_write_overwrite

// TC16: outstanding transaction block
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

// TC17: random stress test
class test_random_stress extends axi4lite_base_test;
    `uvm_component_utils(test_random_stress)

    tc17_random_stress_seq seq;

    function new(string name = "test_random_stress", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test_random_stress");
        vif.pulse_reset(5);
        fork
            global_timeout_watchdog(phase, 2_000_000ns);
            begin
                seq = tc17_random_stress_seq::type_id::create("seq");
                void'(seq.randomize() with { num_transactions == 1000; });
                seq.start(env.agent.sqr);
            end
        join_any
        disable fork;
        phase.drop_objection(this, "test_random_stress");
    endtask
endclass : test_random_stress