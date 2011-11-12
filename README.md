## UIKit classes ##

Just filling the gaps. Simple. Useful. Experimental.

1. **SKHelpViewer**: An easy way to add contextual help to your views. Supply a title, and an HTML based help string, along with the view controller in which you want to show the help. It presents itself as partially covering the parent view, and dimming the background. You can customize the fonts, the background color, and the height upto which the parent view is covered.
2. **SKLabeledTextField**: Instead of using a table for showing text fields with labels, I decided to make a standalone version, a subclass of UITextField. Can customize the label's font, backgroundColor, text color, and width.
3. **SKSegmentedControl**: A more minimal segmented control that also works in vertical mode. It decides the orientation based on the `CGRect` you provide for its frame. With a sliding selection indicator, and customizable colors, fonts, and separators (bullets, bars; only in horizontal orientation).