# AGXLayout

视图自动布局.

##### Components

- AGXLayoutConstraint

    变换函数类, 用于自适应UIView的某一维度的变换式定义.

##### Categories

- UIView+AGXLayout

```objective-c
// 使用点语法构造布局约束
-viewAs(UIView*)
-leftAs(id)
-rightAs(id)
-topAs(id)
-bottomAs(id)
-widthAs(id)
-heightAs(id)
-centerXAs(id)
-centerYAs(id)

// 构造自适应UIView
// 依据view.bounds自适应frame
// 可设置约束:
//   1. left
//   2. right
//   3. top
//   4. bottom
//   5. width
//   6. height
//   7. centerX
//   8. centerY
// 适应方式为:
//   1. margin默认为0
//   2. width/height默认为view的width/height减去同坐标轴上的margin
//   3. 根据leftMargin&width&rightMargin计算frame.origin.x & frame.size.width
//   4. 根据topMargin&height&bottomMargin计算frame.origin.y & frame.size.height
//   5. 当设置center值时, 使用设置的center值替代上述计算中的中间值center
//   6. 当同坐标轴上的尺寸和留白都设置时, width&height保持原始设置值, 等量增减双向的margin进行缩放以适应view.bounds

PS: 可用于定义约束的类型有:
- NSNumber及其子类(转换为CGFloat类型)
- AGXConstraint及其子类(取出block传入view计算结果)
- NSExpression及其子类(expressionValueWithObject:view, 获得结果的CGFloat值)
- NSString及其子类([NSExpression expressionWithParametricFormat:transform]获得NSExpression对象, 按NSExpression及其子类进行计算)
```
