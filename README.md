# Hotspot
热点，公告等跑马灯效果

## 效果展示

![img](https://github.com/zhuzhuxingtianxia/Hotspot/blob/master/videoed.gif)

## ⚠️注意的问题

动画代理采用的是强引用，
```
 @property(nullable, strong) id <CAAnimationDelegate> delegate;
 ```
 这样引起当前的对象无法得到释放，造成内存泄漏问题。
 所以在取消定时器的时候需要把动画代理置为nil,即
 ```
 //防止循环引用
 _flipTransition.delegate = nil;
```
