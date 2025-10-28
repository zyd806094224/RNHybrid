#!/usr/bin/env ruby

require 'xcodeproj'

# 打开项目
project_path = 'ios/RNHybrid.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# 获取主target
target = project.targets.first

# 获取主组
main_group = project.main_group

# 找到RNHybrid组
rn_hybrid_group = main_group['RNHybrid']

# 添加文件到项目并获取引用
splash_header = project.new_file('ios/RNHybrid/SplashViewController.h')
splash_implementation = project.new_file('ios/RNHybrid/SplashViewController.m')
main_header = project.new_file('ios/RNHybrid/MainViewController.h')
main_implementation = project.new_file('ios/RNHybrid/MainViewController.m')
rn_header = project.new_file('ios/RNHybrid/RNViewController.h')
rn_implementation = project.new_file('ios/RNHybrid/RNViewController.m')

# 将文件添加到RNHybrid组
rn_hybrid_group << splash_header
rn_hybrid_group << splash_implementation
rn_hybrid_group << main_header
rn_hybrid_group << main_implementation
rn_hybrid_group << rn_header
rn_hybrid_group << rn_implementation

# 将实现文件添加到target的编译阶段
target.add_file_references([splash_implementation, main_implementation, rn_implementation])

# 将头文件添加到target的headers阶段
headers_phase = target.headers_build_phase
headers_phase.add_file_reference(splash_header)
headers_phase.add_file_reference(main_header)
headers_phase.add_file_reference(rn_header)

# 保存项目
project.save()

puts "Files successfully added to the project!"