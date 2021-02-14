using System;
using System.Collections;
using System.IO;
using Steak.Plugins.Internal;

namespace Steak.Plugins
{
	public static class Plugins
	{
		private static List<IPlugin> mPlugins;
		public static Span<IPlugin> Plugins => mPlugins;

		public static Result<IPlugin, PluginLoadError> Load(StringView path) => Load<IPlugin>(path);

		public static Result<TPlugin, PluginLoadError> Load<TPlugin>(StringView path)
		{
			if (!File.Exists(path) || !path.EndsWith(".dll", .CurrentCultureIgnoreCase))
				return .Err(.InvalidPath);

			Windows.HModule module = Windows.LoadLibraryA(path.Ptr);
			if (module.IsInvalid)
				return .Err(.InvalidModuleHandle);

			String pluginName = scope .();
			Path.GetFileNameWithoutExtension(path, pluginName);

			function IPlugin() getPluginProc = (.) Windows.GetProcAddress(module, scope $"Steak.Plugins.Get");
			if (getPluginProc == 0)
				return .Err(.PluginClassNotFound);

			IPlugin plugin = getPluginProc();

			if (plugin == null)
				return .Err(.NoPluginInstance);

			if (!(plugin is TPlugin))
				return .Err(.InvalidGeneric);

			return .Ok((.) plugin);
		}

		public static void Unload<TPlugin>() where TPlugin : IPlugin
		{
			if (Get<TPlugin>() case .Ok(let plugin))
				Windows.FreeLibrary(plugin.GetNativeModuleHandle());
		}

		public static void Unload(IPlugin plugin)
		{
			Windows.FreeLibrary(plugin.GetNativeModuleHandle());
			mPlugins.Remove(plugin);
		}

		public static void Unload(StringView name)
		{
			Windows.HModule module = Windows.GetModuleHandleA(name.Ptr);

			IPlugin pluginToRemove = null;
			for (IPlugin plugin in Plugins)
			{
				if (plugin.GetNativeModuleHandle() == module)
				{
					pluginToRemove = plugin;
					break;
				}
			}

			mPlugins.Remove(pluginToRemove);

			if (!module.IsInvalid)
				Windows.FreeLibrary(module);
		}

		public static Result<IPlugin> Get<TPlugin>() where TPlugin : IPlugin
		{
			for (IPlugin plugin in Plugins)
			{
				if (plugin is TPlugin)
					return .Ok(plugin);
			}

			return .Err;
		}

		public static Result<IPlugin> Get(StringView name)
		{
			Windows.HModule module = Windows.GetModuleHandleA(name.Ptr);
			if (!module.IsInvalid)
			{
				for (IPlugin plugin in Plugins)
				{
					if (plugin.GetNativeModuleHandle() == module)
						return .Ok(plugin);
				}
			}

			return .Err;
		}
	}
}
