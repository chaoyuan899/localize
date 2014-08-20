localize
========

本地化字符串
### Use<br />
		0、新建本地化需要的.strings文件，重命名为Localizable.strings
		1、修改.xib上的Label、Button等需要本地化的字符串，在原有的内容前面加多一个^
		2、拖一个Object对象到.xib上，改类名名为TTSLocalizer
		3、为刚才拖得Object对象关联一个变量，使用这个变量可手动本地化需要的任何一个字符串（可选）
		4、NSString * alertMsg = [LanguageUtil localizedStringForKey:@"Email Send Fail,Server problems."];
		5、需要本地化的字符串直接使用上面的函数即可，它会去.strings中找对应的key的value，至于.xib中的字符串，由于有1步骤的修改，会自动去.strings文件中查找对应key的value值，不需要用到4步骤。
		6、某一个.xib需要设置为某种语言时（不跟随系统语言）,需要先做步骤3，然后这样设置即可。
		[LanguageUtil setLanguage:@"de" withLocalizerObject:_ttsUILocalizer];
