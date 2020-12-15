#  iBike

Nothing special to run, just one scheme. To test location auth can just say no to the alert iOS displays.

Most of the interesting work is done in the ContainerViewController. I use a Swift enum to model the state, of which there are quite a few - displaying content, authorizing, getting location, hitting the API, and error. When the state variable changes, a configure method is called to update the relevant views.

Like every iOS developer who lives in/around NYC, I have some existing CitiBike API code that I wrote in the past, and I modifed that here. The APIController is a singleton which hits the CitiBike API and decodes into model instances. I then calculate the distance between each station and the user's location, and sort. A note on performance here - after decoding, I'm looping through all of the stations to calculate their distance from the user, and then sorting. An interesting optimization opportunity could be to calculate the distance at parse time, taking the runtime pre-sort from O(2n) -> O(n).

Once there's Bike Share data, the Container VC adds a child VC which is a subclass of UITableViewController. Tapping each cell shows the Detail View, which is also a Table VC subclass, statically configured in the Storyboard. In a production app, I'd spend a bit more time to get these table VCs working with dynamic type, etc.

