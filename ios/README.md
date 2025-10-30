ios设置应用相关图标：
1. 准备好你的 App Logo 图片，并根据下面的列表，将它制作成9个不同尺寸的 .png 文件。
2. 将这9个图片文件，放入以下目录中：
   /Users/zhaoyudong/IdeaProjects/RNHybrid/ios/RNHybrid/Media.xcassets/AppIcon.appiconset/

所需图标文件列表 (文件名和尺寸):
┌───────────────────────────┬─────────────┐
│ 文件名                    │ 尺寸 (像素) │
├───────────────────────────┼─────────────┤
│ Icon-App-20x20@2x.png     │ 40 x 40     │
│ Icon-App-20x20@3x.png     │ 60 x 60     │
│ Icon-App-29x29@2x.png     │ 58 x 58     │
│ Icon-App-29x29@3x.png     │ 87 x 87     │
│ Icon-App-40x40@2x.png     │ 80 x 80     │
│ Icon-App-40x40@3x.png     │ 120 x 120   │
│ Icon-App-60x60@2x.png     │ 120 x 120   │
│ Icon-App-60x60@3x.png     │ 180 x 180   │
│ Icon-App-1024x1024@1x.png │ 1024 x 1024 │
└───────────────────────────┴─────────────┘
将这些文件放到指定位置后，你重新用 Xcode 编译并运行 App，就可以在模拟器或手机的桌面上看到你设置的图标了。
