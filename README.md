<<<<<<< HEAD
# AXI4-Lite Slave UVM Testbench
=======
# AXI4-Lite Slave Verification
>>>>>>> 88d947bbb263cfc32b4a95d62d2d3636f622ee24

[![UVM](https://img.shields.io/badge/UVM-1.2-blue)]()
[![SystemVerilog](https://img.shields.io/badge/SystemVerilog-IEEE1800-orange)]()
[![Testcases](https://img.shields.io/badge/testcases-17-brightgreen)]()
[![Simulator](https://img.shields.io/badge/simulator-Questa%20%2F%20EDA%20Playground-lightgrey)]()

A from-scratch UVM verification environment for a 4-register **AXI4-Lite slave** (`myip_v1_0_S00_AXI`, based on the standard Xilinx AXI4-Lite IP template). Built layer by layer — interface, transaction, driver, monitor, scoreboard, tests — as a learning project to understand how a real UVM testbench fits together, not just how to copy one.

## Table of Contents

- [Why this project](#why-this-project)
- [Testbench architecture](#testbench-architecture)
- [File list](#file-list)
- [Testcase list](#testcase-list-tc01tc17)
- [Design limitations this testbench catches](#design-limitations-this-testbench-catches)
- [How to run](#how-to-run)
- [Expected result](#expected-result)
- [Compile order](#compile-order)
- [Notes](#notes)

## Why This Project

The DUT looks simple — 4 registers behind an AXI4-Lite interface — but a proper UVM environment around it still has to answer real verification questions: what happens if reset hits mid-transaction? Does the slave actually respect `WSTRB` at the byte level? Can it accept a second write while the first response is still pending? This testbench is built to answer those questions with assertions and a reference-model scoreboard, not just "it ran without crashing."

## Testbench Architecture

<<<<<<< HEAD
![UVM Testbench Architecture](uvm_architecture.png)
=======
```
tb_top (module)
 └─ axi4lite_if            interface, holds ARESETN internally + reset tasks
 └─ myip_v1_0_S00_AXI       DUT
 └─ uvm_test (axi4lite_base_test and derived tests)
     └─ axi4lite_env
         ├─ axi4lite_agent
         │   ├─ axi4lite_sequencer
         │   ├─ axi4lite_driver     drives signals into the DUT
         │   └─ axi4lite_monitor    watches the bus, captures completed transactions
         └─ axi4lite_scoreboard     reference model of the 4 registers, checks results
```
>>>>>>> 88d947bbb263cfc32b4a95d62d2d3636f622ee24

**Key design choices:**
- `ARESETN` lives *inside* the interface as a plain variable (not a port), with `assert_reset()` / `deassert_reset()` / `pulse_reset()` tasks — so any test can control reset legally through the virtual interface, without fighting SystemVerilog's net-driving rules.
- Protocol-stability assertions (`VALID` must not drop before `READY`) live in the interface itself, so every single test gets that check for free — no need to repeat it per testcase.
- Timing-sensitive checks that a data-only scoreboard can't see (e.g. "does `AWREADY` stay low while a previous response is still pending?") are written as explicit signal-level checks inside the test, not bolted onto the scoreboard.

## File List

| File | Role |
|---|---|
| `axi4lite_if_basic.sv` | Interface connecting to the DUT — no modport/clocking block, includes assertions checking that `VALID` doesn't drop before `READY` |
| `axi4lite_seq_item.sv` | Transaction (seq_item): address, data, `WSTRB`, handshake delays |
| `axi4lite_base_seq.sv` | Base sequence, provides `do_write()` / `do_read()` helpers reused by other sequences |
| `axi4lite_testcase_seqs.sv` | One sequence per testcase |
| `axi4lite_sequencer.sv` | Sequencer (typedef of `uvm_sequencer`) |
| `axi4lite_driver.sv` | Driver — pulls items from the sequencer, drives them into the DUT via the interface |
| `axi4lite_monitor.sv` | Monitor — captures completed transactions, publishes them on an analysis port |
| `axi4lite_agent.sv` | Bundles sequencer + driver + monitor |
| `axi4lite_scoreboard.sv` | Reference model of the 4 registers, checks `RDATA`/`BRESP`/`RRESP` |
| `axi4lite_env.sv` | Bundles agent + scoreboard, sets a `drain_time` for waveform inspection |
| `axi4lite_base_test.sv` | Base test — builds the env, fetches the virtual interface, provides a hang-watchdog |
| `axi4lite_tests.sv` | 17 test classes, one per testcase |
| `axi4lite_pkg.sv` | Bundles all classes in the correct include order |
| `tb_top.sv` | Top module — generates the clock, wires the DUT to the interface, calls `run_test()` |

## Testcase List (TC01–TC17)

| # | Test | What it's really checking |
|---|---|---|
| 01 | `test_reset_basic` | Every slave output goes idle while `ARESETN=0` |
| 02 | `test_reset_mid_transaction` | Reset asserted mid-write doesn't leave `AWREADY`/`WREADY`/`BVALID` stuck high |
| 03 | `test_aw_en_after_reset` | The very first write after reset release is accepted (`aw_en` initialized correctly) |
| 04 | `test_single_write_all_regs` | Basic write to each of the 4 registers |
| 05 | `test_addr_before_data` | `AWVALID` arrives before `WVALID` — DUT still handshakes correctly |
| 06 | `test_data_before_addr` | `WVALID` arrives before `AWVALID` — order shouldn't matter |
| 07 | `test_write_bready_low` | `BVALID` stays high while the master delays `BREADY` |
| 08 | `test_wstrb_single_byte` | Each individual byte lane of `WSTRB` writes correctly, others stay untouched |
| 09 | `test_wstrb_partial_combo` | Non-contiguous `WSTRB` patterns (e.g. `1010`) still write the right bytes |
| 10 | `test_wstrb_all_zero` | `WSTRB=0000` completes the handshake but changes nothing |
| 11 | `test_single_read_all_regs` | Write known values, read every register back, verify match |
| 12 | `test_read_rready_low` | `RVALID`/`RDATA` stay stable while the master delays `RREADY` |
| 13 | `test_write_then_read_same_addr` | Write then immediate read-back of the same address returns the new value |
| 14 | `test_random_write_read` | Randomized write/read mix, fully checked against the reference model |
| 15 | `test_write_overwrite` | Second write to the same register overwrites the first — read confirms the latest value wins |
| 16 | `test_outstanding_txn_block` | A second write is **not** accepted while the first response is still pending (no outstanding-transaction support) |
| 17 | `test_random_stress` | 1000 fully random transactions back-to-back, guarded by a 2ms watchdog |

## Design Limitations This Testbench Catches

Not every "interesting" test is about a bug — some are about documenting real constraints of this DUT so nobody is surprised later:

- **No outstanding transactions.** `aw_en` blocks a second write address until the first write's response has been accepted (`test_outstanding_txn_block`). This DUT is strictly one-transaction-at-a-time.
- **`AWPROT`/`ARPROT` are decorative.** The DUT never reads them for access control — they can be any value without changing behavior.
- **No decode error path.** `BRESP`/`RRESP` are hard-coded `OKAY` — there's no `SLVERR`/`DECERR` logic to verify, so response checks in the scoreboard are really checking "did the DUT stay well-behaved," not address decoding.

## How to Run

```bash
vsim -c work.tb_top +UVM_TESTNAME=<test_name> -do "run -all"
```

Example:
```bash
vsim -c work.tb_top +UVM_TESTNAME=test_single_write_all_regs -do "run -all"
```

Run the full regression:
```bash
for t in test_reset_basic test_reset_mid_transaction test_aw_en_after_reset \
         test_single_write_all_regs test_addr_before_data test_data_before_addr \
         test_write_bready_low test_wstrb_single_byte test_wstrb_partial_combo \
         test_wstrb_all_zero test_single_read_all_regs test_read_rready_low \
         test_write_then_read_same_addr test_random_write_read test_write_overwrite \
         test_outstanding_txn_block test_random_stress; do
    vsim -c work.tb_top +UVM_TESTNAME=$t -do "run -all; quit" | tee log_$t.txt
done
```

Want to see what the driver and monitor are actually doing cycle by cycle? Bump the verbosity (only scoreboard summaries are shown by default):
```bash
vsim -c work.tb_top +UVM_TESTNAME=<test_name> +UVM_VERBOSITY=UVM_HIGH -do "run -all"
```

## Expected Result

Every test ends with a scoreboard summary:
```
UVM_INFO ... [SCOREBOARD] SUMMARY: writes=X reads=Y matches=Z mismatches=0 bresp_err=0 rresp_err=0
UVM_INFO ... [SCOREBOARD] *** TEST PASSED (no mismatches/response errors) ***
```

A non-zero `mismatches`, `bresp_err`, or `rresp_err` — or a `UVM_ERROR` from one of the protocol assertions — means the run should be treated as a failure, not just "check the log title."

## Compile Order

```
axi4lite_if_basic.sv     (interface, must be compiled before the package)
axi4lite_pkg.sv          (bundles all classes in include order)
tb_top.sv
```

## Notes

- The original DUT (`myip_v1_0_S00_AXI`) only supports one transaction at a time (no outstanding transaction support) — `test_outstanding_txn_block` verifies this design limitation directly.
- Reset (`ARESETN`) does not live in `tb_top`; it lives inside `axi4lite_if` and is controlled via `vif.assert_reset()` / `vif.deassert_reset()` / `vif.pulse_reset()` — each test calls `pulse_reset()` at the start of its own `run_phase`, so reset happens sequentially as part of the test rather than racing against `run_test()`.
- This project was built and debugged step by step (including chasing down real compile/runtime errors along the way — `vlog-13276`, `vlog-13167`, `vopt-2110`, `SEQREQZMB`) rather than assembled from a finished template, so the structure favors clarity over cleverness.
