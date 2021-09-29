#include <stdint.h>

#include "../../bsp/include/uart.h"
#include "../../bsp/include/xprintf.h"
#include "../../bsp/include/pinmux.h"


int main()
{
    // UART0引脚配置
    pinmux_set_io0_func(IO0_UART0_TX);
    pinmux_set_io3_func(IO3_UART0_RX);
    // UART0初始化
    uart_init(UART0, uart0_putc);

    while (1) {
        // loopback
        xprintf("%c", uart0_getc());
    }
}
