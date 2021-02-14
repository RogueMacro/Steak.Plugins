using System;
using Steak.Plugins;

namespace ExampleApp
{
	public abstract class ProgramPlugin<T> : Plugin<T>, IProgramPlugin where T : ProgramPlugin<T>
	{
		public abstract void Update();
	}

	public interface IProgramPlugin
	{
		public void Update();
	}

	class Program
	{
		public static int Main(String[] args)
		{
			Result<IProgramPlugin, PluginLoadError> result = Plugins.Load<IProgramPlugin>("ExamplePlugin.dll");
			if (result case .Ok(let plugin))
			{
				Console.WriteLine("Loaded plugin: ExamplePlugin");
				plugin.Update();
			}
			else if (result case .Err(let err))
			{
				Console.WriteLine("Failed to load plugin: {}", err);
			}

			Console.Read();
			return 0;
		}
	}
}