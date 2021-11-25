 /*                                                                      
 Copyright 2020 Blue Liang, liangkangnan@163.com
                                                                         
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

// 取指模块
module ifu #(
    parameter bit          BranchPredictor      = 1'b1
    )(

    input wire                      clk,
    input wire                      rst_n,

    input wire                      flush_i,      // 冲刷标志
    input wire[31:0]                flush_addr_i, // 冲刷地址
    input wire[`STALL_WIDTH-1:0]    stall_i,      // 流水线暂停标志
    input wire                      id_ready_i,   // ID模块可以接收指令

    // to ifu_idu
    output wire[31:0]               inst_o,
    output wire[31:0]               pc_o,
    output wire                     inst_valid_o,

    // 指令总线信号
    output wire                     instr_req_o,
    input  wire                     instr_gnt_i,
    input  wire                     instr_rvalid_i,
    output wire[31:0]               instr_addr_o,
    input  wire[31:0]               instr_rdata_i,
    input  wire                     instr_err_i

    );

// 从(Nor)Flash启动(非易失)
`ifdef FLASH_BOOT

    localparam S_RESET    = 3'b001;
    localparam S_FETCH    = 3'b010;
    localparam S_VALID    = 3'b100;

    reg[2:0] state_d, state_q;

    wire inst_valid;
    wire[31:0] fetch_addr_n;
    reg[31:0] fetch_addr_q;

    wire prdt_taken;
    wire[31:0] prdt_addr;


    always @ (*) begin
        state_d = state_q;

        case (state_q)
            // 复位
            S_RESET: begin
                // 复位撤销后转到取指状态
                if (rst_n) begin
                    state_d = S_FETCH;
                end
            end

            // 取指
            S_FETCH: begin
                // 取指有效
                if (instr_gnt_i & (~stall_i[`STALL_IF]) & (~flush_i)) begin
                    state_d = S_VALID;
                end
            end

            // 指令有效
            S_VALID: begin
                // 回到取指状态
                if (stall_i[`STALL_IF] || instr_rvalid_i || flush_i) begin
                    state_d = S_FETCH;
                end
            end

            default: ;
        endcase
    end

    // 指令有效
    assign inst_valid   = (state_q == S_VALID) & instr_rvalid_i & id_ready_i;
    assign inst_valid_o = inst_valid;
    // 指令无效时有nop指令代替
    assign inst_o       = inst_valid ? instr_rdata_i: `INST_NOP;
    assign pc_o         = fetch_addr_q;

    // 更新取指地址
    assign fetch_addr_n = flush_i            ? flush_addr_i:
                          prdt_taken         ? prdt_addr:
                          inst_valid         ? fetch_addr_q + 4'h4:
                          fetch_addr_q;

    // 取指请求
    assign instr_req_o  = (~stall_i[`STALL_IF]) & (state_q == S_FETCH) & (~flush_i);
    // 取指地址(4字节对齐)
    assign instr_addr_o = {fetch_addr_q[31:2], 2'b00};

    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_q <= S_RESET;
            fetch_addr_q <= `CPU_RESET_ADDR;
        end else begin
            state_q <= state_d;
            fetch_addr_q <= fetch_addr_n;
        end
    end

    // 分支预测
    if (BranchPredictor) begin: g_branch_predictor
        bpu u_bpu(
            .clk(clk),
            .rst_n(rst_n),
            .inst_i(instr_rdata_i),
            .inst_valid_i(inst_valid),
            .pc_i(fetch_addr_q),
            .prdt_taken_o(prdt_taken),
            .prdt_addr_o(prdt_addr)
        );
    end else begin: g_no_branch_predictor
        assign prdt_taken = 1'b0;
        assign prdt_addr  = 32'h0;
    end

// 从Rom启动(易失)
`else

    localparam S_RESET    = 3'b001;
    localparam S_FETCH    = 3'b010;
    localparam S_VALID    = 3'b100;

    reg[2:0] state_d, state_q;

    wire inst_valid;
    wire req_valid;
    wire[31:0] fetch_addr_n;
    reg[31:0] fetch_addr_q;

    wire prdt_taken;
    wire[31:0] prdt_addr;

    // 取指请求有效
    assign req_valid = instr_gnt_i & (~stall_i[`STALL_IF]);

    // 状态切换
    // 取指模块需要实现连续不断地取指，因此
    // 在S_FETCH和S_VALID这两个状态都要进行取指操作
    always @ (*) begin
        state_d = state_q;

        case (state_q)
            // 复位
            S_RESET: begin
                // 复位撤销后转到取指状态
                if (rst_n) begin
                    state_d = S_FETCH;
                end
            end
            // 取指
            S_FETCH: begin
                // 取指有效
                if (req_valid) begin
                    state_d = S_VALID;
                end
            end
            // 指令有效
            S_VALID: begin
                // 取指无效
                if (~req_valid) begin
                    state_d = S_FETCH;
                end
            end

            default: ;
        endcase
    end

    // 指令有效
    assign inst_valid   = (state_q == S_VALID) & instr_rvalid_i & id_ready_i;
    assign inst_valid_o = inst_valid;
    // 指令无效时有nop指令代替
    assign inst_o       = inst_valid ? instr_rdata_i: `INST_NOP;
    assign pc_o         = fetch_addr_q;

    // 更新取指地址
    assign fetch_addr_n = flush_i            ? flush_addr_i:
                          prdt_taken         ? prdt_addr:
                          //stall_i[`STALL_IF] ? fetch_addr_q:
                          inst_valid         ? fetch_addr_q + 4'h4:
                          fetch_addr_q;

    // 取指请求
    assign instr_req_o  = (~stall_i[`STALL_IF]) & (state_q != S_RESET);
    // 取指地址(4字节对齐)
    assign instr_addr_o = {fetch_addr_n[31:2], 2'b00};

    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_q <= S_RESET;
            fetch_addr_q <= `CPU_RESET_ADDR;
        end else begin
            state_q <= state_d;
            // 取指有效时保存当前取指地址
            if (req_valid | flush_i) begin
                fetch_addr_q <= fetch_addr_n;
            end
        end
    end

    // 分支预测
    if (BranchPredictor) begin: g_branch_predictor
        bpu u_bpu(
            .clk(clk),
            .rst_n(rst_n),
            .inst_i(instr_rdata_i),
            .inst_valid_i(inst_valid),
            .pc_i(fetch_addr_q),
            .prdt_taken_o(prdt_taken),
            .prdt_addr_o(prdt_addr)
        );
    end else begin: g_no_branch_predictor
        assign prdt_taken = 1'b0;
        assign prdt_addr  = 32'h0;
    end

`endif

endmodule
