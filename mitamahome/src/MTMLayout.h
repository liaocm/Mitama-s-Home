//
//  MTMLayout.h
//  libmitamaui
//
//  Created by Chengming Liao on 7/2/20.
//  Copyright © 2020 Chengming Liao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define MTMActivateLayout(...) \
  [NSLayoutConstraint activateConstraints:@[__VA_ARGS__]]

#define MTMActivateLayoutArray(LayoutArray) \
[NSLayoutConstraint activateConstraints:LayoutArray]

static inline NSLayoutConstraint *
  MTMConstraint(id view,
                id _Nullable otherView,
                NSLayoutAttribute first,
                NSLayoutAttribute second,
                NSLayoutRelation relation,
                CGFloat mul,
                CGFloat constant)
{
  NSLayoutConstraint *constraint =
  [NSLayoutConstraint
   constraintWithItem:view
   attribute:first
   relatedBy:relation
   toItem:otherView
   attribute:second
   multiplier:mul
   constant:constant];
  constraint.priority = UILayoutPriorityRequired - 1;
  return constraint;
}

static inline NSLayoutConstraint *MTMConstraintAbove(id viewAbove, id view, CGFloat padding)
{
  return MTMConstraint(viewAbove, view, NSLayoutAttributeBottom, NSLayoutAttributeTop, NSLayoutRelationEqual, 1, -padding);
}

static inline NSLayoutConstraint *MTMConstraintBelow(id viewBelow, id view, CGFloat padding)
{
  return MTMConstraint(viewBelow, view, NSLayoutAttributeTop, NSLayoutAttributeBottom, NSLayoutRelationEqual, 1, padding);
}

static inline NSLayoutConstraint *MTMConstraintLeft(id viewLeft, id view, CGFloat padding)
{
  return MTMConstraint(viewLeft, view, NSLayoutAttributeTrailing, NSLayoutAttributeLeading, NSLayoutRelationEqual, 1, -padding);
}

static inline NSLayoutConstraint *MTMConstraintRight(id viewRight, id view, CGFloat padding)
{
  return MTMConstraint(viewRight, view, NSLayoutAttributeLeading, NSLayoutAttributeTrailing, NSLayoutRelationEqual, 1, padding);
}

static inline NSLayoutConstraint *MTMConstraintAboveFlexShrink(id viewAbove, id view, CGFloat padding)
{
  return MTMConstraint(viewAbove, view, NSLayoutAttributeBottom, NSLayoutAttributeTop, NSLayoutRelationLessThanOrEqual, 1, -padding);
}

static inline NSLayoutConstraint *MTMConstraintBelowFlexShrink(id viewBelow, id view, CGFloat padding)
{
  return MTMConstraint(viewBelow, view, NSLayoutAttributeTop, NSLayoutAttributeBottom, NSLayoutRelationLessThanOrEqual, 1, padding);
}

static inline NSLayoutConstraint *MTMConstraintLeftFlexShrink(id viewLeft, id view, CGFloat padding)
{
  return MTMConstraint(viewLeft, view, NSLayoutAttributeTrailing, NSLayoutAttributeLeading, NSLayoutRelationLessThanOrEqual, 1, -padding);
}

static inline NSLayoutConstraint *MTMConstraintRightFlexShrink(id viewRight, id view, CGFloat padding)
{
  return MTMConstraint(viewRight, view, NSLayoutAttributeLeading, NSLayoutAttributeTrailing, NSLayoutRelationLessThanOrEqual, 1, padding);
}

static inline NSLayoutConstraint *MTMSetHeight(id view, CGFloat height)
{
  return MTMConstraint(view, nil, NSLayoutAttributeHeight, NSLayoutAttributeNotAnAttribute, NSLayoutRelationEqual, 1, height);
}

static inline NSLayoutConstraint *MTMSetWidth(id view, CGFloat width)
{
  return MTMConstraint(view, nil, NSLayoutAttributeWidth, NSLayoutAttributeNotAnAttribute, NSLayoutRelationEqual, 1, width);
}

static inline NSLayoutConstraint *MTMSetMinHeight(id view, CGFloat height)
{
  return MTMConstraint(view, nil, NSLayoutAttributeHeight, NSLayoutAttributeNotAnAttribute, NSLayoutRelationGreaterThanOrEqual, 1, height);
}

static inline NSLayoutConstraint *MTMSetMinWidth(id view, CGFloat width)
{
  return MTMConstraint(view, nil, NSLayoutAttributeWidth, NSLayoutAttributeNotAnAttribute, NSLayoutRelationGreaterThanOrEqual, 1, width);
}

static inline NSLayoutConstraint *MTMMatchTop(id view, id reference, CGFloat padding)
{
  return MTMConstraint(view, reference, NSLayoutAttributeTop, NSLayoutAttributeTop, NSLayoutRelationEqual, 1, padding);
}

static inline NSLayoutConstraint *MTMMatchBottom(id view, id reference, CGFloat padding)
{
  return MTMConstraint(view, reference, NSLayoutAttributeBottom, NSLayoutAttributeBottom, NSLayoutRelationEqual, 1, -padding);
}

static inline NSLayoutConstraint *MTMMatchLeft(id view, id reference, CGFloat padding)
{
  return MTMConstraint(view, reference, NSLayoutAttributeLeading, NSLayoutAttributeLeading, NSLayoutRelationEqual, 1, padding);
}

static inline NSLayoutConstraint *MTMMatchRight(id view, id reference, CGFloat padding)
{
  return MTMConstraint(view, reference, NSLayoutAttributeTrailing, NSLayoutAttributeTrailing, NSLayoutRelationEqual, 1, -padding);
}

static inline NSLayoutConstraint *MTMMatchCenterX(id view, id reference, CGFloat padding)
{
  return MTMConstraint(view, reference, NSLayoutAttributeCenterX, NSLayoutAttributeCenterX, NSLayoutRelationEqual, 1, padding);
}

static inline NSLayoutConstraint *MTMMatchCenterY(id view, id reference, CGFloat padding)
{
  return MTMConstraint(view, reference, NSLayoutAttributeCenterY, NSLayoutAttributeCenterY, NSLayoutRelationEqual, 1, padding);
}

static inline NSLayoutConstraint *MTMMatchHeight(id view, id reference, CGFloat mul)
{
  return MTMConstraint(view, reference, NSLayoutAttributeHeight, NSLayoutAttributeHeight, NSLayoutRelationEqual, mul, 0);
}

static inline NSLayoutConstraint *MTMMatchWidth(id view, id reference, CGFloat mul)
{
  return MTMConstraint(view, reference, NSLayoutAttributeWidth, NSLayoutAttributeWidth, NSLayoutRelationEqual, mul, 0);
}

static inline NSArray<NSLayoutConstraint *> *MTMInsetView(UIView *subview, id superview, UIEdgeInsets insets)
{
  assert(subview.translatesAutoresizingMaskIntoConstraints == NO);
  return @[
    MTMMatchTop(subview, superview, insets.top),
    MTMMatchBottom(subview, superview, insets.bottom),
    MTMMatchLeft(subview, superview, insets.left),
    MTMMatchRight(subview, superview, insets.right)
  ];
}

NS_ASSUME_NONNULL_END
