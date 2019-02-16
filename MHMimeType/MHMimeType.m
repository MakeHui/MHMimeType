//
//  MHMimeType.m
//  MHMimeTypeDemo
//
//  Created by MakeHui on 2018/5/14.
//  Copyright © 2018年 MakeHui. All rights reserved.
//

#import "MHMimeType.h"

@interface MHMimeTypeModel ()

/**
 Number of bytes required for `MimeType` to be able to check if the
 given bytes match with its mime type magic number specifications.
 */
@property(nonatomic, assign)NSUInteger bytesCount;


/**
 A function to check if the bytes match the `MimeType` specifications.
 */
@property(nonatomic, copy)MHMimeTypeMatchesBlock matchesBlock;

@end

@implementation MHMimeTypeModel

- (instancetype)initWithMime:(NSString *)mime ext:(NSString *)ext type:(MHMimeTypeFileType)type bytesCount:(NSUInteger)bytesCount matchesBlock:(MHMimeTypeMatchesBlock)matchesBlock
{
    self = [super init];
    if (self) {
        self.mime = mime;
        self.ext = ext;
        self.type = type;
        self.bytesCount = bytesCount;
        self.matchesBlock = matchesBlock;
    }
    return self;
}

@end



@interface MHMimeType ()

@property(nonatomic, strong)NSData *data;

@property(nonatomic, strong)NSArray<MHMimeTypeModel *> *mimeTypeModelArray;

@end

@implementation MHMimeType

+ (instancetype)sharedInstance
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

+ (instancetype)initWithData:(NSData *)data
{
    MHMimeType *mimeType = [MHMimeType new];
    mimeType.data = data;
    [mimeType parse];
    
    return mimeType;
}

+ (instancetype)initWithURL:(NSURL *)url
{
    MHMimeType *mimeType = [MHMimeType new];
    mimeType.data = [[NSData alloc] initWithContentsOfURL:url];
    [mimeType parse];
    
    return mimeType;
}

+ (instancetype)initWithPath:(NSString *)path
{
    MHMimeType *mimeType = [MHMimeType new];
    mimeType.data = [[NSData alloc] initWithContentsOfURL:[[NSURL alloc] initWithString:path]];
    [mimeType parse];
    
    return mimeType;
}

- (MHMimeTypeModel *)mimeTypeModelWithData:(NSData *)data
{
    return [self parse];
}

- (MHMimeTypeModel *)mimeTypeModelWithURL:(NSURL *)url
{
    self.data = [[NSData alloc] initWithContentsOfURL:url];
    return [self parse];
}

- (MHMimeTypeModel *)mimeTypeModelWithPath:(NSString *)path
{
    self.data = [[NSData alloc] initWithContentsOfURL:[[NSURL alloc] initWithString:path]];
    return [self parse];
}

- (MHMimeTypeModel *)parse
{
    if (!self.data) {
        return nil;
    }
    
    UInt8 bytes[262];
    [self.data getBytes:&bytes length:262];
    
    self.currentMimeTypeModel = nil;
    for (MHMimeTypeModel *model in self.mimeTypeModelArray) {
        if (model.matchesBlock(bytes, model)) {
            self.currentMimeTypeModel = model;
            break;
        }
    }
    
    return self.currentMimeTypeModel;
}

- (NSArray<MHMimeTypeModel *> *)mimeTypeModelArray
{
    if (_mimeTypeModelArray == nil) {
        NSMutableArray<MHMimeTypeModel *> *array = [NSMutableArray array];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"image/jpeg" ext:@"jpg" type:MHMimeTypeFileTypeJpg bytesCount:3 matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"image/png" ext:@"png" type:MHMimeTypeFileTypePng bytesCount:3 matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"image/gif" ext:@"gif" type:MHMimeTypeFileTypeGif bytesCount:3 matchesBlock:^BOOL(UInt8 *bytes,  MHMimeTypeModel *model) {
            return (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"image/webp" ext:@"webp" type:MHMimeTypeFileTypeWebp bytesCount:12 matchesBlock:^BOOL(UInt8 *bytes,  MHMimeTypeModel *model) {
            return (bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"image/flif" ext:@"flif" type:MHMimeTypeFileTypeFlif bytesCount:4  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x46 && bytes[1] == 0x4C && bytes[2] == 0x49 && bytes[3] == 0x46);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"image/x-canon-cr2" ext:@"cr2" type:MHMimeTypeFileTypeCr2 bytesCount:10  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return ((bytes[0] == 0x49 && bytes[1] == 0x49 && bytes[2] == 0x2A && bytes[3] == 0x00)
            || (bytes[0] == 0x4D && bytes[1] == 0x4D && bytes[2] == 0x00 && bytes[3] == 0x2A)) && (bytes[8] == 0x43 && bytes[9] == 0x52);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"image/tiff" ext:@"tif" type:MHMimeTypeFileTypeTif bytesCount:4  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return ((bytes[0] == 0x49 && bytes[1] == 0x49 && bytes[2] == 0x2A && bytes[3] == 0x00)
                    || (bytes[0] == 0x4D && bytes[1] == 0x4D && bytes[2] == 0x00 && bytes[3] == 0x2A));
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"image/bmp" ext:@"bmp" type:MHMimeTypeFileTypeBmp bytesCount:2  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x42 && bytes[1] == 0x4D);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"image/vnd.ms-photo" ext:@"jxr" type:MHMimeTypeFileTypeJxr bytesCount:3  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x49 && bytes[1] == 0x49 && bytes[2] == 0xBC);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"image/vnd.adobe.photoshop" ext:@"psd" type:MHMimeTypeFileTypePsd bytesCount:4  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x38 && bytes[1] == 0x42 && bytes[2] == 0x50 && bytes[3] == 0x53);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/epub+zip" ext:@"epub" type:MHMimeTypeFileTypeEpub bytesCount:58  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x50 && bytes[1] == 0x4B && bytes[2] == 0x03 && bytes[3] == 0x04)
            && (bytes[30] == 0x6D && bytes[31] == 0x69 && bytes[32] == 0x6D && bytes[33] == 0x65
                && bytes[34] == 0x74 && bytes[35] == 0x79 && bytes[36] == 0x70 && bytes[37] == 0x65
                && bytes[38] == 0x61 && bytes[39] == 0x70 && bytes[40] == 0x70 && bytes[41] == 0x6C
                && bytes[42] == 0x69 && bytes[43] == 0x63 && bytes[44] == 0x61 && bytes[45] == 0x74
                && bytes[46] == 0x69 && bytes[47] == 0x6F && bytes[48] == 0x6E && bytes[49] == 0x2F
                && bytes[50] == 0x65 && bytes[51] == 0x70 && bytes[52] == 0x75 && bytes[53] == 0x62
                && bytes[54] == 0x2B && bytes[55] == 0x7A && bytes[56] == 0x69 && bytes[57] == 0x70);
        }]];

        // Needs to be before `zip` check
        // assumes signed .xpi from addons.mozilla.org
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/x-xpinstall" ext:@"xpi" type:MHMimeTypeFileTypeXpi bytesCount:50  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x50 && bytes[1] == 0x4B && bytes[2] == 0x03 && bytes[3] == 0x04) &&
            (bytes[30] == 0x4D && bytes[31] == 0x45 && bytes[32] == 0x54 && bytes[33] == 0x41 &&
             bytes[34] == 0x2D && bytes[35] == 0x49 && bytes[36] == 0x4E && bytes[37] == 0x46 &&
             bytes[38] == 0x2F && bytes[39] == 0x6D && bytes[40] == 0x6F && bytes[41] == 0x7A &&
             bytes[42] == 0x69 && bytes[43] == 0x6C && bytes[44] == 0x6C && bytes[45] == 0x61 &&
             bytes[46] == 0x2E && bytes[47] == 0x72 && bytes[48] == 0x73 && bytes[49] == 0x61);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/zip" ext:@"zip" type:MHMimeTypeFileTypeZip bytesCount:50  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x50 && bytes[1] == 0x4B) &&
            (bytes[2] == 0x3 || bytes[2] == 0x5 || bytes[2] == 0x7) &&
            (bytes[3] == 0x4 || bytes[3] == 0x6 || bytes[3] == 0x8);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/x-tar" ext:@"tar" type:MHMimeTypeFileTypeTar bytesCount:262  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[257] == 0x75 && bytes[258] == 0x73 && bytes[259] == 0x74 && bytes[260] == 0x61 && bytes[261] == 0x72);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/x-rar-compressed" ext:@"rar" type:MHMimeTypeFileTypeRar bytesCount:7  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x52 && bytes[1] == 0x61 && bytes[2] == 0x72 && bytes[3] == 0x21 && bytes[4] == 0x1A && bytes[5] == 0x07) &&
            (bytes[6] == 0x0 || bytes[6] == 0x1);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/gzip" ext:@"gz" type:MHMimeTypeFileTypeGz bytesCount:3  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x1F && bytes[1] == 0x8B && bytes[2] == 0x08);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/x-bzip2" ext:@"bz2" type:MHMimeTypeFileTypeBz2 bytesCount:3  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x42 && bytes[1] == 0x5A && bytes[2] == 0x68);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/x-7z-compressed" ext:@"7z" type:MHMimeTypeFileTypeSevenZ bytesCount:6  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x37 && bytes[1] == 0x7A && bytes[2] == 0xBC && bytes[3] == 0xAF && bytes[4] == 0x27 && bytes[5] == 0x1C);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/x-apple-diskimage" ext:@"dmg" type:MHMimeTypeFileTypeDmg bytesCount:2  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x78 && bytes[1] == 0x01);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"video/mp4" ext:@"mp4" type:MHMimeTypeFileTypeMp4 bytesCount:28  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return ((bytes[0] == 0x00 && bytes[1] == 0x00 && bytes[2] == 0x00) && (bytes[3] == 0x18 || bytes[3] == 0x20) && (bytes[4] == 0x66 && bytes[5] == 0x74 && bytes[6] == 0x79 && bytes[7] == 0x70)) ||
            (bytes[0] == 0x33 && bytes[1] == 0x67 && bytes[2] == 0x70 && bytes[3] == 0x35) ||
            ((bytes[0] == 0x00 && bytes[1] == 0x00 && bytes[2] == 0x00 && bytes[3] == 0x1C &&
             bytes[4] == 0x66 && bytes[5] == 0x74 && bytes[6] == 0x79 && bytes[7] == 0x70 &&
             bytes[8] == 0x6D && bytes[9] == 0x70 && bytes[10] == 0x34 && bytes[11] == 0x32) &&
             (bytes[16] == 0x6D && bytes[17] == 0x70 && bytes[18] == 0x34 && bytes[19] == 0x31 &&
              bytes[20] == 0x6D && bytes[21] == 0x70 && bytes[22] == 0x34 && bytes[23] == 0x32 &&
              bytes[24] == 0x69 && bytes[25] == 0x73 && bytes[26] == 0x6F && bytes[27] == 0x6D)) ||
            (bytes[0] == 0x00 && bytes[1] == 0x00 && bytes[2] == 0x00 && bytes[3] == 0x1C &&
              bytes[4] == 0x66 && bytes[5] == 0x74 && bytes[6] == 0x79 && bytes[7] == 0x70 &&
              bytes[8] == 0x69 && bytes[9] == 0x73 && bytes[10] == 0x6F && bytes[11] == 0x6D) ||
             (bytes[0] == 0x00 && bytes[1] == 0x00 && bytes[2] == 0x00 && bytes[3] == 0x1C &&
              bytes[4] == 0x66 && bytes[5] == 0x74 && bytes[6] == 0x79 && bytes[7] == 0x70 &&
              bytes[8] == 0x6D && bytes[9] == 0x70 && bytes[10] == 0x34 && bytes[11] == 0x32);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"video/x-m4v" ext:@"m4v" type:MHMimeTypeFileTypeM4v bytesCount:11  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x00 && bytes[1] == 0x00 && bytes[2] == 0x00 && bytes[3] == 0x1C &&
                    bytes[4] == 0x66 && bytes[5] == 0x74 && bytes[6] == 0x79 && bytes[7] == 0x70 &&
                    bytes[8] == 0x4D && bytes[9] == 0x34 && bytes[10] == 0x56);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"audio/midi" ext:@"mid" type:MHMimeTypeFileTypeMid bytesCount:4  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x4D && bytes[1] == 0x54 && bytes[2] == 0x68 && bytes[3] == 0x64);
        }]];

        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"video/x-matroska" ext:@"mkv" type:MHMimeTypeFileTypeMkv bytesCount:4 matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            if (! (bytes[0] == 0x1A && bytes[1] == 0x45 && bytes[2] == 0xDF && bytes[3] == 0xA3)) {
                return false;
            }
            
            NSInteger idPos = -1;
            UInt8 _bytes[4100];
            [self.data getBytes:&_bytes length:4100];
            for (int i = 0; i < 4100; ++i) {
                if (_bytes[i] == 0x42 &&  _bytes[i + 1] == 0x82) {
                    idPos =  i;
                    break;
                }
            }
            
            if (idPos <= -1) {
                return false;
            }
            
            NSInteger docTypePos = idPos + 3;
            NSString *type = @"matroska";
            for (int i = 0; i < type.length; ++i) {
                unichar scalars = [type characterAtIndex:i];
                if (_bytes[docTypePos + i] != scalars) {
                    return false;
                }
            }
            
            return true;
        }]];

        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"video/webm" ext:@"webm" type:MHMimeTypeFileTypeWebm bytesCount:4 matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            if (! (bytes[0] == 0x1A && bytes[1] == 0x45 && bytes[2] == 0xDF && bytes[3] == 0xA3)) {
                return false;
            }
            
            NSInteger idPos = -1;
            UInt8 _bytes[4100];
            [self.data getBytes:&_bytes length:4100];
            for (int i = 0; i < 4100; ++i) {
                if (_bytes[i] == 0x42 &&  _bytes[i + 1] == 0x82) {
                    idPos =  i;
                    break;
                }
            }
            
            if (idPos <= -1) {
                return false;
            }
            
            NSInteger docTypePos = idPos + 3;
            NSString *type = @"webm";
            for (int i = 0; i < type.length; ++i) {
                unichar scalars = [type characterAtIndex:i];
                if (_bytes[docTypePos + i] != scalars) {
                    return false;
                }
            }
            
            return true;
        }]];

        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"video/quicktime" ext:@"mov" type:MHMimeTypeFileTypeMov bytesCount:8  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x00 && bytes[1] == 0x00 && bytes[2] == 0x00 && bytes[3] == 0x14 && bytes[4] == 0x66 && bytes[5] == 0x74 && bytes[6] == 0x79 && bytes[7] == 0x70);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"video/x-msvideo" ext:@"avi" type:MHMimeTypeFileTypeAvi bytesCount:11  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return ((bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46) && (bytes[8] == 0x41 && bytes[9] == 0x56 && bytes[10] == 0x49));
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"video/x-ms-wmv" ext:@"wmv" type:MHMimeTypeFileTypeWmv bytesCount:10  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x30 && bytes[1] == 0x26 && bytes[2] == 0xB2 && bytes[3] == 0x75 &&
                    bytes[4] == 0x8E && bytes[5] == 0x66 && bytes[6] == 0xCF && bytes[7] == 0x11 &&
                    bytes[8] == 0xA6 && bytes[9] == 0xD9);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"video/mpeg" ext:@"mpg" type:MHMimeTypeFileTypeMpg bytesCount:4  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            if (! (bytes[0] == 0x00 && bytes[1] == 0x00 && bytes[2] == 0x01)) {
                return false;
            }
            NSString *hexCode = [NSString stringWithFormat:@"%2X", bytes[3]];
            return hexCode.length && [[hexCode substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"B"];
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"audio/mpeg" ext:@"mp3" type:MHMimeTypeFileTypeMp3 bytesCount:3  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x49 && bytes[1] == 0x44 && bytes[2] == 0x33) || (bytes[0] == 0xFF && bytes[1] == 0xFB);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"audio/m4a" ext:@"m4a" type:MHMimeTypeFileTypeM4a bytesCount:11  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x4D && bytes[1] == 0x34 && bytes[2] == 0x41 && bytes[3] == 0x20) ||
            (bytes[4] == 0x66 && bytes[5] == 0x74 && bytes[6] == 0x79 && bytes[7] == 0x70 &&
             bytes[8] == 0x4D && bytes[9] == 0x34 && bytes[10] == 0x41);
        }]];
        
        // Needs to be before `ogg` check
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"audio/opus" ext:@"opus" type:MHMimeTypeFileTypeOpus bytesCount:36  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[28] == 0x4F && bytes[29] == 0x70 && bytes[30] == 0x75 && bytes[31] == 0x73 &&
                    bytes[32] == 0x48 && bytes[33] == 0x65 && bytes[34] == 0x61 && bytes[35] == 0x64);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"audio/ogg" ext:@"ogg" type:MHMimeTypeFileTypeOgg bytesCount:4  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x4F && bytes[1] == 0x67 && bytes[2] == 0x67 && bytes[3] == 0x53);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"audio/x-flac" ext:@"flac" type:MHMimeTypeFileTypeFlac bytesCount:4  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x66 && bytes[1] == 0x4C && bytes[2] == 0x61 && bytes[3] == 0x43);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"audio/x-wav" ext:@"wav" type:MHMimeTypeFileTypeWav bytesCount:12  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46) ||
            (bytes[8] == 0x57 && bytes[9] == 0x41 && bytes[10] == 0x56 && bytes[11] == 0x45);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"audio/amr" ext:@"amr" type:MHMimeTypeFileTypeAmr bytesCount:6  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x23 && bytes[1] == 0x21 && bytes[2] == 0x41 && bytes[3] == 0x4D && bytes[4] == 0x52 && bytes[5] == 0x0A);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/pdf" ext:@"pdf" type:MHMimeTypeFileTypePdf bytesCount:4  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/x-msdownload" ext:@"exe" type:MHMimeTypeFileTypeExe bytesCount:2  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x4D && bytes[1] == 0x5A);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/x-shockwave-flash" ext:@"swf" type:MHMimeTypeFileTypeSwf bytesCount:3  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return  (bytes[0] == 0x43 || bytes[0] == 0x46) && (bytes[1] == 0x57 && bytes[2] == 0x53);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/rtf" ext:@"rtf" type:MHMimeTypeFileTypeRtf bytesCount:5  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x7B && bytes[1] == 0x5C && bytes[2] == 0x72 && bytes[3] == 0x74 && bytes[4] == 0x66);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/font-woff" ext:@"woff" type:MHMimeTypeFileTypeWoff bytesCount:8  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x77 && bytes[1] == 0x4F && bytes[2] == 0x46 && bytes[3] == 0x46) &&
            ((bytes[4] == 0x00 && bytes[5] == 0x01 && bytes[6] == 0x00 && bytes[7] == 0x00) ||
             (bytes[4] == 0x4F && bytes[5] == 0x54 && bytes[6] == 0x54 && bytes[7] == 0x4F));
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/font-woff" ext:@"woff2" type:MHMimeTypeFileTypeWoff2 bytesCount:8  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x77 && bytes[1] == 0x4F && bytes[2] == 0x46 && bytes[3] == 0x32) &&
            ((bytes[4] == 0x00 && bytes[5] == 0x01 && bytes[6] == 0x00 && bytes[7] == 0x00) ||
             (bytes[4] == 0x4F && bytes[5] == 0x54 && bytes[6] == 0x54 && bytes[7] == 0x4F));
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/octet-stream" ext:@"eot" type:MHMimeTypeFileTypeEot bytesCount:11  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[34] == 0x4C && bytes[35] == 0x50) &&
            ((bytes[8] == 0x00 && bytes[9] == 0x00 && bytes[10] == 0x01) ||
             (bytes[8] == 0x01 && bytes[9] == 0x00 && bytes[10] == 0x02) ||
             (bytes[8] == 0x02 && bytes[9] == 0x00 && bytes[10] == 0x02));
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/font-sfnt" ext:@"ttf" type:MHMimeTypeFileTypeTtf bytesCount:5  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x00 && bytes[1] == 0x01 && bytes[2] == 0x00 && bytes[3] == 0x00 && bytes[4] == 0x00);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/font-sfnt" ext:@"otf" type:MHMimeTypeFileTypeOtf bytesCount:5  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x4F && bytes[1] == 0x54 && bytes[2] == 0x54 && bytes[3] == 0x4F && bytes[4] == 0x00);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"image/x-icon" ext:@"ico" type:MHMimeTypeFileTypeIco bytesCount:4  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x00 && bytes[1] == 0x00 && bytes[2] == 0x01 && bytes[3] == 0x00);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"video/x-flv" ext:@"flv" type:MHMimeTypeFileTypeFlv bytesCount:4  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x46 && bytes[1] == 0x4C && bytes[2] == 0x56 && bytes[3] == 0x01);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/postscript" ext:@"ps" type:MHMimeTypeFileTypePs bytesCount:2  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x25 && bytes[1] == 0x21);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/x-xz" ext:@"xz" type:MHMimeTypeFileTypeXz bytesCount:6  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0xFD && bytes[1] == 0x37 && bytes[2] == 0x7A && bytes[3] == 0x58 && bytes[4] == 0x5A && bytes[5] == 0x00);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/x-sqlite3" ext:@"sqlite" type:MHMimeTypeFileTypeSqlite bytesCount:4  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x53 && bytes[1] == 0x51 && bytes[2] == 0x4C && bytes[3] == 0x69);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/x-nintendo-nes-rom" ext:@"nes" type:MHMimeTypeFileTypeNes bytesCount:4  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x4E && bytes[1] == 0x45 && bytes[2] == 0x53 && bytes[3] == 0x1A);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/x-google-chrome-extension" ext:@"crx" type:MHMimeTypeFileTypeCrx bytesCount:4  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x43 && bytes[1] == 0x72 && bytes[2] == 0x32 && bytes[3] == 0x34);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/vnd.ms-cab-compressed" ext:@"cab" type:MHMimeTypeFileTypeCab bytesCount:4  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x4D && bytes[1] == 0x53 && bytes[2] == 0x43 && bytes[3] == 0x46) ||
            (bytes[0] == 0x49 && bytes[1] == 0x53 && bytes[2] == 0x63 && bytes[3] == 0x28);
        }]];
        
        // Needs to be before `ar` check
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/x-deb" ext:@"deb" type:MHMimeTypeFileTypeDeb bytesCount:21  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x21 && bytes[1] == 0x3C && bytes[2] == 0x61 && bytes[3] == 0x72 &&
                    bytes[4] == 0x63 && bytes[5] == 0x68 && bytes[6] == 0x3E && bytes[7] == 0x0A &&
                    bytes[8] == 0x64 && bytes[9] == 0x65 && bytes[10] == 0x62 && bytes[11] == 0x69 &&
                    bytes[12] == 0x61 && bytes[13] == 0x6E && bytes[14] == 0x2D && bytes[15] == 0x62 &&
                    bytes[16] == 0x69 && bytes[17] == 0x6E && bytes[18] == 0x61 && bytes[19] == 0x72 && bytes[20] == 0x79);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/x-unix-archive" ext:@"ar" type:MHMimeTypeFileTypeAr bytesCount:7  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x21 && bytes[1] == 0x3C && bytes[2] == 0x61 && bytes[3] == 0x72 && bytes[4] == 0x63 && bytes[5] == 0x68 && bytes[6] == 0x3E);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/x-rpm" ext:@"rpm" type:MHMimeTypeFileTypeRpm bytesCount:4  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0xED && bytes[1] == 0xAB && bytes[2] == 0xEE && bytes[3] == 0xDB);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/x-compress" ext:@"Z" type:MHMimeTypeFileTypeZ bytesCount:2  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return ((bytes[0] == 0x1F && bytes[1] == 0xA0) || (bytes[0] == 0x1F && bytes[1] == 0x9D));
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/x-lzip" ext:@"lz" type:MHMimeTypeFileTypeLz bytesCount:4  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x4C && bytes[1] == 0x5A && bytes[2] == 0x49 && bytes[3] == 0x50);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/x-msi" ext:@"msi" type:MHMimeTypeFileTypeMsi bytesCount:8  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0xD0 && bytes[1] == 0xCF && bytes[2] == 0x11 && bytes[3] == 0xE0 && bytes[4] == 0xA1 && bytes[5] == 0xB1 && bytes[6] == 0x1A && bytes[7] == 0xE1);
        }]];
        
        [array addObject:[[MHMimeTypeModel alloc] initWithMime:@"application/mxf" ext:@"mxf" type:MHMimeTypeFileTypeMxf bytesCount:14  matchesBlock:^BOOL(UInt8 *bytes, MHMimeTypeModel *model) {
            return (bytes[0] == 0x06 && bytes[1] == 0x0E && bytes[2] == 0x2B && bytes[3] == 0x34 &&
                    bytes[4] == 0x02 && bytes[5] == 0x05 && bytes[6] == 0x01 && bytes[7] == 0x01 &&
                    bytes[8] == 0x0D && bytes[9] == 0x01 && bytes[10] == 0x02 && bytes[11] == 0x01 &&
                    bytes[12] == 0x01 && bytes[13] == 0x02);
        }]];

        _mimeTypeModelArray = [NSArray arrayWithArray:array];
    }
    
    return _mimeTypeModelArray;
}

@end
