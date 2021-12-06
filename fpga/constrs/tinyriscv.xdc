# 时钟约束50MHz
# 7020 pl
set_property -dict { PACKAGE_PIN K17 IOSTANDARD LVCMOS33 } [get_ports {clk}]; 
create_clock -add -name sys_clk_pin -period 20.00 -waveform {0 10} [get_ports {clk}];

# 时钟引脚
# 7020 pl
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN K17 [get_ports clk]

# 复位引脚
# 7020 pl
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN E17 [get_ports rst]

# 程序执行完毕指示引脚
set_property IOSTANDARD LVCMOS33 [get_ports over]
set_property PACKAGE_PIN K18 [get_ports over]

# 程序执行成功指示引脚
set_property IOSTANDARD LVCMOS33 [get_ports succ]
set_property PACKAGE_PIN H15 [get_ports succ]

# CPU停住指示引脚
set_property IOSTANDARD LVCMOS33 [get_ports halted_ind]
set_property PACKAGE_PIN J14 [get_ports halted_ind]

# 串口下载使能引脚
set_property IOSTANDARD LVCMOS33 [get_ports uart_debug_pin]
set_property PACKAGE_PIN K14 [get_ports uart_debug_pin]

# 串口发送引脚
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx_pin]
set_property PACKAGE_PIN G20 [get_ports uart_tx_pin]

# 串口接收引脚
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx_pin]
set_property PACKAGE_PIN G19 [get_ports uart_rx_pin]

# GPIO0引脚
set_property IOSTANDARD LVCMOS33 [get_ports {gpio[0]}]
set_property PACKAGE_PIN F19 [get_ports {gpio[0]}]

# GPIO1引脚
set_property IOSTANDARD LVCMOS33 [get_ports {gpio[1]}]
set_property PACKAGE_PIN F20 [get_ports {gpio[1]}]

# JTAG TCK引脚
set_property IOSTANDARD LVCMOS33 [get_ports jtag_TCK]
set_property PACKAGE_PIN J19 [get_ports jtag_TCK]

#create_clock -name jtag_clk_pin -period 300 [get_ports {jtag_TCK}];

# JTAG TMS引脚
set_property IOSTANDARD LVCMOS33 [get_ports jtag_TMS]
set_property PACKAGE_PIN K19 [get_ports jtag_TMS]

# JTAG TDI引脚
set_property IOSTANDARD LVCMOS33 [get_ports jtag_TDI]
set_property PACKAGE_PIN H20 [get_ports jtag_TDI]

# JTAG TDO引脚
set_property IOSTANDARD LVCMOS33 [get_ports jtag_TDO]
set_property PACKAGE_PIN J20 [get_ports jtag_TDO]

# SPI MISO引脚
set_property IOSTANDARD LVCMOS33 [get_ports spi_miso]
set_property PACKAGE_PIN L15 [get_ports spi_miso]

# SPI MOSI引脚
set_property IOSTANDARD LVCMOS33 [get_ports spi_mosi]
set_property PACKAGE_PIN L14 [get_ports spi_mosi]

# SPI SS引脚
set_property IOSTANDARD LVCMOS33 [get_ports spi_ss]
set_property PACKAGE_PIN L17 [get_ports spi_ss]

# SPI CLK引脚
set_property IOSTANDARD LVCMOS33 [get_ports spi_clk]
set_property PACKAGE_PIN M19 [get_ports spi_clk]

set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]  
set_property CONFIG_MODE SPIx4 [current_design] 
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets jtag_TCK_IBUF] 
#自jm2 右下角开始 
#    pin1 k18
#    output reg over,         // 测试是否完成信号
#    pin2 H15
#    output reg succ,         // 测试是否成功信号
#    pin3 J14
#    output wire halted_ind,  // jtag是否已经halt住CPU信号
#    pin4 K14
#    input wire uart_debug_pin, // 串口下载使能引脚
#    pin5 G20
#    output wire uart_tx_pin, // UART发送引脚
#    pin6 G19
#    input wire uart_rx_pin,  // UART接收引脚
#    pin7 F20  pin8 F19
#    inout wire[1:0] gpio,    // GPIO引脚

#    pin13 J19
#    input wire jtag_TCK,     // JTAG TCK引脚
#    pin14 K19
#    input wire jtag_TMS,     // JTAG TMS引脚
#    pin15 H20
#    input wire jtag_TDI,     // JTAG TDI引脚
#    pin16 J20
#    output wire jtag_TDO,    // JTAG TDO引脚

#    pin17 L15
#    input wire spi_miso,     // SPI MISO引脚
#    pin18 L14
#    output wire spi_mosi,    // SPI MOSI引脚
#    pin19 L17
#    output wire spi_ss,      // SPI SS引脚
#    pin20 M19
#    output wire spi_clk      // SPI CLK引脚
