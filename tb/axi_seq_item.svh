class axi4lite_seq_item extends uvm_sequence_item;

    rand bit               is_write;

    rand bit [3:0]         addr;
    rand bit [31:0]        wdata;
    rand bit [3:0]         wstrb;
    rand bit [2:0]         prot;

    rand int unsigned      addr_valid_delay;
    rand int unsigned      data_valid_delay;
    rand int unsigned      bready_delay;
    rand int unsigned      rready_delay;

    bit [31:0]              rdata;
    bit [1:0]                bresp;
    bit [1:0]                rresp;

    `uvm_object_utils_begin(axi4lite_seq_item)
        `uvm_field_int(is_write,          UVM_ALL_ON)
        `uvm_field_int(addr,              UVM_ALL_ON)
        `uvm_field_int(wdata,             UVM_ALL_ON)
        `uvm_field_int(wstrb,             UVM_ALL_ON)
        `uvm_field_int(prot,              UVM_ALL_ON)
        `uvm_field_int(addr_valid_delay,  UVM_ALL_ON)
        `uvm_field_int(data_valid_delay,  UVM_ALL_ON)
        `uvm_field_int(bready_delay,      UVM_ALL_ON)
        `uvm_field_int(rready_delay,      UVM_ALL_ON)
        `uvm_field_int(rdata,             UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(bresp,             UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(rresp,             UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_object_utils_end

    constraint c_addr_word_aligned {
        addr inside {4'h0, 4'h4, 4'h8, 4'hC};
    }

    constraint c_wstrb_default {
        soft wstrb == 4'hF;
    }

    constraint c_delay_default {
        soft addr_valid_delay inside {[0:2]};
        soft data_valid_delay inside {[0:2]};
        soft bready_delay     inside {[0:2]};
        soft rready_delay     inside {[0:2]};
    }

    function new(string name = "axi4lite_seq_item");
        super.new(name);
    endfunction

    function string convert2str();
        if (is_write)
            return $sformatf("WRITE addr=0x%0h wdata=0x%0h wstrb=%0b aw_dly=%0d w_dly=%0d bready_dly=%0d",
                              addr, wdata, wstrb, addr_valid_delay, data_valid_delay, bready_delay);
        else
            return $sformatf("READ  addr=0x%0h ar_dly=%0d rready_dly=%0d -> rdata=0x%0h rresp=%0b",
                              addr, addr_valid_delay, rready_delay, rdata, rresp);
    endfunction

endclass : axi4lite_seq_item