// TC04: single write to all registers
class tc04_single_write_all_regs_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc04_single_write_all_regs_seq)
    function new(string name = "tc04_single_write_all_regs_seq"); super.new(name); endfunction

    virtual task body();
        bit [3:0]  addrs[4] = '{4'h0, 4'h4, 4'h8, 4'hC};
        bit [31:0] data;
        foreach (addrs[i]) begin
            data = $urandom();
            do_write(addrs[i], data);
        end
    endtask
endclass

// TC05: AWVALID before WVALID
class tc05_addr_before_data_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc05_addr_before_data_seq)
    function new(string name = "tc05_addr_before_data_seq"); super.new(name); endfunction

    virtual task body();
        do_write(4'h4, $urandom(), 4'hF, /*aw_dly*/0, /*w_dly*/5, /*bready_dly*/0);
    endtask
endclass

// TC06: WVALID before AWVALID
class tc06_data_before_addr_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc06_data_before_addr_seq)
    function new(string name = "tc06_data_before_addr_seq"); super.new(name); endfunction

    virtual task body();
        do_write(4'h8, $urandom(), 4'hF, /*aw_dly*/5, /*w_dly*/0, /*bready_dly*/0);
    endtask
endclass

// TC07: BREADY held low
class tc07_write_bready_low_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc07_write_bready_low_seq)
    function new(string name = "tc07_write_bready_low_seq"); super.new(name); endfunction

    virtual task body();
        do_write(4'h0, $urandom(), 4'hF, 0, 0, /*bready_dly*/8);
    endtask
endclass

// TC08: single byte WSTRB
class tc08_wstrb_single_byte_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc08_wstrb_single_byte_seq)
    function new(string name = "tc08_wstrb_single_byte_seq"); super.new(name); endfunction

    virtual task body();
        bit [3:0]  strobes[4] = '{4'b0001, 4'b0010, 4'b0100, 4'b1000};
        bit [31:0] rd_data;
        foreach (strobes[i]) begin
            do_write(4'h0, $urandom(), strobes[i]);
            do_read(4'h0, rd_data);
        end
    endtask
endclass

// TC09: partial WSTRB combo
class tc09_wstrb_partial_combo_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc09_wstrb_partial_combo_seq)
    function new(string name = "tc09_wstrb_partial_combo_seq"); super.new(name); endfunction

    virtual task body();
        bit [3:0]  strobes[2] = '{4'b1010, 4'b0101};
        bit [31:0] rd_data;
        foreach (strobes[i]) begin
            do_write(4'h4, $urandom(), strobes[i]);
            do_read(4'h4, rd_data);
        end
    endtask
endclass

// TC10: WSTRB all zero
class tc10_wstrb_all_zero_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc10_wstrb_all_zero_seq)
    function new(string name = "tc10_wstrb_all_zero_seq"); super.new(name); endfunction

    virtual task body();
        bit [31:0] rd_data;
        do_write(4'h8, $urandom(), 4'hF);
        do_write(4'h8, $urandom(), 4'b0000);
        do_read(4'h8, rd_data);
    endtask
endclass

// TC11: single read from all registers
class tc11_single_read_all_regs_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc11_single_read_all_regs_seq)
    function new(string name = "tc11_single_read_all_regs_seq"); super.new(name); endfunction

    virtual task body();
        bit [3:0]  addrs[4] = '{4'h0, 4'h4, 4'h8, 4'hC};
        bit [31:0] wr_data[4];
        bit [31:0] rd_data;

        foreach (addrs[i]) begin
            wr_data[i] = $urandom();
            do_write(addrs[i], wr_data[i]);
        end
        foreach (addrs[i]) begin
            do_read(addrs[i], rd_data);
        end
    endtask
endclass

// TC12: RREADY held low
class tc12_read_rready_low_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc12_read_rready_low_seq)
    function new(string name = "tc12_read_rready_low_seq"); super.new(name); endfunction

    virtual task body();
        bit [31:0] rd_data;
        do_read(4'h8, rd_data, 0, /*rready_dly*/8);
    endtask
endclass

// TC13: write then read same address
class tc13_write_then_read_same_addr_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc13_write_then_read_same_addr_seq)
    function new(string name = "tc13_write_then_read_same_addr_seq"); super.new(name); endfunction

    virtual task body();
        bit [31:0] rd_data;
        bit [31:0] wr_data = $urandom();
        do_write(4'h4, wr_data);
        do_read(4'h4, rd_data);
    endtask
endclass

// TC14: random write/read mix
class tc14_random_write_read_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc14_random_write_read_seq)
    rand int unsigned num_transactions = 100;
    function new(string name = "tc14_random_write_read_seq"); super.new(name); endfunction

    virtual task body();
        axi4lite_seq_item item;
        repeat (num_transactions) begin
            item = axi4lite_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize())
                `uvm_error("AXI4LITE_SEQ", "Randomization failed in tc20")
            finish_item(item);
        end
    endtask
endclass

// TC15: overwrite same register (write twice, read back)
class tc15_write_overwrite_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc15_write_overwrite_seq)
    function new(string name = "tc15_write_overwrite_seq"); super.new(name); endfunction

    virtual task body();
        bit [31:0] rd_data;
        do_write(4'h0, 32'hAAAA_AAAA);
        do_write(4'h0, 32'h5555_5555);
        do_read(4'h0, rd_data);
    endtask
endclass

// TC17: random stress test
class tc17_random_stress_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc17_random_stress_seq)
    rand int unsigned num_transactions = 1000;
    function new(string name = "tc17_random_stress_seq"); super.new(name); endfunction

    virtual task body();
        axi4lite_seq_item item;
        repeat (num_transactions) begin
            item = axi4lite_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize())
                `uvm_error("AXI4LITE_SEQ", "Randomization failed in tc23")
            finish_item(item);
        end
    endtask
endclass