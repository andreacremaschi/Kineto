//---------------------------------------------------------------------------
//
//	File: Memory.c
//
//  Abstract: Utilities for memory management.
// 			 
//  Disclaimer: IMPORTANT:  This Apple software is supplied to you by
//  Apple Inc. ("Apple") in consideration of your agreement to the
//  following terms, and your use, installation, modification or
//  redistribution of this Apple software constitutes acceptance of these
//  terms.  If you do not agree with these terms, please do not use,
//  install, modify or redistribute this Apple software.
//  
//  In consideration of your agreement to abide by the following terms, and
//  subject to these terms, Apple grants you a personal, non-exclusive
//  license, under Apple's copyrights in this original Apple software (the
//  "Apple Software"), to use, reproduce, modify and redistribute the Apple
//  Software, with or without modifications, in source and/or binary forms;
//  provided that if you redistribute the Apple Software in its entirety and
//  without modifications, you must retain this notice and the following
//  text and disclaimers in all such redistributions of the Apple Software. 
//  Neither the name, trademarks, service marks or logos of Apple Inc.
//  may be used to endorse or promote products derived from the Apple
//  Software without specific prior written permission from Apple.  Except
//  as expressly stated in this notice, no other rights or licenses, express
//  or implied, are granted by Apple herein, including but not limited to
//  any patent rights that may be infringed by your derivative works or by
//  other works in which the Apple Software may be incorporated.
//  
//  The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
//  MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
//  THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
//  FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
//  OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
//  
//  IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
//  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
//  MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
//  AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
//  STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
// 
//  Copyright (c) 2008 Apple Inc., All rights reserved.
//
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#include <mach/mach.h>

#include "Memory.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

void *VMemAlloc(const vm_size_t size)
{
	GLbyte         *pointer = NULL;
	kern_return_t   err     = KERN_SUCCESS;
	
	// In debug builds, check that we have
	// correct VM page alignment
	
	check(size != 0);
	check((size % 4096) == 0);
	
	// Allocate directly from VM
	
	err = vm_allocate(	(vm_map_t) mach_task_self(),
					  (vm_address_t *)&pointer,
					  size,
					  VM_FLAGS_ANYWHERE );
	
	// Check errors
	
	check(err == KERN_SUCCESS);
	
	if( err != KERN_SUCCESS)
	{
		NSLog(@">> ERROR: Failed to allocate vm memory of size = %lu",size);
		
		pointer = NULL;
	} // if
	
	return pointer;
} // VMemAlloc

//---------------------------------------------------------------------------

void VMemFree(const vm_size_t size, void *pointer)
{
	if ( ( pointer != NULL ) && ( size > 0 ) )
	{
		kern_return_t err = vm_deallocate(	(vm_map_t) mach_task_self(),
										  (vm_address_t)pointer,
										  size );
		
		// Check errors
		
		check(err == KERN_SUCCESS);
		
		if( err != KERN_SUCCESS)
		{
			NSLog(@">> ERROR: Failed to deallocate vm memory of size = %lu",size);
		} // if
	} // if
	else
	{
		NSLog(@">> ERROR: Can't free a NULL vm pointer!");
	} // else
} // VMemFree

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

void *MemAlloc(const size_t size)
{
	GLbyte *pointer = NULL;
	
	if ( size > 0 )
	{
		pointer = malloc( size );
		
		if ( pointer != NULL )
		{
			memset(pointer, 0, size );
		} // if
		else
		{
			NSLog(@">> ERROR: Failed to allocate memory of size = %lu",size);
		} // else
	} // if
	
	return pointer;
} // MemAlloc

//---------------------------------------------------------------------------

void MemFree(void *pointer)
{
	if ( pointer != NULL )
	{
		free( pointer );
		
		pointer = NULL;
	} // if
	else
	{
		NSLog(@">> ERROR: Can't free a NULL pointer!");
	} // else
} // MemFree

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
