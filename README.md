# Steak.Plugins

Simple, easy-to-use plugin library.

Currently, only one plugin is allowed per DLL.

## Example

Examples can be found in [ExampleApp](ExampleApp/) and [ExamplePlugin](ExamplePlugin/)

> <b>Tip:</b> Have this post-build command in your main project to copy your plugin DLL to your app's target directory: `copy "$(TargetDir MyPlugin)/MyPlugin.dll" "$(TargetDir)/MyPlugin.dll"`

## Usage

### <b>Creating a plugin</b>

---

```cs
[Plugin]
public class ExamplePlugin : Plugin<ExamplePlugin>
{
    public override void OnLoad()
    {
        Debug.WriteLine("[ExamplePlugin] OnLoad()");
    }

    public override void OnUnload()
    {
        Debug.WriteLine("[ExamplePlugin] OnUnload()");
    }
}
```

#### Explanation:

---

The `[Plugin]` attribute says to always include the plugin in the DLL. It will be the same as adding a `[AlwaysInclude]` attribute.

> <b>Note:</b> `OnLoad()` and `OnUnload()` are called at the same time as static constructors and destructors. That means `Console.Write*()` will not work in `OnLoad()`. However, the `Debug` class offers the same methods and written output will can be seen in the IDE Output window.

### <b>Loading a plugin</b>

---

```cs
Result<IPlugin, PluginLoadError> result = Plugins.Load("ExamplePlugin.dll");
if (result case .Ok)
{
    Console.WriteLine("Plugin Loaded");
}
else if (result case .Err(let err))
{
    Console.WriteLine("Failed to load plugin: {}", err);
}
```

### <b>Errors</b>

---

```cs
enum PluginLoadError
{
    InvalidGeneric, // The generic specified in Plugins.Load<TPlugin>() is not implemented by the plugin

    PluginClassNotFound, // The plugin is missing a [Plugin] or [AlwaysInclude] attribute, since it is not found in the DLL

    InvalidModuleHandle, // Something went wrong natively loading the library

    NoPluginInstance, // The plugin failed to instantiate itself (Something went very wrong)

    InvalidPath // The file specified is either not a DLL or doesn't exist
}
```

### <b>Extending the `Plugin<T>` class</b>

Extending the `Plugin<T>` class allows you to create a plugin template or interface specific to your application. That way you can add additional methods required by your plugins. This also hides the `Steak.Plugins` API from plugin creators, removing the need to add it as a dependency.

> <b>Note:</b> Both the interface and abstract class is required for this to work. Further down is another example on how to implement this, but it involves exposing the `Steak.Plugins` API.

Here's an example:

```cs
// Program.bf

public interface IProgramPlugin
{
    public void Update();
}

public abstract class ProgramPlugin<T> : Plugin<T>, IProgramPlugin where T : ProgramPlugin<T>
{
    public abstract void Update();
}

// ExamplePlugin.bf

[Plugin]
public class ExamplePlugin : ProgramPlugin<ExamplePlugin> // No reference to Steak.Plugins needed
{
    public override void OnLoad()
    {
        Debug.WriteLine("[ExamplePlugin] OnLoad()");
    }

    public override void OnUnload()
    {
        Debug.WriteLine("[ExamplePlugin] OnUnload()");
    }

    public override void Update()
    {
        Debug.WriteLine("[ExamplePlugin] Update()");
    }
}
```

Another way to implement this is to simply define an interface that the plugins have to derive from.

> <b>Note:</b> This requires the plugins to inherit `Steak.Plugins.Plugin<T>`, instead of your own implementation.

```cs
// Program.bf

public interface IProgramPlugin
{
    public void Update();
}

// ExamplePlugin.bf

[Plugin]
public class ExamplePlugin : Plugin<ExamplePlugin>, IProgramPlugin // Has to inherit Steak.Plugins.Plugin<T>
{
    public override void OnLoad()
    {
        Debug.WriteLine("[ExamplePlugin] OnLoad()");
    }

    public override void OnUnload()
    {
        Debug.WriteLine("[ExamplePlugin] OnUnload()");
    }

    public void Update() // Required by interface so no override keyword needed
    {
        Debug.WriteLine("[ExamplePlugin] Update()");
    }
}
```
