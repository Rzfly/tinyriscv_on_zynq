// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Package auto-generated by `reggen` containing data structure

package timer_reg_pkg;

  // Address widths within the block
  parameter int BlockAw = 4;

  ////////////////////////////
  // Typedefs for registers //
  ////////////////////////////

  typedef struct packed {
    struct packed {
      logic        q;
      logic        qe;
    } en;
    struct packed {
      logic        q;
      logic        qe;
    } int_en;
    struct packed {
      logic        q;
      logic        qe;
    } int_pending;
    struct packed {
      logic        q;
      logic        qe;
    } mode;
    struct packed {
      logic [23:0] q;
      logic        qe;
    } clk_div;
  } timer_reg2hw_ctrl_reg_t;

  typedef struct packed {
    logic [31:0] q;
  } timer_reg2hw_value_reg_t;

  typedef struct packed {
    logic [31:0] q;
  } timer_reg2hw_count_reg_t;

  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } en;
    struct packed {
      logic        d;
      logic        de;
    } int_en;
    struct packed {
      logic        d;
      logic        de;
    } int_pending;
    struct packed {
      logic        d;
      logic        de;
    } mode;
    struct packed {
      logic [23:0] d;
      logic        de;
    } clk_div;
  } timer_hw2reg_ctrl_reg_t;

  typedef struct packed {
    logic [31:0] d;
  } timer_hw2reg_count_reg_t;

  // Register -> HW type
  typedef struct packed {
    timer_reg2hw_ctrl_reg_t ctrl; // [96:64]
    timer_reg2hw_value_reg_t value; // [63:32]
    timer_reg2hw_count_reg_t count; // [31:0]
  } timer_reg2hw_t;

  // HW -> register type
  typedef struct packed {
    timer_hw2reg_ctrl_reg_t ctrl; // [64:32]
    timer_hw2reg_count_reg_t count; // [31:0]
  } timer_hw2reg_t;

  // Register offsets
  parameter logic [BlockAw-1:0] TIMER_CTRL_OFFSET = 4'h0;
  parameter logic [BlockAw-1:0] TIMER_VALUE_OFFSET = 4'h4;
  parameter logic [BlockAw-1:0] TIMER_COUNT_OFFSET = 4'h8;

  // Reset values for hwext registers and their fields
  parameter logic [31:0] TIMER_COUNT_RESVAL = 32'h0;

  // Register index
  typedef enum int {
    TIMER_CTRL,
    TIMER_VALUE,
    TIMER_COUNT
  } timer_id_e;

  // Register width information to check illegal writes
  parameter logic [3:0] TIMER_PERMIT [3] = '{
    4'b1111, // index[0] TIMER_CTRL
    4'b1111, // index[1] TIMER_VALUE
    4'b1111  // index[2] TIMER_COUNT
  };

endpackage
