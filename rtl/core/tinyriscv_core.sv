 /*                                                                      
 Copyright 2019 Blue Liang, liangkangnan@163.com
                                                                         
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         
     http://www.apache.org/licenses/LICENSE-2.0                          
                                                                         
 Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.                                          
 */

`include "defines.sv"

// tinyriscv处理器核顶层模块
module tinyriscv_core #(
    parameter int unsigned DEBUG_HALT_ADDR      = 32'h10000800,
    parameter int unsigned DEBUG_EXCEPTION_ADDR = 32'h10000808
    )(

    input wire clk,
    input wire rst_n,

    // instr fetch interface
    output wire instr_req_o,
    input wire instr_gnt_i,
    input wire instr_rvalid_i,
    output wire[31:0] instr_addr_o,
    input wire[31:0] instr_rdata_i,
    input wire instr_err_i,

    // data access interface
    output wire data_req_o,
    input wire data_gnt_i,
    input wire data_rvalid_i,
    output wire data_we_o,
    output wire[3:0] data_be_o,
    output wire[31:0] data_addr_o,
    output wire[31:0] data_wdata_o,
    input wire[31:0] data_rdata_i,
    input wire data_err_i,

    // interrupt inputs
    input wire irq_software_i,
    input wire irq_timer_i,
    input wire irq_external_i,
    input wire[14:0] irq_fast_i,

    // debug req signal
    input wire debug_req_i

    );

    // ifu模块输出信号
    wire[31:0] ifetch_inst_o;
    wire[31:0] ifetch_pc_o;
    wire ifetch_inst_valid_o;

    // ifu_idu模块输出信号
	wire[31:0] if_inst_o;
    wire[31:0] if_inst_addr_o;
    wire if_inst_valid_o;

    // idu模块输出信号
    wire[31:0] id_inst_o;
    wire[31:0] id_inst_addr_o;
    wire[`DECINFO_WIDTH-1:0] id_dec_info_bus_o;
    wire[31:0] id_dec_imm_o;
    wire[31:0] id_dec_pc_o;
    wire[4:0] id_rs1_raddr_o;
    wire[4:0] id_rs2_raddr_o;
    wire[4:0] id_rd_waddr_o;
    wire id_rd_we_o;
    wire id_stall_o;
    wire[31:0] id_rs1_rdata_o;
    wire[31:0] id_rs2_rdata_o;
    wire id_illegal_inst_o;

    // idu_exu模块输出信号
    wire[31:0] ie_inst_o;
    wire[31:0] ie_inst_addr_o;
    wire[`DECINFO_WIDTH-1:0] ie_dec_info_bus_o;
    wire[31:0] ie_dec_imm_o;
    wire[31:0] ie_dec_pc_o;
    wire[31:0] ie_rs1_rdata_o;
    wire[31:0] ie_rs2_rdata_o;
    wire[4:0] ie_rd_waddr_o;
    wire ie_rd_we_o;
    wire ie_inst_valid_o;

    // exu模块输出信号
    wire[31:0] ex_mem_wdata_o;
    wire[31:0] ex_mem_addr_o;
    wire ex_mem_we_o;
    wire[3:0] ex_mem_sel_o;
    wire ex_mem_req_valid_o;
    wire ex_mem_rsp_ready_o;
    wire ex_mem_access_misaligned_o;
    wire[31:0] ex_reg_wdata_o;
    wire ex_reg_we_o;
    wire[4:0] ex_reg_waddr_o;
    wire ex_hold_flag_o;
    wire ex_jump_flag_o;
    wire[31:0] ex_jump_addr_o;
    wire[31:0] ex_csr_wdata_o;
    wire ex_csr_we_o;
    wire[31:0] ex_csr_waddr_o;
    wire[31:0] ex_csr_raddr_o;
    wire ex_inst_ecall_o;
    wire ex_inst_ebreak_o;
    wire ex_inst_mret_o;
    wire ex_inst_dret_o;
    wire ex_inst_valid_o;
    wire ex_inst_executed_o;

    // gpr_reg模块输出信号
    wire[31:0] regs_rdata1_o;
    wire[31:0] regs_rdata2_o;

    // csr_reg模块输出信号
    wire[31:0] csr_ex_data_o;
    wire[31:0] csr_clint_data_o;
    wire[31:0] csr_mtvec_o;
    wire[31:0] csr_mepc_o;
    wire[31:0] csr_mstatus_o;
    wire[31:0] csr_mie_o;
    wire[31:0] csr_dpc_o;
    wire[31:0] csr_dcsr_o;
    wire csr_trigger_match_o;

    // pipe_ctrl模块输出信号
    wire[31:0] ctrl_flush_addr_o;
    wire ctrl_flush_o;
    wire[`STALL_WIDTH-1:0] ctrl_stall_o;

    // clint模块输出信号
    wire clint_csr_we_o;
    wire[31:0] clint_csr_waddr_o;
    wire[31:0] clint_csr_wdata_o;
    wire clint_stall_flag_o;
    wire[31:0] clint_int_addr_o;
    wire clint_int_assert_o;


    ifu u_ifu(
        .clk(clk),
        .rst_n(rst_n),
        .flush_addr_i(ctrl_flush_addr_o),
        .stall_i(ctrl_stall_o),
        .flush_i(ctrl_flush_o),
        .inst_o(ifetch_inst_o),
        .pc_o(ifetch_pc_o),
        .inst_valid_o(ifetch_inst_valid_o),
        .instr_req_o(instr_req_o),
        .instr_gnt_i(instr_gnt_i),
        .instr_rvalid_i(instr_rvalid_i),
        .instr_addr_o(instr_addr_o),
        .instr_rdata_i(instr_rdata_i),
        .instr_err_i(instr_err_i)
    );

    pipe_ctrl u_pipe_ctrl(
        .clk(clk),
        .rst_n(rst_n),
        .stall_from_id_i(id_stall_o),
        .stall_from_ex_i(ex_hold_flag_o),
        .stall_from_jtag_i(1'b0),
        .stall_from_clint_i(clint_stall_flag_o),
        .jump_assert_i(ex_jump_flag_o),
        .jump_addr_i(ex_jump_addr_o),
        .flush_o(ctrl_flush_o),
        .stall_o(ctrl_stall_o),
        .flush_addr_o(ctrl_flush_addr_o)
    );

    gpr_reg u_gpr_reg(
        .clk(clk),
        .rst_n(rst_n),
        .we_i(ex_reg_we_o),
        .waddr_i(ex_reg_waddr_o),
        .wdata_i(ex_reg_wdata_o),
        .raddr1_i(id_rs1_raddr_o),
        .rdata1_o(regs_rdata1_o),
        .raddr2_i(id_rs2_raddr_o),
        .rdata2_o(regs_rdata2_o)
    );

    csr_reg u_csr_reg(
        .clk(clk),
        .rst_n(rst_n),
        .pc_if_i(ie_dec_pc_o),
        .trigger_match_o(csr_trigger_match_o),
        .exu_we_i(ex_csr_we_o),
        .exu_raddr_i(ex_csr_raddr_o),
        .exu_waddr_i(ex_csr_waddr_o),
        .exu_wdata_i(ex_csr_wdata_o),
        .exu_rdata_o(csr_ex_data_o),
        .clint_we_i(clint_csr_we_o),
        .clint_waddr_i(clint_csr_waddr_o),
        .clint_wdata_i(clint_csr_wdata_o),
        .mtvec_o(csr_mtvec_o),
        .mepc_o(csr_mepc_o),
        .mstatus_o(csr_mstatus_o),
        .mie_o(csr_mie_o),
        .dpc_o(csr_dpc_o),
        .dcsr_o(csr_dcsr_o)
    );

    ifu_idu u_ifu_idu(
        .clk(clk),
        .rst_n(rst_n),
        .inst_i(ifetch_inst_o),
        .inst_addr_i(ifetch_pc_o),
        .stall_i(ctrl_stall_o),
        .flush_i(ctrl_flush_o),
        .inst_valid_i(ifetch_inst_valid_o),
        .inst_valid_o(if_inst_valid_o),
        .inst_o(if_inst_o),
        .inst_addr_o(if_inst_addr_o)
    );

    idu u_idu(
        .clk(clk),
        .rst_n(rst_n),
        .inst_i(if_inst_o),
        .rs1_rdata_i(regs_rdata1_o),
        .rs2_rdata_i(regs_rdata2_o),
        .inst_o(id_inst_o),
        .inst_addr_i(if_inst_addr_o),
        .rs1_rdata_o(id_rs1_rdata_o),
        .rs2_rdata_o(id_rs2_rdata_o),
        .stall_o(id_stall_o),
        .illegal_inst_o(id_illegal_inst_o),
        .dec_info_bus_o(id_dec_info_bus_o),
        .dec_imm_o(id_dec_imm_o),
        .dec_pc_o(id_dec_pc_o),
        .rs1_raddr_o(id_rs1_raddr_o),
        .rs2_raddr_o(id_rs2_raddr_o),
        .rd_waddr_o(id_rd_waddr_o),
        .rd_we_o(id_rd_we_o)
    );

    idu_exu u_idu_exu(
        .clk(clk),
        .rst_n(rst_n),
        .inst_i(id_inst_o),
        .stall_i(ctrl_stall_o),
        .flush_i(ctrl_flush_o),
        .dec_info_bus_i(id_dec_info_bus_o),
        .dec_imm_i(id_dec_imm_o),
        .dec_pc_i(id_dec_pc_o),
        .rs1_rdata_i(id_rs1_rdata_o),
        .rs2_rdata_i(id_rs2_rdata_o),
        .rd_waddr_i(id_rd_waddr_o),
        .rd_we_i(id_rd_we_o),
        .inst_valid_i(if_inst_valid_o),
        .inst_valid_o(ie_inst_valid_o),
        .inst_o(ie_inst_o),
        .dec_info_bus_o(ie_dec_info_bus_o),
        .dec_imm_o(ie_dec_imm_o),
        .dec_pc_o(ie_dec_pc_o),
        .rs1_rdata_o(ie_rs1_rdata_o),
        .rs2_rdata_o(ie_rs2_rdata_o),
        .rd_waddr_o(ie_rd_waddr_o),
        .rd_we_o(ie_rd_we_o)
    );

    exu u_exu(
        .clk(clk),
        .rst_n(rst_n),
        .reg1_rdata_i(ie_rs1_rdata_o),
        .reg2_rdata_i(ie_rs2_rdata_o),
        .mem_rdata_i(data_rdata_i),
        .mem_gnt_i(data_gnt_i),
        .mem_rvalid_i(data_rvalid_i),
        .mem_wdata_o(data_wdata_o),
        .mem_addr_o(data_addr_o),
        .mem_we_o(data_we_o),
        .mem_be_o(data_be_o),
        .mem_req_o(data_req_o),
        .mem_access_misaligned_o(ex_mem_access_misaligned_o),
        .reg_wdata_o(ex_reg_wdata_o),
        .reg_we_o(ex_reg_we_o),
        .reg_waddr_o(ex_reg_waddr_o),
        .hold_flag_o(ex_hold_flag_o),
        .jump_flag_o(ex_jump_flag_o),
        .jump_addr_o(ex_jump_addr_o),
        .int_assert_i(clint_int_assert_o),
        .int_addr_i(clint_int_addr_o),
        .inst_ecall_o(ex_inst_ecall_o),
        .inst_ebreak_o(ex_inst_ebreak_o),
        .inst_mret_o(ex_inst_mret_o),
        .inst_dret_o(ex_inst_dret_o),
        .int_stall_i(clint_stall_flag_o),
        .csr_raddr_o(ex_csr_raddr_o),
        .csr_rdata_i(csr_ex_data_o),
        .csr_wdata_o(ex_csr_wdata_o),
        .csr_we_o(ex_csr_we_o),
        .csr_waddr_o(ex_csr_waddr_o),
        .inst_valid_o(ex_inst_valid_o),
        .inst_valid_i(ie_inst_valid_o),
        .inst_executed_o(ex_inst_executed_o),
        .inst_i(ie_inst_o),
        .dec_info_bus_i(ie_dec_info_bus_o),
        .dec_imm_i(ie_dec_imm_o),
        .dec_pc_i(ie_dec_pc_o),
        .next_pc_i(if_inst_addr_o),
        .rd_waddr_i(ie_rd_waddr_o),
        .rd_we_i(ie_rd_we_o)
    );

    exception u_exception(
        .clk(clk),
        .rst_n(rst_n),
        .illegal_inst_i(id_illegal_inst_o),
        .inst_valid_i(ie_inst_valid_o),
        .inst_executed_i(ex_inst_executed_o),
        .inst_ecall_i(ex_inst_ecall_o),
        .inst_ebreak_i(ex_inst_ebreak_o),
        .inst_mret_i(ex_inst_mret_o),
        .inst_dret_i(ex_inst_dret_o),
        .inst_addr_i(ie_dec_pc_o),
        .mtvec_i(csr_mtvec_o),
        .mepc_i(csr_mepc_o),
        .mstatus_i(csr_mstatus_o),
        .mie_i(csr_mie_o),
        .dpc_i(csr_dpc_o),
        .dcsr_i(csr_dcsr_o),
        .trigger_match_i(csr_trigger_match_o),
        .irq_software_i(irq_software_i),
        .irq_timer_i(irq_timer_i),
        .irq_external_i(irq_external_i),
        .irq_fast_i(irq_fast_i),
        .debug_halt_addr_i(DEBUG_HALT_ADDR),
        .debug_req_i(debug_req_i),
        .csr_we_o(clint_csr_we_o),
        .csr_waddr_o(clint_csr_waddr_o),
        .csr_wdata_o(clint_csr_wdata_o),
        .stall_flag_o(clint_stall_flag_o),
        .int_addr_o(clint_int_addr_o),
        .int_assert_o(clint_int_assert_o)
    );

`ifdef TRACE_ENABLED
    tracer u_tracer(
        .clk(clk),
        .rst_n(rst_n),
        .inst_i(ie_inst_o),
        .pc_i(ie_dec_pc_o),
        .inst_valid_i(ex_inst_valid_o)
    );
`endif

endmodule