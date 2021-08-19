// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Top module auto-generated by `reggen`


module i2c_reg_top (
  input  logic        clk_i,
  input  logic        rst_ni,

  // To HW
  output i2c_reg_pkg::i2c_reg2hw_t reg2hw, // Write
  input  i2c_reg_pkg::i2c_hw2reg_t hw2reg, // Read

  input  logic        reg_we,
  input  logic        reg_re,
  input  logic [31:0] reg_wdata,
  input  logic [ 3:0] reg_be,
  input  logic [31:0] reg_addr,
  output logic [31:0] reg_rdata
);

  import i2c_reg_pkg::* ;

  localparam int AW = 4;
  localparam int DW = 32;
  localparam int DBW = DW/8;    // Byte Width

  logic reg_error;
  logic addrmiss, wr_err;

  logic [DW-1:0] reg_rdata_next;

  assign reg_rdata = reg_rdata_next;
  assign reg_error = wr_err;

  // Define SW related signals
  // Format: <reg>_<field>_{wd|we|qs}
  //        or <reg>_{wd|we|qs} if field == 1 or 0
  logic ctrl_we;
  logic ctrl_start_qs;
  logic ctrl_start_wd;
  logic ctrl_int_en_qs;
  logic ctrl_int_en_wd;
  logic ctrl_int_pending_qs;
  logic ctrl_int_pending_wd;
  logic ctrl_mode_qs;
  logic ctrl_mode_wd;
  logic ctrl_write_qs;
  logic ctrl_write_wd;
  logic ctrl_ack_qs;
  logic ctrl_error_qs;
  logic [15:0] ctrl_clk_div_qs;
  logic [15:0] ctrl_clk_div_wd;
  logic master_data_we;
  logic [7:0] master_data_address_qs;
  logic [7:0] master_data_address_wd;
  logic [7:0] master_data_regreg_qs;
  logic [7:0] master_data_regreg_wd;
  logic [7:0] master_data_data_qs;
  logic [7:0] master_data_data_wd;
  logic slave_data_re;
  logic [7:0] slave_data_qs;

  // Register instances
  // R[ctrl]: V(False)

  //   F[start]: 0:0
  prim_subreg #(
    .DW      (1),
    .SWACCESS("RW"),
    .RESVAL  (1'h0)
  ) u_ctrl_start (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (ctrl_we),
    .wd     (ctrl_start_wd),

    // from internal hardware
    .de     (hw2reg.ctrl.start.de),
    .d      (hw2reg.ctrl.start.d),

    // to internal hardware
    .qe     (reg2hw.ctrl.start.qe),
    .q      (reg2hw.ctrl.start.q),

    // to register interface (read)
    .qs     (ctrl_start_qs)
  );


  //   F[int_en]: 1:1
  prim_subreg #(
    .DW      (1),
    .SWACCESS("RW"),
    .RESVAL  (1'h0)
  ) u_ctrl_int_en (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (ctrl_we),
    .wd     (ctrl_int_en_wd),

    // from internal hardware
    .de     (hw2reg.ctrl.int_en.de),
    .d      (hw2reg.ctrl.int_en.d),

    // to internal hardware
    .qe     (reg2hw.ctrl.int_en.qe),
    .q      (reg2hw.ctrl.int_en.q),

    // to register interface (read)
    .qs     (ctrl_int_en_qs)
  );


  //   F[int_pending]: 2:2
  prim_subreg #(
    .DW      (1),
    .SWACCESS("W1C"),
    .RESVAL  (1'h0)
  ) u_ctrl_int_pending (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (ctrl_we),
    .wd     (ctrl_int_pending_wd),

    // from internal hardware
    .de     (hw2reg.ctrl.int_pending.de),
    .d      (hw2reg.ctrl.int_pending.d),

    // to internal hardware
    .qe     (reg2hw.ctrl.int_pending.qe),
    .q      (reg2hw.ctrl.int_pending.q),

    // to register interface (read)
    .qs     (ctrl_int_pending_qs)
  );


  //   F[mode]: 3:3
  prim_subreg #(
    .DW      (1),
    .SWACCESS("RW"),
    .RESVAL  (1'h0)
  ) u_ctrl_mode (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (ctrl_we),
    .wd     (ctrl_mode_wd),

    // from internal hardware
    .de     (hw2reg.ctrl.mode.de),
    .d      (hw2reg.ctrl.mode.d),

    // to internal hardware
    .qe     (reg2hw.ctrl.mode.qe),
    .q      (reg2hw.ctrl.mode.q),

    // to register interface (read)
    .qs     (ctrl_mode_qs)
  );


  //   F[write]: 4:4
  prim_subreg #(
    .DW      (1),
    .SWACCESS("RW"),
    .RESVAL  (1'h0)
  ) u_ctrl_write (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (ctrl_we),
    .wd     (ctrl_write_wd),

    // from internal hardware
    .de     (hw2reg.ctrl.write.de),
    .d      (hw2reg.ctrl.write.d),

    // to internal hardware
    .qe     (reg2hw.ctrl.write.qe),
    .q      (reg2hw.ctrl.write.q),

    // to register interface (read)
    .qs     (ctrl_write_qs)
  );


  //   F[ack]: 5:5
  prim_subreg #(
    .DW      (1),
    .SWACCESS("RO"),
    .RESVAL  (1'h0)
  ) u_ctrl_ack (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.ctrl.ack.de),
    .d      (hw2reg.ctrl.ack.d),

    // to internal hardware
    .qe     (reg2hw.ctrl.ack.qe),
    .q      (reg2hw.ctrl.ack.q),

    // to register interface (read)
    .qs     (ctrl_ack_qs)
  );


  //   F[error]: 6:6
  prim_subreg #(
    .DW      (1),
    .SWACCESS("RO"),
    .RESVAL  (1'h0)
  ) u_ctrl_error (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.ctrl.error.de),
    .d      (hw2reg.ctrl.error.d),

    // to internal hardware
    .qe     (reg2hw.ctrl.error.qe),
    .q      (reg2hw.ctrl.error.q),

    // to register interface (read)
    .qs     (ctrl_error_qs)
  );


  //   F[clk_div]: 31:16
  prim_subreg #(
    .DW      (16),
    .SWACCESS("RW"),
    .RESVAL  (16'h0)
  ) u_ctrl_clk_div (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (ctrl_we),
    .wd     (ctrl_clk_div_wd),

    // from internal hardware
    .de     (hw2reg.ctrl.clk_div.de),
    .d      (hw2reg.ctrl.clk_div.d),

    // to internal hardware
    .qe     (reg2hw.ctrl.clk_div.qe),
    .q      (reg2hw.ctrl.clk_div.q),

    // to register interface (read)
    .qs     (ctrl_clk_div_qs)
  );


  // R[master_data]: V(False)

  //   F[address]: 7:0
  prim_subreg #(
    .DW      (8),
    .SWACCESS("RW"),
    .RESVAL  (8'h0)
  ) u_master_data_address (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (master_data_we),
    .wd     (master_data_address_wd),

    // from internal hardware
    .de     (hw2reg.master_data.address.de),
    .d      (hw2reg.master_data.address.d),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.master_data.address.q),

    // to register interface (read)
    .qs     (master_data_address_qs)
  );


  //   F[regreg]: 15:8
  prim_subreg #(
    .DW      (8),
    .SWACCESS("RW"),
    .RESVAL  (8'h0)
  ) u_master_data_regreg (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (master_data_we),
    .wd     (master_data_regreg_wd),

    // from internal hardware
    .de     (hw2reg.master_data.regreg.de),
    .d      (hw2reg.master_data.regreg.d),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.master_data.regreg.q),

    // to register interface (read)
    .qs     (master_data_regreg_qs)
  );


  //   F[data]: 23:16
  prim_subreg #(
    .DW      (8),
    .SWACCESS("RW"),
    .RESVAL  (8'h0)
  ) u_master_data_data (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (master_data_we),
    .wd     (master_data_data_wd),

    // from internal hardware
    .de     (hw2reg.master_data.data.de),
    .d      (hw2reg.master_data.data.d),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.master_data.data.q),

    // to register interface (read)
    .qs     (master_data_data_qs)
  );


  // R[slave_data]: V(True)

  prim_subreg_ext #(
    .DW    (8)
  ) u_slave_data (
    .re     (slave_data_re),
    .we     (1'b0),
    .wd     ('0),
    .d      (hw2reg.slave_data.d),
    .qre    (reg2hw.slave_data.re),
    .qe     (),
    .q      (reg2hw.slave_data.q),
    .qs     (slave_data_qs)
  );


  logic [2:0] addr_hit;
  always_comb begin
    addr_hit = '0;
    addr_hit[0] = (reg_addr == I2C_CTRL_OFFSET);
    addr_hit[1] = (reg_addr == I2C_MASTER_DATA_OFFSET);
    addr_hit[2] = (reg_addr == I2C_SLAVE_DATA_OFFSET);
  end

  assign addrmiss = (reg_re || reg_we) ? ~|addr_hit : 1'b0 ;

  // Check sub-word write is permitted
  always_comb begin
    wr_err = (reg_we &
              ((addr_hit[0] & (|(I2C_PERMIT[0] & ~reg_be))) |
               (addr_hit[1] & (|(I2C_PERMIT[1] & ~reg_be))) |
               (addr_hit[2] & (|(I2C_PERMIT[2] & ~reg_be)))));
  end

  assign ctrl_we = addr_hit[0] & reg_we & !reg_error;

  assign ctrl_start_wd = reg_wdata[0];

  assign ctrl_int_en_wd = reg_wdata[1];

  assign ctrl_int_pending_wd = reg_wdata[2];

  assign ctrl_mode_wd = reg_wdata[3];

  assign ctrl_write_wd = reg_wdata[4];

  assign ctrl_clk_div_wd = reg_wdata[31:16];
  assign master_data_we = addr_hit[1] & reg_we & !reg_error;

  assign master_data_address_wd = reg_wdata[7:0];

  assign master_data_regreg_wd = reg_wdata[15:8];

  assign master_data_data_wd = reg_wdata[23:16];
  assign slave_data_re = addr_hit[2] & reg_re & !reg_error;

  // Read data return
  always_comb begin
    reg_rdata_next = '0;
    unique case (1'b1)
      addr_hit[0]: begin
        reg_rdata_next[0] = ctrl_start_qs;
        reg_rdata_next[1] = ctrl_int_en_qs;
        reg_rdata_next[2] = ctrl_int_pending_qs;
        reg_rdata_next[3] = ctrl_mode_qs;
        reg_rdata_next[4] = ctrl_write_qs;
        reg_rdata_next[5] = ctrl_ack_qs;
        reg_rdata_next[6] = ctrl_error_qs;
        reg_rdata_next[31:16] = ctrl_clk_div_qs;
      end

      addr_hit[1]: begin
        reg_rdata_next[7:0] = master_data_address_qs;
        reg_rdata_next[15:8] = master_data_regreg_qs;
        reg_rdata_next[23:16] = master_data_data_qs;
      end

      addr_hit[2]: begin
        reg_rdata_next[7:0] = slave_data_qs;
      end

      default: begin
        reg_rdata_next = '1;
      end
    endcase
  end

  // Unused signal tieoff

  // wdata / byte enable are not always fully used
  // add a blanket unused statement to handle lint waivers
  logic unused_wdata;
  logic unused_be;
  assign unused_wdata = ^reg_wdata;
  assign unused_be = ^reg_be;

endmodule
