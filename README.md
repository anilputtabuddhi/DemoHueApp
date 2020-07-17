# DemoHueApp - Hue Lights Controller

Requires: XCode 12.0 beta or later. iOS 14 beta or later

This is a quick hack built to understand how to construct a reasonable sized app that can be further scaled using the Composable architecture. The architecture focuses on modularity, Functional reactive programming using Apple's Combine, Reducers for state and action pullback.  More details in
[Swift Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)

Some of the features

1) Automatically discovers Hue bridges and authorises on user selection
2) Ability to toggle on/off individual lights or a group as a whole. The actions are synchronised across Group and Lights tabs
3) Focus on modularity and Single responsibility.
4) Reuse Views and modules (Core, View pair) wherever applicable.

I think this is a great way to build highly scalable apps. I had so much hacking together this app and hope you find this useful. The Composable architecture naturally lends itself easily to slice up "Application state" into as small a chunk as one wants and then pulling it back through the reducer. I have now become a big fan and will continue to use it in all my projects.

Note:
  If you do not have a Hue Bridge or any Hue lights and just want to see the app working, there are mocks you can use. In file RootCore.swift replace LiveDiscoverHueApi()" with "MockDiscoverHueApi(), and replace "HueAPI(authorisedHueBridge: authorisedHueBridge)" with "MockHueAPI()". This should allow you to use the app with its full functionality. 

