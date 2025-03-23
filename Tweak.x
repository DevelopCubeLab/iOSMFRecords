#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

%hook UILabel // 用Flex看了下，就是UILabel 但是有的不是，封装了，能解决数据统计页面就行了，剩下懒得管，爱咋咋地

- (void)setText:(NSString *)text {
    // 判断Label是否包含 kg
    if ([text containsString:@"kg"]) {
        // 匹配带小数点或逗号的 kg 格式 用正则表达式
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([0-9]+[\\.,]?[0-9]*)\\s+kg" options:0 error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:text options:0 range:NSMakeRange(0, text.length)];

        if (match) {
            NSRange numberRange = [match rangeAtIndex:1];
            NSString *kgString = [text substringWithRange:numberRange];

            // 替换逗号为点（欧洲的有些国家显示小数是23,00 kg 不是23.00 kg 所以匹配不上，先转换再说），转 double
            NSString *normalizedKgString = [kgString stringByReplacingOccurrencesOfString:@"," withString:@"."];
            double kg = [normalizedKgString doubleValue];
            double jin = kg * 2.0; // kg到斤直接乘2

            // 转换成斤保留两位小数
            NSString *newText = [NSString stringWithFormat:@"%@ kg (%.2f 斤)", kgString, jin];
            %orig(newText); // 设置修改后的文本
            
            return;
        }
    }

    // 不包含 kg，原样处理
    %orig(text);
}

%end

%hook UIView // hook其余部分，包括首页的，反正官方是一点不想改是吧
//有个bug，就是历史数据里面会显示比前几日下降多少，那个就没了，懒得改了，凑活用吧

- (void)didMoveToSuperview {
    %orig;

    if (self.window) {
        NSMutableArray *stack = [NSMutableArray arrayWithObject:self];
        while (stack.count > 0) {
            UIView *subview = [stack lastObject];
            [stack removeLastObject];

            if ([subview respondsToSelector:@selector(text)] &&
                [subview respondsToSelector:@selector(setText:)]) {
                
                NSString *text = [subview performSelector:@selector(text)];

                if ([text isKindOfClass:[NSString class]] && [text containsString:@"kg"]) {
                    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([0-9]+[\\.,]?[0-9]*)\\s+kg" options:0 error:nil];
                    NSTextCheckingResult *match = [regex firstMatchInString:text options:0 range:NSMakeRange(0, text.length)];

                    if (match) {
                        NSRange numberRange = [match rangeAtIndex:1];
                        NSString *kgString = [text substringWithRange:numberRange];

                        NSString *normalizedKgString = [kgString stringByReplacingOccurrencesOfString:@"," withString:@"."];
                        double kg = [normalizedKgString doubleValue];
                        double jin = kg * 2.0;

                        NSString *newText = [NSString stringWithFormat:@"%@ kg (%.2f 斤)", kgString, jin];
                        [subview performSelector:@selector(setText:) withObject:newText];

                        NSLog(@"[Tweak] Modified pseudo-label: %@", newText);
                    }
                }
            }

            [stack addObjectsFromArray:subview.subviews];
        }
    }
}

%end
