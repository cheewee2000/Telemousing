<h3>Pointer</h3>
=======================
conceived:	Che-Wei Wang, 2009
built by:	Che-Wei Wang & Jonathan Bobrow, 2014

<h4>What is it?</h4>
Pointer is an app for connecting you to another through the most basic of digital presence. Wherever your mouse is on your screen, you are broadcasting it for another or many others to see where you are headed. The app does not share any information other than your mouse position, normalized for relevance to screens of all sizes. Subscribe to as many pointers as you'd like to keep you company.

Pointer will always stay on top of your windows but not take focus away from the precious work you are doing. This is accomplished by floating a very tiny (mouse sized) window across your screen and maintaining a higher z priority on your monitor. A nice application for creating transparent webviews allows the window to simply appear as a cursor and any other interface elements needed.

Pointer. Why pointer? Well, yes pointer is a term for the cursor or mouse icon that navigates your screen, but pointer also refers to a reference that it is pointing to. In this case, the pointer is a reference of anothers pointer, and so it was coined--"pointer", case in point. 

<h4>How is it built?</h4>
The application utilizes the following open source code and closed source tools to accomplish our goals.

Objective C - To make a native OS X app which can track mouse position continuously.

<a href="https://github.com/irlabs/TransparentWebView">Transparent Web Browser</a> - The TransparentWebView is a transparent web browser for Mac OS X. That means that if the visited web page is without a background color, or the background color is set to transparent, the complete browser window will be see-through. (Built w/ Objective C)

<a href="http://pubnub.com">PubNub</a> - a simple tool for publishing realtime data and subscribing to that data seamlessl