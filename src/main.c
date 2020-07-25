#include "hal/stm32/stm32f10x.h"
#include "rtos/include/FreeRTOS.h"
#include "rtos/include/task.h"

void led_task_on(void *pvParameters)
{
    const uint32_t time = (uint32_t)pvParameters;
    for (;;)
    {
        uint32_t cnt = time;
        GPIOC->BRR |= 1 << 13;
        while(cnt--);
        vTaskDelay(time);
        cnt = time;
        GPIOC->BSRR |= 1 << 13;
        while(cnt--);
        vTaskDelay(time);
    }
    vTaskDelete( NULL );
}

void led_task_off(void *pvParameters)
{
    //const uint32_t time = (uint32_t)pvParameters;
    for (;;)
    {
        //uint32_t cnt = time;
        //GPIOC->BRR |= 1 << 13;
       // while(cnt--);
        //vTaskDelay(time);
        //cnt = time;
        GPIOC->BSRR |= 1 << 13;
        //while(cnt--);
        //vTaskDelay(time);
    }
    vTaskDelete( NULL );
}

int main(void)
{
    RCC->APB2ENR |= RCC_APB2ENR_IOPCEN;

    GPIOC->CRH |= GPIO_CRL_MODE5_1;

    GPIOC->BSRR |= 1 << 13;

    static StackType_t xStack_1[ configMINIMAL_STACK_SIZE ];
    static StackType_t xStack_2[ configMINIMAL_STACK_SIZE ];

    static StaticTask_t xTaskBuffer1;
    static StaticTask_t xTaskBuffer2;

    xTaskCreateStatic(led_task_on,
                    "LED_TASK_1",
                    configMINIMAL_STACK_SIZE,
                    (void *)300,
                    tskIDLE_PRIORITY + 2,
                    xStack_1,
                    &xTaskBuffer1);
    /*
    xTaskCreateStatic(led_task_off,
                "LED_TASK_2",
                configMINIMAL_STACK_SIZE,
                NULL,
                tskIDLE_PRIORITY + 2,
                xStack_2,
                &xTaskBuffer2);
*/
    vTaskStartScheduler();

    for(;;);

    return 0;
}
