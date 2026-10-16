`include "sram_if.sv"

package sram_pkg;
    import uvm::*;

    //UVM Classes
    `include "sram_item.sv"
    `include "sram_config.sv"
    `include "sram_sequencer.sv"
    `include "base_sequence.sv"
    `include "base_vip.sv"
    `include "sram_driver.sv"
    `include "sram_monitor_active.sv"
    `include "sram_monitor_passive.sv"
    `include "sram_vip.sv"
    `include "sram_coverage.sv"
    `include "sram_agent.sv"
    `include "sram_scb.sv"
    `include "sram_env.sv"
endpackage