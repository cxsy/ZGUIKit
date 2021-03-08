//
//  ZGUIViewController.m
//  ZGUIKit
//
//  Created by cxsy on 02/05/2021.
//  Copyright (c) 2021 cxsy. All rights reserved.
//

#import "ZGUIViewController.h"
#import "DemoThemeManager.h"
#import <ZGUIThemeManager.h>
#import <Masonry/Masonry.h>

@interface ZGUIViewController ()

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *changeLightBtn;
@property (nonatomic, strong) UIButton *changeDarkBtn;
@property (nonatomic, strong) UIButton *changeRedBtn;

@end

@implementation ZGUIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupBaseUI {
    _backView = [UIView new];
    [self.view addSubview:_backView];
    
    _scrollView = [UIScrollView new];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrollView];

    _stackView = [UIStackView new];
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.distribution = UIStackViewDistributionEqualSpacing;
    _stackView.alignment = UIStackViewAlignmentCenter;
    _stackView.spacing = 16.f;
    [self.scrollView addSubview:_stackView];
    
    [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(12.f);
        } else {
            make.top.equalTo(self.view).offset(12.f);
        }
        make.bottom.equalTo(self.view).inset(12.f);
        make.left.right.equalTo(self.view);
    }];

    [_stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.centerX.equalTo(self.scrollView);
    }];
}

- (void)setupUI {
    [self setupBaseUI];
    
    _backView.backgroundColor = UIColor.demo_brandColor;
    
    _label = [[UILabel alloc] init];
    _label.textColor = UIColor.demo_text1Color;
    _label.font = [UIFont systemFontOfSize:16.f];
    _label.text = @"文案";
    [self.stackView addArrangedSubview:_label];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.image = UIImage.demo_brandImage;
    [self.stackView addArrangedSubview:_imageView];
    
    _changeLightBtn = [[UIButton alloc] init];
    _changeLightBtn.backgroundColor = UIColor.whiteColor;
    [_changeLightBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [_changeLightBtn setTitle:@"Theme White" forState:UIControlStateNormal];
    [_changeLightBtn addTarget:self
                        action:@selector(onChangeToLightTheme)
              forControlEvents:UIControlEventTouchUpInside];
    [self.stackView addArrangedSubview:_changeLightBtn];
    
    _changeDarkBtn = [[UIButton alloc] init];
    _changeDarkBtn.backgroundColor = UIColor.blackColor;
    [_changeDarkBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_changeDarkBtn setTitle:@"Theme Dark" forState:UIControlStateNormal];
    [_changeDarkBtn addTarget:self
                       action:@selector(onChangeToDarkTheme)
             forControlEvents:UIControlEventTouchUpInside];
    [self.stackView addArrangedSubview:_changeDarkBtn];
    
    _changeRedBtn = [[UIButton alloc] init];
    _changeRedBtn.backgroundColor = UIColor.orangeColor;
    [_changeRedBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [_changeRedBtn setTitle:@"Theme Red" forState:UIControlStateNormal];
    [_changeRedBtn addTarget:self
                      action:@selector(onChangeToRedTheme)
            forControlEvents:UIControlEventTouchUpInside];
    [self.stackView addArrangedSubview:_changeRedBtn];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(64.f, 64.f));
    }];
}

- (void)zgui_onThemeDidChange {
    
}

- (void)onChangeToLightTheme {
    [ZGUITM setCurrentThemeIdentifier:@"light"];
}

- (void)onChangeToDarkTheme {
    [ZGUITM setCurrentThemeIdentifier:@"dark"];
}

- (void)onChangeToRedTheme {
    [ZGUITM setCurrentThemeIdentifier:@"red"];
}

@end
