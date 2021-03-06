// Copyright 2020 XMOS LIMITED. This Software is subject to the terms of the 
// XMOS Public License: Version 1

#if defined(__XS3A__)


/*  
void fc_deepin_shallowout_16(
    const int8_t* W, 
    const int32_t* B,
    const int8_t* X, 
    int16_t* Y,
    const int32_t C_out, 
    const int32_t C_in,
    const uint16_t* shifts, 
    const int16_t* scales);
*/

#ifndef NN_USE_REF
  #define FUNCTION_NAME fc_deepin_shallowout_16
#else
  #define FUNCTION_NAME fc_deepin_shallowout_16_asm
#endif //NN_USE_REF

#define NSTACKWORDS  16
    
.text
.issue_mode  dual
.globl FUNCTION_NAME
.align 4
.type FUNCTION_NAME,@function
.cc_top FUNCTION_NAME.function,FUNCTION_NAME

#define                  nop
    
#define W               r0
#define B               r1
#define X               r2
#define Y               r3
#define C_out           r4
#define C_in            r5
#define shifts          r6
#define scales          r7

#define _32             r8

#define STACK_TMP_VEC   8

.align 8


FUNCTION_NAME:
    dualentsp NSTACKWORDS
    std r4, r5, sp[0]
    std r6, r7, sp[1]
    std r8, r9, sp[2]
    {   ldc r8, 32                               ;   stw r10, sp[6]                      }
    {                                            ;   ldw C_in, sp[NSTACKWORDS+2]         }
    {   shr C_in, C_in, 5                        ;   ldw C_out, sp[NSTACKWORDS+1]        }
    {                                            ;   ldw shifts, sp[NSTACKWORDS+3]       }
    {                                            ;   ldw scales, sp[NSTACKWORDS+4]       }
    {   ldaw r11, sp[STACK_TMP_VEC]              ;                                       }
    {                                            ;   vclrdr                              }
    {                                            ;   vstr r11[0]                         }
    {                                            ;   bf C_out, .Lfunc_end                }


.L_row_top_aligned:
    {   shl r11, _32, 4                         ;                                        }
    {   ldc r9, 1                               ;   vsetc r11                           }
    {   ldaw r11, sp[STACK_TMP_VEC]             ;   ld16s r10, B[r9]                    }
    {   ldc r9, 0                               ;                                        }
    st16 r10, r11[r9]
    {                                            ;   vldd r11[0]                         }
    {   add B, B, 4                             ;   ld16s r10, B[r9]                    }
    st16 r10, r11[r9]
    {   mov r10, C_in                           ;   vldr r11[0]                         }
    {   mov r9, X                               ;   stw r9, r11[0]                      }
    
.L_maccA:
    {   add r9, r9, _32                         ;   vldc r9[0]                          }
    {   sub r10, r10, 1                         ;   vlmaccr W[0]                        }
    {   add W, W, _32                           ;   bt r10, .L_maccA                    }

.L_maccA_end:
    {   shl r11, _32, 3                         ;   vadddr                              }
    {   ldc r10, 3                              ;   vsetc r11                           }
    {   sub C_out, C_out, 1                     ;   vlsat shifts[0]                     }
    {                                            ;   vlmul scales[0]                     }
    vstrpv Y[0], r10
    {                                            ;   bf C_out, .Lfunc_end                }
    
.L_row_top_unaligned:
    {   shl r11, _32, 4                         ;                                        }
    {   ldc r9, 1                               ;   vsetc r11                           }
    {   ldaw r11, sp[STACK_TMP_VEC]             ;   ld16s r10, B[r9]                    }
    {   ldc r9, 0                               ;                                        }
    st16 r10, r11[r9]
    {                                            ;   vldd r11[0]                         }
    {   add B, B, 4                             ;   ld16s r10, B[r9]                    }
    st16 r10, r11[r9]
    {   mov r10, C_in                           ;   vldr r11[0]                         }
    {   mov r9, X                               ;   stw r9, r11[0]                      }
    
.L_maccB:
    {   add r9, r9, _32                         ;   vldc r9[0]                          }
    {   sub r10, r10, 1                         ;   vlmaccr W[0]                        }
    {   add W, W, _32                           ;   bt r10, .L_maccB                    }

.L_maccB_end:
    {   ldc r10, 0xC                            ;   vadddr                              }
    {   shl r11, _32, 3                         ;   vlmaccr r11[0]                      }
    {   sub C_out, C_out, 1                     ;   vsetc r11                           }
    {   add shifts, shifts, 4                   ;   vlsat shifts[0]                     }
    {   add scales, scales, 4                   ;   vlmul scales[0]                     }
    vstrpv Y[0], r10
    {   add Y, Y, 4                             ;   bt C_out, .L_row_top_aligned        }

.Lfunc_end:
    {                                            ;   ldw r10, sp[6]                      }
    ldd r8, r9, sp[2]
    ldd r6, r7, sp[1]
    ldd r4, r5, sp[0]
    retsp NSTACKWORDS

    .cc_bottom FUNCTION_NAME.function
    .set FUNCTION_NAME.nstackwords,NSTACKWORDS
    .globl FUNCTION_NAME.nstackwords
    .set FUNCTION_NAME.maxcores,1
    .globl FUNCTION_NAME.maxcores
    .set FUNCTION_NAME.maxtimers,0
    .globl FUNCTION_NAME.maxtimers
    .set FUNCTION_NAME.maxchanends,0
    .globl FUNCTION_NAME.maxchanends
.Ltmp0:
    .size FUNCTION_NAME, .Ltmp0-FUNCTION_NAME
    .issue_mode  single

#endif



