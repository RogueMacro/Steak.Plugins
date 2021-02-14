using System;

namespace Steak.Plugins.Internal
{
	public interface IPlugin
	{
		Windows.HModule GetNativeModuleHandle() => 0;

		void OnLoad();
		void OnUnload();
	}
}
