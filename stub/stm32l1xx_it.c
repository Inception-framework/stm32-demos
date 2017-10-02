/**
  ******************************************************************************
  * @file    GPIO/GPIO_EXTI/Src/stm32l1xx_it.c
  * @author  MCD Application Team
  * @brief   Main Interrupt Service Routines.
  *          This file provides template for all exceptions handler and
  *          peripherals interrupt service routine.
  ******************************************************************************
  * @attention
  *
  * <h2><center>&copy; COPYRIGHT(c) 2017 STMicroelectronics</center></h2>
  *
  * Redistribution and use in source and binary forms, with or without modification,
  * are permitted provided that the following conditions are met:
  *   1. Redistributions of source code must retain the above copyright notice,
  *      this list of conditions and the following disclaimer.
  *   2. Redistributions in binary form must reproduce the above copyright notice,
  *      this list of conditions and the following disclaimer in the documentation
  *      and/or other materials provided with the distribution.
  *   3. Neither the name of STMicroelectronics nor the names of its contributors
  *      may be used to endorse or promote products derived from this software
  *      without specific prior written permission.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
  * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  *
  ******************************************************************************
  */

/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "stm32l1xx_it.h"

/** @addtogroup STM32L1xx_HAL_Examples
  * @{
  */

/** @addtogroup GPIO_EXTI
  * @{
  */

/* Private typedef -----------------------------------------------------------*/
/* Private define ------------------------------------------------------------*/
/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/

/* Private function prototypes -----------------------------------------------*/
/* Private functions ---------------------------------------------------------*/

/******************************************************************************/
/*            Cortex-M3 Processor Exceptions Handlers                         */
/******************************************************************************/

/**
  * @brief  This function handles the communication with the fpga.
  * @param  interrupt ID
  * @retval None
  */
void GLOBAL_HANDLER(unsigned id)
{ 
  __disable_irq();
  BSP_LED_On(LED2);
  HAL_GPIO_WritePin(GPIOC,GPIO_PIN_10, GPIO_PIN_SET);
  *id_ptr = id;
  IDs[id]=1;
  while(HAL_GPIO_ReadPin(GPIOC,GPIO_PIN_12) == GPIO_PIN_RESET);
  BSP_LED_Off(LED2);
  HAL_GPIO_WritePin(GPIOC,GPIO_PIN_10, GPIO_PIN_RESET);
  __enable_irq();
  
  while(IDs[id]!=0); //wait for ack from klee (klee handler returns)
}

#define CREATE_HANDLER(f, id, ...)                                                \
void f(void) {                \
 GLOBAL_HANDLER(id);          \
}

CREATE_HANDLER(Reset_Handler, 1);
CREATE_HANDLER(NMI_Handler, 2);

void HardFault_Handler(void)
{
  GLOBAL_HANDLER(3);          
  /* Go to infinite loop when Hard Fault exception occurs */
  while (1)
  {
  }
}

void MemManage_Handler(void)
{
  GLOBAL_HANDLER(4);          
  /* Go to infinite loop when Memory Manage exception occurs */
  while (1)
  {
  }
}

void BusFault_Handler(void)
{
  GLOBAL_HANDLER(5);          
  /* Go to infinite loop when Bus Fault exception occurs */
  while (1)
  {
  }
}

void UsageFault_Handler(void)
{
  GLOBAL_HANDLER(6);          
  /* Go to infinite loop when Usage Fault exception occurs */
  while (1)
  {
  }
}

CREATE_HANDLER(SVC_Handler, 11);
CREATE_HANDLER(DebugMon_Handler, 12);
CREATE_HANDLER(PendSV_Handler, 14);
CREATE_HANDLER(SysTick_Handler, 15);
CREATE_HANDLER(WWDG_IRQHandler, 16);
CREATE_HANDLER(PVD_IRQHandler, 17);
CREATE_HANDLER(TAMPER_STAMP_IRQHandler, 18);
CREATE_HANDLER(RTC_WKUP_IRQHandler, 19);
CREATE_HANDLER(FLASH_IRQHandler, 20);
CREATE_HANDLER(RCC_IRQHandler, 21);
CREATE_HANDLER(EXTI0_IRQHandler, 22);
CREATE_HANDLER(EXTI1_IRQHandler, 23);
CREATE_HANDLER(EXTI2_IRQHandler, 24);
CREATE_HANDLER(EXTI3_IRQHandler, 25);
CREATE_HANDLER(EXTI4_IRQHandler, 26);
CREATE_HANDLER(DMA1_Channel1_IRQHandler, 27);
CREATE_HANDLER(DMA1_Channel2_IRQHandler, 28);
CREATE_HANDLER(DMA1_Channel3_IRQHandler, 29);
CREATE_HANDLER(DMA1_Channel4_IRQHandler, 30);
CREATE_HANDLER(DMA1_Channel5_IRQHandler, 31);
CREATE_HANDLER(DMA1_Channel6_IRQHandler, 32);
CREATE_HANDLER(DMA1_Channel7_IRQHandler, 33);
CREATE_HANDLER(ADC1_IRQHandler, 34);
CREATE_HANDLER(USB_HP_IRQHandler, 35);
CREATE_HANDLER(USB_LP_IRQHandler, 36);
CREATE_HANDLER(DAC_IRQHandler, 37);
CREATE_HANDLER(COMP_IRQHandler, 38);
CREATE_HANDLER(EXTI9_5_IRQHandler, 39);
CREATE_HANDLER(LCD_IRQHandler, 40);
CREATE_HANDLER(TIM9_IRQHandler, 41);
CREATE_HANDLER(TIM10_IRQHandler, 42);
CREATE_HANDLER(TIM11_IRQHandler, 43);
CREATE_HANDLER(TIM2_IRQHandler, 44);
CREATE_HANDLER(TIM3_IRQHandler, 45);
CREATE_HANDLER(TIM4_IRQHandler, 46);
CREATE_HANDLER(I2C1_EV_IRQHandler, 47);
CREATE_HANDLER(I2C1_ER_IRQHandler, 48);
CREATE_HANDLER(I2C2_EV_IRQHandler, 49);
CREATE_HANDLER(I2C2_ER_IRQHandler, 50);
CREATE_HANDLER(SPI1_IRQHandler, 51);
CREATE_HANDLER(SPI2_IRQHandler, 52);
CREATE_HANDLER(USART1_IRQHandler, 53);
CREATE_HANDLER(USART2_IRQHandler, 54);
CREATE_HANDLER(USART3_IRQHandler, 55);
CREATE_HANDLER(EXTI15_10_IRQHandler, 56);
CREATE_HANDLER(RTC_Alarm_IRQHandler, 57);
CREATE_HANDLER(USB_FS_WKUP_IRQHandler, 58);
CREATE_HANDLER(TIM6_IRQHandler, 59);
CREATE_HANDLER(TIM7_IRQHandler, 60);
CREATE_HANDLER(TIM5_IRQHandler, 62);
CREATE_HANDLER(SPI3_IRQHandler, 63);
CREATE_HANDLER(UART4_IRQHandler, 64);
CREATE_HANDLER(UART5_IRQHandler, 65);
CREATE_HANDLER(DMA2_Channel1_IRQHandler, 66);
CREATE_HANDLER(DMA2_Channel2_IRQHandler, 67);
CREATE_HANDLER(DMA2_Channel3_IRQHandler, 68);
CREATE_HANDLER(DMA2_Channel4_IRQHandler, 69);
CREATE_HANDLER(DMA2_Channel5_IRQHandler, 70);
CREATE_HANDLER(COMP_ACQ_IRQHandler, 72);
CREATE_HANDLER(BootRAM, 78);
