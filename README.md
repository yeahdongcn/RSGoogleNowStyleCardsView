Google-Now-Style-Card-View
==========================
Google Search for Android has been updated to take advantage of various new Google Now cards, including one for live TV. 

This project clones the card inserting animation, card exchange animation and provide UITableView alike APIs for data sourcing and delegating.

Add 'Card View' to your project and use RSCardsView.

    RSCardsView *view = [[[RSCardsView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    view.delegate = self;
    view.dataSource = self;
    view.animationStyle = RSCardsViewAnimationStyleExchange; // or RSCardsViewAnimationStyleDrop
    self.view = view;

You should implement your own card and card view, open sample to see lot more.
