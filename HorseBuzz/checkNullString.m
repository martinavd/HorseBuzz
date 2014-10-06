//
//  checkNullString.m
//  Bimbadgen
//
//  Created by Ritheesh Koodalil on 19/04/13.
//  Copyright (c) 2013 Santhosh Raj Sundaram. All rights reserved.
//

#import "checkNullString.h"

@implementation checkNullString

-(NSString *)checkString:(NSString *)str{
    
    if((str != ( id ) [ NSNull null ]) && (![str isEqualToString:@"<null>"]) && ([str length] >0)){
        return str;
        
    }
    else{
        return @"";
    }
    
}

-(BOOL)IsEmptyOrNull:(NSString *)str{
    
    if((str != ( id ) [ NSNull null ]) && (![str isEqualToString:@"<null>"]) && ([str length] >0)){
        return FALSE;
        
    }
    else{
        return TRUE;
    }
    
}
@end
