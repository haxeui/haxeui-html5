<p align="center">
  <img src="https://dl.dropboxusercontent.com/u/26678671/haxeui2-warning.png"/>
</p>

<h2>haxeui-html5</h2>
`haxeui-html5` is the pure HTML5 backend for HaxeUI. It has no other framework dependency except `haxeui-core` itself and outputs a DOM tree.

<h2>Installation</h2>
 * `haxeui-html5` has a dependency to <a href="https://github.com/haxeui/haxeui-core">`haxeui-core`</a>, and so that too must be installed.

Eventually all these libs will become haxelibs, however, currently in their alpha form they do not even contain a `haxelib.json` file (for dependencies, etc) and therefore can only be used by downloading the source and using the `haxelib dev` command or by directly using the git versions using the `haxelib git` command (recommended). Eg:

```
haxelib git haxeui-core https://github.com/haxeui/haxeui-core
haxelib dev haxeui-html5 path/to/expanded/source/archive
```

<h2>Usage</h2>
The simplest method to create a new HTML5 application that is HaxeUI ready is simply to use one of the <a href="https://github.com/haxeui/haxeui-templates">haxeui-templates</a>. These templates will allow you to start a new project rapidly with HaxeUI support baked in. 

If however you already have an existing application, then incorporating HaxeUI into that application is straight forward:

<h3>Haxe build.hxml</h3>
If you are using a command line build (via a `.hxml` file) then simply add these two lines:

```
-lib haxeui-core
-lib haxeui-html5
```

If you are using an IDE (like Flash Develop simply add these lines via the project settings window)

_Note: Currently you must also include `haxeui-core` explicitly during the alpha, eventually `haxelib.json` files will exist to take care of this dependency automatically._ 

<h3>Toolkit initialisation and usage</h3>
Initialising the toolkit is very simple, simply add this line somewhere _before_ you start to actually use HaxeUI in your application:

```
Toolkit.init();
```
Once the toolkit is initialised you can add components using the methods specified <a href="https://github.com/haxeui/haxeui-core#adding-components-using-haxe-code">here</a>.

<h2>HTML5 specifics</h2>
