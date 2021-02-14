using System;
using System.Diagnostics;
using Steak.Plugins;
using ExampleApp;

namespace ExamplePlugin
{
	[Plugin]
	public class ExamplePlugin : Plugin<ExamplePlugin>, IProgramPlugin
	{
		public override void OnLoad()
		{
			Debug.WriteLine("[ExamplePlugin] OnLoad()");
		}

		public override void OnUnload()
		{
			Debug.WriteLine("[ExamplePlugin] OnUnload()");
		}

		public void Update()
		{
			Debug.WriteLine("[ExamplePlugin] Update()");
			Console.WriteLine("Updating ExamplePlugin");
		}
	}
}
