/*
 *  DebugIncludes.h
 *  eyeconmacosx
 *
 *  Created by Andrea Cremaschi on 31/10/10.
 *  Copyright 2010 AndreaCremaschi. All rights reserved.
 *
 */

#define	myMasterSwitch	( 0 )

#if		myMasterSwitch
#define	myLog1(x)	NSLog(x)
#define	myLog2(x,y)	NSLog(x,y)
#else
#define	myLog1(x)
#define	myLog2(x,y)
#endif