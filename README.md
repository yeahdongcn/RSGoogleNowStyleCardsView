Google-Now-Style-Card-View
==========================

![ScreenShot](https://s3.amazonaws.com/cocoacontrols_production/uploads/control_image/image/1784/iOS_Simulator_Screen_shot_Sep_5__2013_3.44.58_PM.png)

Google Search for Android has been updated to take advantage of various new Google Now cards, including one for live TV. 

This project clones the card inserting animation, card exchange animation and provides UITableView alike APIs for data sourcing and delegating.

Add 'Card View' (Dir) to your project and start to use RSCardsView.

    RSCardsView *view = [[[RSCardsView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    view.delegate = self;
    view.dataSource = self;
    view.animationStyle = RSCardsViewAnimationStyleExchange; // or RSCardsViewAnimationStyleDrop
    self.view = view;

You should implement your own card and card view, open sample to see lot more.

[![ScreenShot](https://raw.github.com/GabLeRoux/WebMole/master/ressources/WebMole_Youtube_Video.png)](http://v.youku.com/v_show/id_XNTc4MDUyODY0.html)


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/yeahdongcn/google-now-style-card-view/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

