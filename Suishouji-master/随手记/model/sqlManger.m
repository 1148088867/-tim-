//
//  sqlManger.m
//  layoutDemo
//
//  Created by 何易东 on 16/5/16.
//  Copyright © 2016年 dong. All rights reserved.
//

#import "sqlManger.h"
#define sQName @"sqllite.db"
#define sBlName @"Bill"
#define sCGName @"category"
#define sImage @"image"
#define sBudget @"budget"

@implementation sqlManger


+ (instancetype)dataBaseDefaultManager;
{
    static sqlManger *theManger;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        theManger = [[sqlManger alloc]init];
    });
    return theManger;
}

- (instancetype)init
{
    self.dabase = [FMDatabase databaseWithPath:[self DBpath]];
    self.bil = [[Bill alloc]init];
    self.categ = [[category alloc]init];
    
    if ([self.dabase open]) {
        NSLog(@"打开了数据库");
    }else{
        NSLog(@"打开失败");
    }
    NSString *sqlStr2 = [NSString stringWithFormat:@"create table if not exists %@(categoryID integer primary key, icon text, categoryName text, isOut int, color text)",sCGName];
    if (![self.dabase executeUpdate:sqlStr2]) {
        NSLog(@"创建%@表失败，SQL语句为%@",sCGName,sqlStr2);
        return nil;
    }
    
    NSString *sqlStr1 = [NSString stringWithFormat:@"create table if not exists %@(BillID integer  primary key,  Money double, categoryID integer not null, time text, note text, FOREIGN KEY (categoryID) REFERENCES %@ (categoryID))",sBlName,sCGName];
    if (![self.dabase executeUpdate:sqlStr1]) {
        NSLog(@"创建%@表失败，SQL语句为%@",sBlName,sqlStr1);
        return nil;
    }
    
    NSString *sqlStr3 = [NSString stringWithFormat:@"create table if not exists %@(ImageID integer primary key, backImage blob)",sImage];
    if (![self.dabase executeUpdate:sqlStr3]) {
        NSLog(@"创建%@表失败，SQL语句为%@",sImage,sqlStr3);
        return nil;
    }
    NSString *sqlStr4 = [NSString stringWithFormat:@"create table if not exists %@(budgetID integer primary key autoincrement, budget double)",sBudget];
    if (![self.dabase executeUpdate:sqlStr4]) {
        NSLog(@"创建%@表失败，SQL语句为%@",sBudget,sqlStr4);
        return nil;
    }

    if ([self categoryCount] == 0) {
        [self categorysFromPlist];
    }
    return self;
}

- (NSString *)DBpath
{
    NSArray *dirList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [dirList firstObject];
    
    NSLog(@"数据库路径: %@",path);
    
    return [path stringByAppendingPathComponent:sQName];
}

- (BOOL)addWithTheBill:(Bill *)theBill ///增加账单数据
{
    if (!theBill) {
        NSLog(@"插入数据为空");
        return NO;
    }
        
    NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(BillID, Money, categoryID, time, note) values(?,?,?,?,?)",sBlName];
    BOOL isSuccess = [self.dabase executeUpdate:sqlStr,theBill.BillID, theBill.money, theBill.categoryID, theBill.timeStr, theBill.note];
    if (!isSuccess)
    {
        NSLog(@"%@表插入%@,插入语句是%@,账单时间是%@",sBlName,isSuccess?@"成功":@"失败",sqlStr,theBill.timeStr);
        return NO;
    }
    return YES;
}

- (void)modifyTheBill:(Bill *)theBill ///<修改账单数据
{
    if(!theBill){
        return;
    }
    [self deleteBill:theBill];
    [self addWithTheBill:theBill];
}
//- (NSMutableDictionary *)BillDictionaryOfTime:(NSDate *)date timeStyle:(timeStyle) timeStyle ///<根据日期找到账单字典
//{
//    if (!date) {
//        return nil;
//    }
//    NSString *sqlStr = [self sqlStringFromDate:date timeStyle:timeStyle];
//    
//    
//    FMResultSet *result = [self.dabase executeQuery:sqlStr];
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
//   
//    
//    while ([result next]) {
//        
//        Bill *theBill = [[Bill alloc]init];
//        theBill.BillID = @([result intForColumn :@"BillID"]);
//        theBill.money = @([result doubleForColumn:@"Money"]);
//        theBill.categoryID = @([result intForColumn:@"categoryID"]);
//        theBill.timeStr = [result stringForColumn:@"time"];
//        theBill.note = [result stringForColumn:@"note"];
//        
//        [dic setObject:theBill forKey:theBill.BillID];
//    }
//    
//    return dic;
//}
//


//搜索每天的账单,传过来的是‘xxxx-xx-xx’这种格式
-(NSMutableArray *)readBillMonth:(NSString *)month{
    month=[NSString stringWithFormat:@"'%@'",month];
    NSMutableArray *dic=[[NSMutableArray alloc]init];
    NSString *monthString = @"'%Y-%m-%d'";
    NSString *sqlString=[NSString stringWithFormat:@"select * from %@ where strftime(%@,time)==strftime(%@,%@) order By BillID desc",sBlName,monthString,monthString,month];
    FMResultSet *result = [self.dabase executeQuery:sqlString];
    while ([result next]) {
        Bill *theBill=[[Bill alloc]init];
        theBill.BillID=@([result intForColumn:@"billID"]);
        theBill.categoryID=@([result intForColumn:@"categoryID"]);
        theBill.timeStr=[result stringForColumn:@"time"];
        theBill.money=@([result  doubleForColumn:@"money"]);
        theBill.note = [result stringForColumn:@"note"];
        [dic addObject:theBill];
    }
    return dic;
}

- (NSMutableArray *)allBill
{
    NSMutableArray *billArray = [[NSMutableArray alloc]init]; //存的当前月所有天账单
    NSMutableArray *time = [self selectTimesOfBill]; //存的当前月的所有时间
    for (int i = 0; i < time.count; i++) {
        NSString *timeStr = time[i]; //在根据数据库月的找到当前天数账单
        NSArray *dayBillArray = [self readBillMonth:timeStr];
        [billArray addObjectsFromArray:dayBillArray]; //所有天数账单存入数组
    }
    return billArray;
}

//搜索每天的账单,传过来的是‘xxxx-xx-xx’这种格式
-(NSMutableArray *)readBillMonthNume:(NSString *)month{
    month=[NSString stringWithFormat:@"'%@-01'",month];
    NSMutableArray *dic=[[NSMutableArray alloc]init];
    NSString *monthString = @"'%Y-%m'";
    NSString *sqlString=[NSString stringWithFormat:@"select * from %@, %@ where strftime(%@,time)==strftime(%@,%@) and Bill.categoryID==category.categoryID order By time desc, isOut desc",sBlName,sCGName,monthString,monthString,month];
    FMResultSet *result = [self.dabase executeQuery:sqlString];
    while ([result next]) {
        Bill *theBill=[[Bill alloc]init];
        theBill.BillID=@([result intForColumn:@"billID"]);
        theBill.categoryID=@([result intForColumn:@"categoryID"]);
        theBill.timeStr=[result stringForColumn:@"time"];
        theBill.money=@([result  doubleForColumn:@"money"]);
        [dic addObject:theBill];
    }
    return dic;
}

- (NSMutableArray *)selectBillOfMonth:(NSString *)year{
    NSMutableArray *monthArray=[[NSMutableArray alloc]init];
    NSString *yearString = [NSString stringWithFormat:@"'%@-01-01'",year];
    NSString *timeString=@"'%Y'";
    NSString *monthString = @"'%Y-%m'";
    //遇到的问题时查出来一直提示没有字段名
    //解决方法 as time，查出的字段命名
    NSString *sqlString=[NSString stringWithFormat:@"select distinct strftime(%@,time) as time from bill where strftime(%@,time)==strftime(%@,%@) order By time desc",monthString,timeString,timeString,yearString];
    FMResultSet *result=[self.dabase executeQuery:sqlString];
    while ([result next]) {
        NSString *str = [result stringForColumn:@"time"];
        [monthArray addObject:str];
    }
    return  monthArray;
}

- (NSMutableArray *)readBillWithIsOut:(BOOL)isOut
{
    NSMutableArray *billArray = [[NSMutableArray alloc]init];
    NSString *sqlStr = [NSString stringWithFormat:@"select  billId, money, categoryId, time, note from %@,category where category.isout = %d and bill.categoryid=category.categoryid",sBlName,isOut];
    FMResultSet *result = [self.dabase executeQuery:sqlStr];
    while ([result next]) {
        Bill *theBill=[[Bill alloc]init];
        theBill.BillID=@([result intForColumn:@"billID"]);
        theBill.categoryID=@([result intForColumn:@"categoryID"]);
        theBill.timeStr=[result stringForColumn:@"time"];
        theBill.money=@([result doubleForColumn:@"money"]);
        [billArray addObject:theBill];
    }
    return billArray;
}
- (BOOL)deleteBill:(Bill *) theBill ///<删除账单
{
    NSString *sqlStr = [NSString stringWithFormat:@"delete from %@ where BillID = %@",sBlName,theBill.BillID];
    if (![self.dabase executeUpdate:sqlStr]) {
        NSLog(@"删除失败");
        return NO;
    }else{
        NSLog(@"删除成功");
        return YES;
    }
}

////求账单数 参数：类别ID、时间、时间类别（年、月）
- (NSInteger)billCountOfCategory:(NSNumber *)typeID time:(NSString *)timeStr
{
    if (!timeStr) {
        NSString *sqlStr = [NSString stringWithFormat:@"select  count(*) from %@ where categoryID = %ld",sBlName,typeID.integerValue];
        NSInteger billCount = [self.dabase intForQuery:sqlStr];        
        return billCount;
    }
    
    NSString *sqlStr = [NSString stringWithFormat:@"select  count(*) from %@ where categoryID = %ld and strftime('%%Y-%%m',bill.time) = '%@'",sBlName,typeID.integerValue,timeStr];
    NSInteger billCount = [self.dabase intForQuery:sqlStr];
    return billCount;
    
}

//类别的所有账单
- (NSMutableArray *)allBillOfType:(NSNumber *)typeID
{
    NSMutableArray *billArray = [NSMutableArray array];
    NSString *sqlStr = [NSString stringWithFormat:@"select * from bill where categoryID = %d order by time asc",typeID.intValue];
    FMResultSet *result = [self.dabase executeQuery:sqlStr];
    while ([result next]) {
        Bill *theBill=[[Bill alloc]init];
        theBill.BillID=@([result intForColumn:@"billID"]);
        theBill.categoryID=@([result intForColumn:@"categoryID"]);
        theBill.timeStr=[result stringForColumn:@"time"];
        theBill.money=@([result doubleForColumn:@"money"]);
        [billArray addObject:theBill];
    }
    return billArray;
}


- (NSMutableDictionary *)billDicWithDate
{
    NSMutableDictionary *billDic = [NSMutableDictionary dictionary];
    NSMutableArray *times = [self selectTimesOfBill];
    for (int i = 0; i < times.count; i++) {
        NSString *timeStr = times[i]; //在根据数据库月的找到当前天数账单
        NSArray *dayBillArray = [self readBillMonth:timeStr];
        [billDic setObject:dayBillArray forKey:timeStr];
    }

    return billDic;
}

//查找某个类别某个月的账单记录时间， month 为 nil 查询所有月份的记录时间
- (NSMutableArray *)timesOfBillWithType:(NSNumber *)typeID month:(NSString *)month
{
    NSMutableArray *array = [NSMutableArray array];
    NSString *sqlStr = [NSString stringWithFormat:@"select time from bill where categoryID = %d and strftime('%%Y-%%m',time) = '%@' order by time desc", typeID.intValue, month];
    if (month == nil) {
        sqlStr = [NSString stringWithFormat:@"select time from bill where categoryID = %d order by time desc", typeID.intValue];
    }
    FMResultSet *result = [self.dabase executeQuery:sqlStr];
    while ([result next]) {
        NSString *month = [result stringForColumn:@"time"];
        if (array.count == 0) {
            [array addObject:month];
        }
        else if (![month isEqualToString:array.lastObject])
        {
            [array addObject:month];
        }
    }
    return array;
}
//查找某个类别某个月的账单， month 为 nil 查询所有月份的账单
- (NSMutableDictionary *)billDicOfType:(NSNumber *)typeID Month:(NSString *)month
{
    NSMutableDictionary *billDic = [NSMutableDictionary dictionary];
    
    NSMutableArray *dateArray = [self timesOfBillWithType:typeID month:month];
    for (NSString *date in dateArray) {
        NSString *sqlStr = [NSString stringWithFormat:@"select * from bill where categoryID = %d and time = '%@' order by time desc",typeID.intValue, date];
        FMResultSet *result = [self.dabase executeQuery:sqlStr];
        NSMutableArray *billArray = [NSMutableArray array];
        while ([result next]) {
            Bill *theBill=[[Bill alloc]init];
            theBill.BillID=@([result intForColumn:@"billID"]);
            theBill.categoryID=@([result intForColumn:@"categoryID"]);
            theBill.timeStr=[result stringForColumn:@"time"];
            theBill.money=@([result doubleForColumn:@"money"]);
            theBill.note = [result stringForColumn:@"note"];
            [billArray addObject:theBill];
        }
        [billDic setObject:billArray forKey:date];
    }
    return billDic;
}

#pragma mark category类别
- (BOOL)addTheCategory:(category *)theCategory ///<增加类别数据
{
     if(!theCategory) {
        NSLog(@"插入数据为空");
        return NO;
    }
//    NSNumber *isOut = @(0);
//    isOut = @(theCategory.isOut?:0);
    NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(categoryID, icon, categoryName, isOut, color) values(?,?,?,?,?)",sCGName];
    
    BOOL isSuccess = [self.dabase executeUpdate:sqlStr,theCategory.categoryID, theCategory.iconName, theCategory.categoryName, @(theCategory.isOut), theCategory.categoryColorStr];
    
    if (!isSuccess) {
        NSLog(@"%@表插入%@,插入语句是%@",sCGName,isSuccess?@"成功":@"失败",sqlStr);
        return NO;
    }
    return YES;
    
}

- (NSMutableArray *)readTheCatgory :(BOOL) isOut ///<读取类别数据
{
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where isOut = %d",sCGName,isOut];
    
    FMResultSet *result = [self.dabase executeQuery:sqlStr];
    
    while ([result next]) {
        category *theCategory = [[category alloc]init];
        theCategory.categoryID = @([result intForColumn:@"categoryID"]);
        theCategory.isOut = [result intForColumn:@"isOut"];
        theCategory.iconName = [result stringForColumn:@"icon"];
        theCategory.categoryName = [result stringForColumn:@"categoryName"];
        theCategory.categoryColorStr = [result stringForColumn:@"color"];
        [array addObject:theCategory];
    }
    return  array;
}

- (category *)readCategoryBy:(NSNumber *) categoryID///< 读取单个类别数据
{
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where categoryID = %ld",sCGName,categoryID.integerValue];
    FMResultSet *result = [self.dabase executeQuery:sqlStr,categoryID];
    category *theCategory = [[category alloc]init];
    
    if(!result){
        NSLog(@"读取%@语句失败",sqlStr);
        return nil;
    }else{
        if([result next]){
            
            theCategory.categoryID = @([result intForColumn:@"categoryID"]);
            theCategory.isOut = [result intForColumn:@"isOut"];
            theCategory.iconName = [result stringForColumn:@"icon"];
            theCategory.categoryName = [result stringForColumn:@"categoryName"];
            theCategory.categoryColorStr = [result stringForColumn:@"color"];
        }
    }
    
    return theCategory;
}

- (BOOL)modifyTheCatgory:(category *)theCategory ///<修改类别数据
{
    if(!theCategory){
        [self categoryCount];
        return NO;
    }
     NSString *sqlStr = [NSString stringWithFormat:@"update %@ set icon = ?, categoryName = ?, isOut = ?, color = ? where categoryID = %ld ",sCGName,theCategory.categoryID.integerValue];
    BOOL flag = [self.dabase executeUpdate:sqlStr, theCategory.iconName, theCategory.categoryName, @(theCategory.isOut), theCategory.categoryColorStr];
    return flag;
}
- (BOOL)deleteCatgory:(category *)theCategroy ///<删除类别
{
    NSString *typeIDSql = [NSString stringWithFormat:@"select categoryID from category where categoryname = '一般' and isout = %d",theCategroy.isOut];
    NSInteger typyid = [self.dabase intForQuery:typeIDSql];
    NSMutableArray *billArray = [self allBillOfType:theCategroy.categoryID];
    for (Bill *abill in billArray) {
        abill.categoryID = @(typyid);
        [self modifyTheBill:abill];
    }
    
    NSString *sqlStr = [NSString stringWithFormat:@"delete from %@ where categoryID = %@",sCGName,theCategroy.categoryID];
    
    if (![self.dabase executeUpdate:sqlStr]) {
        NSLog(@"删除失败");
        return NO;
    }else{
        NSLog(@"删除成功");
        return YES;
    }
}

- (int) categoryCount
{
    NSString *sqlStr = [NSString stringWithFormat:@"select count(*) from %@ ",sCGName];
//    NSLog(@"%@",sqlStr);
    return [self.dabase intForQuery:sqlStr];
    
}

- (NSMutableArray *)categoryIdCount{
    NSString *sqlStr = [NSString stringWithFormat:@"select categoryID from %@",sCGName];
    NSMutableArray *array = [NSMutableArray array];
    FMResultSet *result = [self.dabase executeQuery:sqlStr];
    while ([result next]){
        NSInteger catId = [result intForColumn:@"categoryID"];
        [array addObject:@(catId)];
    }
    
    return array;
}

- (void) categorysFromPlist
{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"CategoryList" ofType:@"plist"];
    NSDictionary *categoryDic = [[NSDictionary alloc]initWithContentsOfFile:path];
    NSArray *ID = [categoryDic allKeys];
    for (int i = 0; i < ID.count; i ++) {
        category *cate = [[category alloc]init];
        NSString *categoryID = ID[i];
        cate.categoryID = @(categoryID.intValue);
        NSDictionary  *dic = categoryDic[categoryID];
        NSString *boolstr = dic[@"isOut"];
        cate.isOut = boolstr.boolValue;
//        NSLog(@"%@",dic[@"isOut"]);
        cate.categoryColorStr = dic[@"color"];
        cate.categoryName = dic[@"name"];
        cate.iconName = dic[@"imageName"];
        [self addTheCategory:cate];
    }
}
//按收入支出查找账单已包含的类别
- (NSMutableArray *)billCategorys:(BOOL)isOut time:(NSString *)timeStr
{
    NSString *sqlStr;
    if (timeStr == nil) {
        sqlStr = [NSString stringWithFormat:@"select bill.categoryid from %@,%@ where category.isout = %d and bill.categoryid=category.categoryid order by  bill.categoryid ",sBlName,sCGName,isOut];
    }
    else{
        sqlStr = [NSString stringWithFormat:@"select bill.categoryid from %@,%@ where category.isout = %d and bill.categoryid=category.categoryid and  strftime('%%Y-%%m',bill.time) = '%@' order by  bill.categoryid ",sBlName,sCGName,isOut,timeStr];
    }
    
    FMResultSet *result = [self.dabase executeQuery:sqlStr];
    NSMutableArray *categoryIDs = [[NSMutableArray alloc]init];
    NSMutableArray *categoryArray = [[NSMutableArray alloc]init];
    while ([result next]) {
        NSInteger ID = [result intForColumn:@"categoryID"];
        if (categoryIDs.count < 1) {
            [categoryIDs addObject:@(ID)];
            [categoryArray addObject: [self readCategoryBy:@(ID)]];
        }
        else
        {
            NSNumber *catID = categoryIDs[categoryIDs.count - 1];
            if (catID.integerValue != ID) {
                [categoryIDs addObject:@(ID)];
                [categoryArray addObject: [self readCategoryBy:@(ID)]];
            }
        }
    }
    return categoryArray;
}


#pragma mark - 计算时间
///* timeStyle = 1 :返回当天的时间的timestamp格式,sql查询语句
//   timeStyle = 2 :返回当月的开始、结束时间的timestamp格式,sql查询语句
//   timeStyle = 3 :返回当年的开始、结束时间的timestamp格式,sql查询语句
// */
//- (NSString *) sqlStringFromDate:(NSDate *) date timeStyle:(timeStyle) timeStyle
//{
//    NSString *sqlStr;
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd"];//日期格式
//    
//    NSString *timeStr = [dateFormatter stringFromDate:date];//转换为字符串
//    NSArray *timeStrArray = [timeStr componentsSeparatedByString:@"-"];
//    NSString *startTimeStr;
//    NSString *endTimeStr;
//    switch (timeStyle) {
//        case 1:
//        {
//            NSString *day = timeStrArray[2];
//            startTimeStr = timeStr;
//            endTimeStr = [NSString stringWithFormat:@"%@-%@-%d",timeStrArray[0], timeStrArray[1], day.intValue + 1];
//            NSDate *startDate = [dateFormatter dateFromString:startTimeStr];
//            NSDate *endDate = [dateFormatter dateFromString:endTimeStr];
//            sqlStr = [NSString stringWithFormat:@"select * from %@ where time >= %@ and time < %@",sBlName,@([startDate timeIntervalSince1970]),@([endDate timeIntervalSince1970])];
//            break;
//        }
//        case 2:
//        {
//            [dateFormatter setDateFormat:@"yyyy-MM"];
//            NSString *month = timeStrArray[1];
//            startTimeStr = [NSString stringWithFormat:@"%@-%d",timeStrArray[0],month.intValue ];
//            endTimeStr = [NSString stringWithFormat:@"%@-%d",timeStrArray[0],month.intValue + 1];
//            NSDate *startDate = [dateFormatter dateFromString:startTimeStr];
//            NSDate *endDate = [dateFormatter dateFromString:endTimeStr];
//            sqlStr = [NSString stringWithFormat:@"select * from %@ where time >= %@ and time < %@",sBlName,@([startDate timeIntervalSince1970]),@([endDate timeIntervalSince1970])];
//            
//            break;
//        }
//        default:
//        {
//            [dateFormatter setDateFormat:@"yyyy"];
//            NSString *year = timeStrArray[0];
//            startTimeStr = [NSString stringWithFormat:@"%@",year];
//            endTimeStr = [NSString stringWithFormat:@"%d",year.intValue + 1];
//            NSDate *startDate = [dateFormatter dateFromString:startTimeStr];
//            NSDate *endDate = [dateFormatter dateFromString:endTimeStr];
//            sqlStr = [NSString stringWithFormat:@"select * from %@ where time >= %@ and time < %@",sBlName,@([startDate timeIntervalSince1970]),@([endDate timeIntervalSince1970])];
//        }
//            break;
//    }
//    NSLog(@"%@",sqlStr);
//    return sqlStr;
//}

- (NSMutableArray *)selectTimesOfBill{
    NSMutableArray *timeArray=[[NSMutableArray alloc]init];
    NSString *sqlString=[NSString stringWithFormat:@"select distinct time from Bill order by time desc"];
    FMResultSet *result=[self.dabase executeQuery:sqlString];
    while ([result next]) {
        NSString *time=[result stringForColumn:@"time"];
        [timeArray addObject:time];
    }
    return  timeArray;
}
- (NSMutableArray *)monthOfAllBill
{
    NSMutableArray *timeArray=[[NSMutableArray alloc]init];

    NSString *sqlString=[NSString stringWithFormat:@"select strftime('%%Y-%%m',bill.time) as month from bill order by bill.time asc"];
    FMResultSet *result=[self.dabase executeQuery:sqlString];
    while ([result next]) {
        NSString *time=[result stringForColumn:@"month"];
        if (timeArray.count == 0) {
            [timeArray addObject:time];
        }
        else
        {
            if (![timeArray.lastObject isEqualToString:time]) {
                [timeArray addObject:time];
            }
        }
        
    }
    NSLog(@"timeArray =%@",timeArray);
    return  timeArray;
    
}

#pragma mark Image
- (BOOL )addImage:(UIImage *)theImage{
    if (!theImage) {
        NSLog(@"插入数据为空");
        return NO;
    }
    NSInteger imageID = 1;
    NSData *imageData = UIImagePNGRepresentation(theImage);
    NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(backImage,imageID) values(?,?)",sImage];
    if ([self isHaveImage]) {
        //判断数据库中是否有图片，有：修改图片为当前选择的图片 没：添加当前选择的图片到数据库
        sqlStr = [NSString stringWithFormat:@"update %@ set backImage = ? where imageID = ?",sImage];
    }
    BOOL isSuccess = [self.dabase executeUpdate:sqlStr,imageData,@(imageID)];
    if (!isSuccess)
    {
        NSLog(@"%@表插入或修改失败,语句是%@",sImage,sqlStr);
        return NO;
    }
    
    return YES;
}

- (NSArray *)readImage{
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ order By ImageID desc",sImage];
    FMResultSet *result = [self.dabase executeQuery:sqlStr];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    if (!result) {
        NSLog(@"读取%@语句失败",sqlStr);
        return nil;
    }
    else{
        if ([result next]) {
            UIImage *image = [UIImage imageWithData:[result dataForColumn:@"backImage"]];
            [array addObject:image];
        }
    }
    return array;
}
- (BOOL)isHaveImage
{
    NSString *SqlStr = [NSString stringWithFormat:@"select count(*) from %@",sImage];
    NSInteger count = [self.dabase intForQuery:SqlStr];
    NSLog(@"image Count: %ld",count);
    if (count == 0) {
        return NO;
    }
    return YES;
}

#pragma mark 计算金额
//计算收入支出的总金额
- (NSString *) totalMoney:(BOOL) isOut date:(NSString *)time
{
    if (time == Nil) {
        NSString *sqlStr = [NSString stringWithFormat:@"select  sum(bill.money) from %@,category where category.isout = %d and bill.categoryid=category.categoryid",sBlName,isOut];
        
        float totalMoney = [self.dabase doubleForQuery:sqlStr];
        return  [NSString stringWithFormat:@"%.2f",totalMoney];
    }
    
    NSString *sqlStr = [NSString stringWithFormat:@"select sum(bill.money) from %@,category where category.isout = %d and bill.categoryid=category.categoryid and  strftime('%%Y-%%m',bill.time) = '%@' ",sBlName,isOut,time];
    NSLog(@"%@",sqlStr);
    float totalMoney = [self.dabase doubleForQuery:sqlStr];
    return  [NSString stringWithFormat:@"%.2f",totalMoney];
}

//计算每笔账单的金额占总金额的比例
- (NSMutableArray *)scaleOfBillMoneyFromTotalMoney:(BOOL)isOut date:(NSString *)time
{
    NSMutableArray *scaleArray = [[NSMutableArray alloc]init];
    
    NSMutableArray *categoryArray = [self billCategorys:isOut time:time];
    NSString *totalMoney = [self totalMoney:isOut date:time];
    for (category *cat in categoryArray)
    {
        NSString *sqlStr;
        if (time == nil) {
           sqlStr  = [NSString stringWithFormat:@"select  sum(money) from %@ where categoryID = %ld",sBlName,cat.categoryID.integerValue];
        }
        else
        {
            sqlStr  = [NSString stringWithFormat:@"select  sum(money) from %@ where categoryID = %ld and strftime('%%Y-%%m',time) = '%@'",sBlName,cat.categoryID.integerValue,time];
        }
        
        float categoryMoney = [self.dabase doubleForQuery:sqlStr];
        NSString *scale = [NSString stringWithFormat:@"%f",categoryMoney / totalMoney.floatValue];
        //        NSDictionary *dic = @{scale:cat.categoryColor};
        NSDictionary *dic = @{@"name":cat.categoryName, @"scale":scale, @"color":cat.categoryColor, @"type":cat};
        [scaleArray addObject:dic];
        //        [scaleDic setObject:dic forKey:cat.categoryName];
    }
    return scaleArray;
}
//计算每个类别的总金额
- (float)totalMoneyOfType:(NSNumber *)typeID time:(NSString *)timeStr
{
    if (timeStr == nil) {
        NSString *sqlStr = [NSString stringWithFormat:@"select  sum(money) from %@ where categoryID = %ld ",sBlName,typeID.integerValue];
        float totalMoney = [self.dabase doubleForQuery:sqlStr];
        return  totalMoney;
    }
    NSString *sqlStr = [NSString stringWithFormat:@"select  sum(money) from %@ where categoryID = %ld and strftime('%%Y-%%m',time) = '%@' ",sBlName,typeID.integerValue,timeStr];
    float totalMoney = [self.dabase doubleForQuery:sqlStr];
    return  totalMoney;
}

- (NSMutableArray *)allMoney:(NSString *)string{
    NSMutableArray *all = [NSMutableArray array];
    NSMutableArray *spendArray = [NSMutableArray array];
    NSMutableArray *revenueAmount = [NSMutableArray array];
    NSString *yearString = [NSString stringWithFormat:@"'%@-01-01'",string];
    NSString *monthString = @"'%Y'";
    //遇到的问题时查出来一直提示没有字段名
    //解决方法 as time，查出的字段命名
    NSString *sqlString=[NSString stringWithFormat:@"select * from %@, %@ where strftime(%@,time)==strftime(%@,%@) and Bill.categoryID==category.categoryID order By time desc, isOut desc",sBlName,sCGName,monthString,monthString,yearString];
    FMResultSet *result=[self.dabase executeQuery:sqlString];
    while ([result next]) {
        Bill *theBill = [[Bill alloc]init];
        theBill.money = @([result doubleForColumn:@"Money"]);
        theBill.categoryID = @([result intForColumn:@"categoryID"]);
        category *theCategory = [[sqlManger dataBaseDefaultManager]readCategoryBy:theBill.categoryID];
        if (theCategory.isOut) {
            [spendArray addObject:theBill.money];
        }else{
            [revenueAmount addObject:theBill.money];
        }
    }
    NSNumber *spend = [spendArray valueForKeyPath:@"@sum.floatValue"];
    [all addObject:spend.stringValue];
    NSNumber *revenue = [revenueAmount valueForKeyPath:@"@sum.floatValue"];
    [all addObject:revenue.stringValue];
    return all;
}

- (float)allExpend:(NSMutableArray *)array ///<单个月支出金额
{
    NSNumber *expend = [array valueForKeyPath:@"@sum.floatValue"];
    return expend.floatValue;
}

- (float)allRevenueAmount:(NSMutableArray *)arry ///<所有收入金额
{
    NSNumber *expend = [arry valueForKeyPath:@"@sum.floatValue"];
    return expend.floatValue;
}
- (float)totalMoneyOfBillList:(NSMutableArray *)billArry
{
    float total = 0;
    for (Bill *abill in billArry) {
        total = total + abill.money.floatValue;
    }
    return total;
}
#pragma mark - 预算

- (BOOL )addBudget:(NSNumber *)theBudget{
    NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(budget) values(?)",sBudget];
    BOOL isSuccess = [self.dabase executeUpdate:sqlStr,theBudget];
    if (isSuccess)
    {
        NSLog(@"%@表插入%@,插入语句是%@",sBudget,isSuccess?@"成功":@"失败",sqlStr);
        return YES;
    }
    
    return NO;
}

- (NSArray *)readBudget{
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@",sBudget];
    FMResultSet *result = [self.dabase executeQuery:sqlStr];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    if (!result) {
        NSLog(@"读取%@语句失败",sqlStr);
        return nil;
    }
    else{
        if ([result next]) {
            NSNumber *theBudget = @([result doubleForColumn:@"budget"]);
            [array addObject:theBudget.stringValue];
        }
    }
    return array;
}

- (BOOL)modifyTheBudget:(NSNumber *)theBudget ///<修改预算数据
{
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set budget = ? ",sBudget];
    BOOL flag = [self.dabase executeUpdate:sqlStr, theBudget];
    return flag;
}

@end
