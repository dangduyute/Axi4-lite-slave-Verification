class axi4lite_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(axi4lite_scoreboard)

    uvm_analysis_imp #(axi4lite_seq_item, axi4lite_scoreboard) item_export;

    bit [31:0] ref_reg[4];

    int unsigned write_count;
    int unsigned read_count;
    int unsigned match_count;
    int unsigned mismatch_count;
    int unsigned bresp_error_count;
    int unsigned rresp_error_count;

    function new(string name = "axi4lite_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        item_export = new("item_export", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        foreach (ref_reg[i]) ref_reg[i] = 32'h0;
    endfunction

    virtual function void write(axi4lite_seq_item tr);
        int idx;
        idx = addr_to_index(tr.addr);
        if (idx < 0) begin
            `uvm_error("SCOREBOARD", $sformatf("Unmapped address 0x%0h observed", tr.addr))
            return;
        end

        if (tr.is_write)
            handle_write(tr, idx);
        else
            handle_read(tr, idx);
    endfunction

    virtual function int addr_to_index(bit [3:0] addr);
        case (addr)
            4'h0: return 0;
            4'h4: return 1;
            4'h8: return 2;
            4'hC: return 3;
            default: return -1;
        endcase
    endfunction

    virtual function void handle_write(axi4lite_seq_item tr, int idx);
        write_count++;

        for (int b = 0; b < 4; b++) begin
            if (tr.wstrb[b])
                ref_reg[idx][b*8 +: 8] = tr.wdata[b*8 +: 8];
        end

        if (tr.bresp !== 2'b00) begin
            bresp_error_count++;
            `uvm_error("SCOREBOARD",
                $sformatf("Write to addr 0x%0h returned BRESP=%0b, expected OKAY", tr.addr, tr.bresp))
        end

        `uvm_info("SCOREBOARD",
            $sformatf("WRITE addr=0x%0h wdata=0x%0h wstrb=%0b -> ref_reg[%0d]=0x%0h",
                      tr.addr, tr.wdata, tr.wstrb, idx, ref_reg[idx]), UVM_HIGH)
    endfunction

    virtual function void handle_read(axi4lite_seq_item tr, int idx);
        read_count++;

        if (tr.rresp !== 2'b00) begin
            rresp_error_count++;
            `uvm_error("SCOREBOARD",
                $sformatf("Read from addr 0x%0h returned RRESP=%0b, expected OKAY", tr.addr, tr.rresp))
        end

        if (tr.rdata === ref_reg[idx]) begin
            match_count++;
            `uvm_info("SCOREBOARD",
                $sformatf("READ  addr=0x%0h rdata=0x%0h MATCH ref_reg[%0d]=0x%0h",
                          tr.addr, tr.rdata, idx, ref_reg[idx]), UVM_HIGH)
        end else begin
            mismatch_count++;
            `uvm_error("SCOREBOARD",
                $sformatf("READ  addr=0x%0h rdata=0x%0h MISMATCH, expected ref_reg[%0d]=0x%0h",
                          tr.addr, tr.rdata, idx, ref_reg[idx]))
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCOREBOARD",
            $sformatf("SUMMARY: writes=%0d reads=%0d matches=%0d mismatches=%0d bresp_err=%0d rresp_err=%0d",
                      write_count, read_count, match_count, mismatch_count,
                      bresp_error_count, rresp_error_count),
            UVM_LOW)
        if (mismatch_count == 0 && bresp_error_count == 0 && rresp_error_count == 0)
            `uvm_info("SCOREBOARD", "*** TEST PASSED (no mismatches/response errors) ***", UVM_LOW)
        else
            `uvm_error("SCOREBOARD", "*** TEST FAILED - see mismatch/response error counts above ***")
    endfunction

endclass : axi4lite_scoreboard