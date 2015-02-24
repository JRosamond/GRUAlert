# GRUAlert
A custom swift alert view with many IBInspectable properties and three built-in animations

<h2>HOW TO USE</h2>
<p>
There are two ways you can use the GRUAlert. The easiest way is to simply drag the GRUAlert folder into your own xcode project.
Then, in your storyboard drag a UIView into your view controller and assign GRUAlertView as its class in IB's identity inspector.  
To customize your alert view, go to IB's attributes inspector.  At the time of this writing, there are 18 properties that can be set
via IB.  To select which animation is used to present/dismiss the alert, call the show(animationKey) function on your 
instance of GRUAlertView.  The available animationKeys can be found in the AnimationKeys enum in GRUAlertView.swift.
Run the included example project to see what they look like.</p>
<p>
Since GRUAlert was build as a framework, the second way you could use it in your own project is to add GRUAlert.framework to
your project.  However, I have been unable to get this method to work properly.  If any of you get this to work and would like to share, please email
me the steps you used and I'll add them here.</p>

<h2>LICENSE</h2>
<p>
Copyright (c) 2015, Georgia Regents University<br/>
<br/>
Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.<br/><br/>

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
</p>


