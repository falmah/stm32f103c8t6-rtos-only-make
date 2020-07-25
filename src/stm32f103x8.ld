/*
 * This file is part of the libopencm3 project.
 *
 * Copyright (C) 2009 Uwe Hermann <uwe@hermann-uwe.de>
 *
 * This library is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * This is a generic linker script for Cortex-M targets using libopencm3.
 *
 * Memory regions MUST be defined in the ld script which includes this one!
 * Example:
*/
MEMORY
{
	rom (rx) : ORIGIN = 0x08000000, LENGTH = 64K
	ram (rwx) : ORIGIN = 0x20000000, LENGTH = 20K
}

/* Enforce emmition of the vector table. */
EXTERN (vector_table)

/* Define the entry point of the output file. */
ENTRY(Reset_Handler)
            
_estack = 0x20005000;

/* Define sections. */
SECTIONS
{
    /* for Cortex devices, the beginning of the startup code is stored in the .isr_vector section, which goes to FLASH */
    .isr_vector :
    {
  . = ALIGN(4);
        KEEP(*(.isr_vector))            /* Startup code */
  . = ALIGN(4);
    } >rom
 
    /* for some STRx devices, the beginning of the startup code is stored in the .flashtext section, which goes to FLASH */
    .flashtext :
    {
  . = ALIGN(4);
        *(.flashtext)            /* Startup code */
  . = ALIGN(4);
    } >rom
 
    
    /* the program code is stored in the .text section, which goes to Flash */
    .text :
    {
      . = ALIGN(4);
      
        *(.text)                   /* remaining code */
        *(.text.*)                   /* remaining code */
        *(.rodata)                 /* read-only data (constants) */
        *(.rodata*)
        *(.glue_7)
        *(.glue_7t)

      . = ALIGN(4);
      _etext = .;
      /* This is used by the startup in order to initialize the .data secion */
      
    } >rom
    
	.init : {
		KEEP (*(.init))
	} > rom

	.fini : {
   		KEEP (*(.fini))
	} > rom
	
	_sidata = .;
    /* This is the initialized data section
    The program executes knowing that the data is in the RAM
    but the loader puts the initial values in the FLASH (inidata).
    It is one task of the startup to copy the initial values from FLASH to RAM. */
    .data  : AT ( _sidata )
    {
      . = ALIGN(4);
        /* This is used by the startup in order to initialize the .data secion */
        _sdata = . ;
        
        *(.data)
        *(.data.*)

      . = ALIGN(4);
      /* This is used by the startup in order to initialize the .data secion */
      _edata = . ;
    } >ram
    
    

    /* This is the uninitialized data section */
    .bss :
    {
      . = ALIGN(4);
        /* This is used by the startup in order to initialize the .bss secion */
        _sbss = .;
        __bss_start__ = .;
        *(.bss)
        *(COMMON)
        
      . = ALIGN(4);
      /* This is used by the startup in order to initialize the .bss secion */
      _ebss = . ;
	  __bss_end__ = .;
    } >ram

	/*
	 * The .eh_frame section appears to be used for C++ exception handling.
	 * You may need to fix this if you're using C++.
	 */
	/*/DISCARD/ : { *(.eh_frame) }*/

	. = ALIGN(4);
	end = .;
}

PROVIDE(_stack = ORIGIN(ram) + LENGTH(ram));

