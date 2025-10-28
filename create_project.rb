require 'xcodeproj'

# 创建项目
project = Xcodeproj::Project.new('ios/RNHybrid.xcodeproj')

# 创建组
main_group = project.main_group
sources_group = main_group['RNHybrid'] || main_group.new_group('RNHybrid')
test_group = main_group['RNHybridTests'] || main_group.new_group('RNHybridTests')

# 添加源文件
app_delegate_h = sources_group.new_file('RNHybrid/AppDelegate.h')
app_delegate_mm = sources_group.new_file('RNHybrid/AppDelegate.mm')

# 创建应用程序目标
app_target = project.new_target(:application, 'RNHybrid', :ios, '12.4')
app_target.add_file_references([app_delegate_h, app_delegate_mm])

# 添加框架
frameworks_group = main_group['Frameworks'] || main_group.new_group('Frameworks')

# 创建测试目标
test_target = project.new_target(:unit_test_bundle, 'RNHybridTests', :ios, '12.4')

# 保存项目
project.save()

puts "Xcode project created successfully"