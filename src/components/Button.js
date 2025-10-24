import React from 'react';
import {
  TouchableOpacity,
  Text,
  StyleSheet,
} from 'react-native';

const CustomButton = ({title, onPress, style, textStyle}) => {
  const handlePress = () => {
    // 添加轻微的延迟，让点击反馈更自然
    requestAnimationFrame(() => {
      onPress && onPress();
    });
  };

  return (
    <TouchableOpacity
      style={[styles.button, style]}
      onPress={handlePress}
      activeOpacity={0.7} // 点击时的透明度变化
      onPressIn={() => {
        // 点击按下的反馈
      }}
      onPressOut={() => {
        // 点击释放的反馈
      }}>
      <Text style={[styles.buttonText, textStyle]}>{title}</Text>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  button: {
    backgroundColor: '#2196F3',
    paddingVertical: 12,
    paddingHorizontal: 20,
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
    // 添加阴影效果
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3,
    // 添加边框
    borderWidth: 1,
    borderColor: 'rgba(33, 150, 243, 0.3)',
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
    // 添加文字阴影
    textShadowColor: 'rgba(0, 0, 0, 0.1)',
    textShadowOffset: {
      width: 0,
      height: 1,
    },
    textShadowRadius: 1,
  },
});

export default CustomButton;
