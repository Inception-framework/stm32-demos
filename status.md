## VERSION

Save current version info in /dev/null
Inception
* master
1259c0ee797e2519568cdacf2db97c63693e5e06
+41ea9eaed20e907ff8dfc525bd188c2e6d668a46 Analyzer
(heads/thread_support_rebased)
+545cd2c1094da5e2319c9485b47d0089a3e87e61 Compiler (heads/jtag_basepri)
+bc54198dfca26a0ed44aae78bf29a120e8c4928d Inception-compiler-verif
(heads/master)
+1ee44ad7bf38ce9f59e0f77719e9fc5b8989ce5c RTDebugger (heads/master)
+7524f1371f16fb8230834090d2697e35d1d45018 RTDebugger-driver
(realease_01-79-g7524f13)
+d425fdcf591061e524ed0952ce627774a9818222 Samples (heads/master)
 daf6f5c94d48193b15c0eb2feed56b70717cb4a1 Stubs (heads/master)
 957653d1ea49a7634f98a771fa0a9306ee45caa5 mini-arm-os-demos (heads/master)
+32e5351a77ceb1894241b772050ca9d6d4b48f05 stm32-demos (heads/master)

## RESULTS

### make
1. Examples/GPIO/GPIO_IOToggle_clock: ok
*  Examples/GPIO/GPIO_EXTI_clock: ok
*  Examples/INTERRUPTS: ok

### make FreeRTOS=true
1. Applications/FreeRTOS/FreeRTOS_ThreadCreation_inception: not working (crash
   + we already had some problems that require debugging more
*  Applications/FreeRTOS/FreeRTOS_ThreadCreation_nodelay: ok
*  Applications/FreeRTOS/FreeRTOS_ThreadCreation_simplevuln: not working (crash)

### rm -rf src; make template ...; make DSP=true
1. DSP/SineCosine: broken (compiler crash, unknown)
1. DSP/Matrix: broken (compiler crash, unsupported return type)
1. DSP/GraphicEqualizer: broken (compiler crash, unknown)
1. DSP/FIR: broken (compiler crash, unsupported return type)
