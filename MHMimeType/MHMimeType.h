//
//  MHMimeType.h
//  MHMimeTypeDemo
//
//  Created by MakeHui on 2018/5/14.
//  Copyright © 2018年 MakeHui. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 List of type shorthands
 with this enum we can check mime type with addition of swift type checker
 */
typedef NS_ENUM(NSUInteger, MHMimeTypeFileType) {
    MHMimeTypeFileTypeAmr,
    MHMimeTypeFileTypeAr,
    MHMimeTypeFileTypeAvi,
    MHMimeTypeFileTypeBmp,
    MHMimeTypeFileTypeBz2,
    MHMimeTypeFileTypeCab,
    MHMimeTypeFileTypeCr2,
    MHMimeTypeFileTypeCrx,
    MHMimeTypeFileTypeDeb,
    MHMimeTypeFileTypeDmg,
    MHMimeTypeFileTypeEot,
    MHMimeTypeFileTypeEpub,
    MHMimeTypeFileTypeExe,
    MHMimeTypeFileTypeFlac,
    MHMimeTypeFileTypeFlif,
    MHMimeTypeFileTypeFlv,
    MHMimeTypeFileTypeGif,
    MHMimeTypeFileTypeGz,
    MHMimeTypeFileTypeIco,
    MHMimeTypeFileTypeJpg,
    MHMimeTypeFileTypeJxr,
    MHMimeTypeFileTypeLz,
    MHMimeTypeFileTypeM4a,
    MHMimeTypeFileTypeM4v,
    MHMimeTypeFileTypeMid,
    MHMimeTypeFileTypeMkv,
    MHMimeTypeFileTypeMov,
    MHMimeTypeFileTypeMp3,
    MHMimeTypeFileTypeMp4,
    MHMimeTypeFileTypeMpg,
    MHMimeTypeFileTypeMsi,
    MHMimeTypeFileTypeMxf,
    MHMimeTypeFileTypeNes,
    MHMimeTypeFileTypeOgg,
    MHMimeTypeFileTypeOpus,
    MHMimeTypeFileTypeOtf,
    MHMimeTypeFileTypePdf,
    MHMimeTypeFileTypePng,
    MHMimeTypeFileTypePs,
    MHMimeTypeFileTypePsd,
    MHMimeTypeFileTypeRar,
    MHMimeTypeFileTypeRpm,
    MHMimeTypeFileTypeRtf,
    MHMimeTypeFileTypeSevenZ,
    MHMimeTypeFileTypeSqlite,
    MHMimeTypeFileTypeSwf,
    MHMimeTypeFileTypeTar,
    MHMimeTypeFileTypeTif,
    MHMimeTypeFileTypeTtf,
    MHMimeTypeFileTypeWav,
    MHMimeTypeFileTypeWebm,
    MHMimeTypeFileTypeWebp,
    MHMimeTypeFileTypeWmv,
    MHMimeTypeFileTypeWoff,
    MHMimeTypeFileTypeWoff2,
    MHMimeTypeFileTypeXpi,
    MHMimeTypeFileTypeXz,
    MHMimeTypeFileTypeZ,
    MHMimeTypeFileTypeZip,
};

@class MHMimeTypeModel;

typedef BOOL (^MHMimeTypeMatchesBlock)(UInt8 *bytes, MHMimeTypeModel *model);

@interface MHMimeTypeModel : NSObject

/**
 Mime type string representation. For example "application/pdf"
 */
@property(nonatomic, strong)NSString *mime;

/**
 Mime type extension. For example "pdf"
 */
@property(nonatomic, strong)NSString *ext;

/**
 Mime type shorthand representation. For example `.pdf`
 */
@property(nonatomic, assign)MHMimeTypeFileType type;

@end

@interface MHMimeType : NSObject

@property(nonatomic, strong)MHMimeTypeModel *currentMimeTypeModel;

+ (instancetype)initWithData:(NSData *)data;

+ (instancetype)initWithURL:(NSURL *)url;

+ (instancetype)initWithPath:(NSString *)path;

@end
