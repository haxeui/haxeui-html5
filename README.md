<p align="center">
  <img src="https://dl.dropboxusercontent.com/u/26678671/haxeui2-warning.png"/>
</p>

[![Build Status](https://travis-ci.org/haxeui/haxeui-html5.svg?branch=master)](https://travis-ci.org/haxeui/haxeui-html5)
[![Code Climate](https://codeclimate.com/github/haxeui/haxeui-html5/badges/gpa.svg)](https://codeclimate.com/github/haxeui/haxeui-html5)
[![Issue Count](https://codeclimate.com/github/haxeui/haxeui-html5/badges/issue_count.svg)](https://codeclimate.com/github/haxeui/haxeui-html5)
[![Support this project on Patreon](https://dl.dropboxusercontent.com/u/26678671/patreon_button.png)](https://www.patreon.com/haxeui)

<h2>haxeui-html5</h2>
`haxeui-html5` is the pure HTML5 backend for HaxeUI. It has no other framework dependency except `haxeui-core` itself and outputs a DOM tree.

<p align="center">
	<img src="https://github.com/haxeui/haxeui-html5/raw/master/screen-hybrid.png" />
</p>
<p align="center">
	<img src="https://github.com/haxeui/haxeui-html5/raw/master/screen.png" />
</p>

<h2>Installation</h2>
 * `haxeui-html5` has a dependency to <a href="https://github.com/haxeui/haxeui-core">`haxeui-core`</a>, and so that too must be installed.

Eventually all these libs will become haxelibs, however, currently in their alpha form they do not even contain a `haxelib.json` file (for dependencies, etc) and therefore can only be used by downloading the source and using the `haxelib dev` command or by directly using the git versions using the `haxelib git` command (recommended). Eg:

```
haxelib git haxeui-core https://github.com/haxeui/haxeui-core
haxelib dev haxeui-html5 path/to/expanded/source/archive
```

<h2>Usage</h2>
The simplest method to create a new HTML5 application that is HaxeUI ready is to use one of the <a href="https://github.com/haxeui/haxeui-templates">haxeui-templates</a>. These templates will allow you to start a new project rapidly with HaxeUI support baked in. 

If however you already have an existing application, then incorporating HaxeUI into that application is straightforward:

<h3>Haxe build.hxml</h3>
If you are using a command line build (via a `.hxml` file) then add these two lines:

```
-lib haxeui-core
-lib haxeui-html5
```

If you are using an IDE, like Flash Develop, add these lines via the project settings window.

_Note: Currently you must also include `haxeui-core` explicitly during the alpha, eventually `haxelib.json` files will exist to take care of this dependency automatically._ 

<h3>Toolkit initialisation and usage</h3>
Initialising the toolkit requires you to add this single line somewhere _before_ you start to actually use HaxeUI in your application:

```
Toolkit.init();
```
Once the toolkit is initialised you can add components using the methods specified <a href="https://github.com/haxeui/haxeui-core#adding-components-using-haxe-code">here</a>.

<h2>HTML5 specifics</h2>

As well as using the generic `Screen.instance.addComponent`, it is also possible to add components directly to any other DOM node: the `haxeui-html5` backend exposes a special `element` property for this purpose. Eg:

```haxe
js.Browser.document.getElementById("myContainer").appendChild(main.element);
```

<h3>Initialisation options</h3>
The configuration options that may be passed to `Tookit.init()` are as follows:

```haxe
Toolkit.init({
    container: js.Browser.document.getElementById("myContainer") // where 'Screen' will place components
                                                                 // defaults to the document body
});
```

<h3>Native components</h3>
HTML5 supports various native versions of components, and therefore so does HaxeUI. There are a few different ways to do this:

<h4>Using a theme (applies to all relevant components)</h4>
```haxe
Toolkit.theme = "native"; // will try to use native components where possible
```

<h4>Using haxe code (applies to single component)</h4>
```haxe
var button:Button = new Button();
button.native = true; // this component alone will be native
```

<h4>Using an inline style (applies to single component)</h4>
```xml
<button text="Native" style="native:true;" />
```
<h4>Using CSS (applies to groups of components)</h4>
```css
.button, #myNativeButton, .myNativeStyle {
	native: true;
}

```

<h2>Addtional resources</h2>
* <a href="http://haxeui.github.io/haxeui-api/">haxeui-api</a> - The HaxeUI api docs.
* <a href="https://github.com/haxeui/haxeui-guides">haxeui-guides</a> - Set of guides to working with HaxeUI and backends.
* <a href="https://github.com/haxeui/haxeui-demo">haxeui-demo</a> - Demo application written using HaxeUI.
* <a href="https://github.com/haxeui/haxeui-templates">haxeui-templates</a> - Set of templates for IDE's to allow quick project creation.
* <a href="https://github.com/haxeui/haxeui-bdd">haxeui-bdd</a> - A behaviour driven development engine written specifically for HaxeUI (uses <a href="https://github.com/haxeui/haxe-bdd">haxe-bdd</a> which is a gherkin/cucumber inspired project).
* <a href="https://www.youtube.com/watch?v=L8J8qrR2VSg&feature=youtu.be">WWX2016 presentation</a> - A presentation given at WWX2016 regarding HaxeUI.

