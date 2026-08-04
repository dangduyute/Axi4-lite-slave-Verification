class axi4lite_base_seq extends uvm_sequence #(axi4lite_seq_item);

    `uvm_object_utils(axi4lite_base_seq)

    function new(string name = "axi4lite_base_seq");
        super.new(name);
    endfunction

    task automatic do_write(bit [3:0] addr, bit [31:0] data,
                             bit [3:0] wstrb = 4'hF,
                             int aw_dly = -1, int w_dly = -1, int bready_dly = -1);
        axi4lite_seq_item item;
        item = axi4lite_seq_item::type_id::create("wr_item");
        start_item(item);
        if (!item.randomize() with {
                is_write == 1;
                addr     == local::addr;
                wdata    == local::data;
                wstrb    == local::wstrb;
                if (aw_dly     >= 0) addr_valid_delay == aw_dly;
                if (w_dly      >= 0) data_valid_delay == w_dly;
                if (bready_dly >= 0) bready_delay      == bready_dly;
            })
            `uvm_error("AXI4LITE_SEQ", "Randomization failed in do_write")
        finish_item(item);
    endtask

    task automatic do_read(input bit [3:0] addr, output bit [31:0] rdata,
                            input int ar_dly = -1, input int rready_dly = -1);
        axi4lite_seq_item item;
        item = axi4lite_seq_item::type_id::create("rd_item");
        start_item(item);
        if (!item.randomize() with {
                is_write == 0;
                addr     == local::addr;
                if (ar_dly     >= 0) addr_valid_delay == ar_dly;
                if (rready_dly >= 0) rready_delay      == rready_dly;
            })
            `uvm_error("AXI4LITE_SEQ", "Randomization failed in do_read")
        finish_item(item);
        rdata = item.rdata;
    endtask

    task automatic body();
    endtask

endclass : axi4lite_base_seq