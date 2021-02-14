using System;
using System.Collections;
using System.IO;
using Steak.Plugins.Internal;

namespace Steak.Plugins
{
	public abstract class Plugin<T> : IPlugin where T : Plugin<T>, new, class
	{
		[Export, LinkName("Steak.Plugins.Get")]
		private static IPlugin Get() { return mInstance; };

		private static IPlugin mInstance = null ~ if (_ != null) delete _;

		private Windows.HModule mNativeModuleHandle;

		public static this()
		{
			mInstance = new T();
			mInstance.OnLoad();
		}

		public static ~this()
		{
			if (mInstance != null)
				mInstance.OnUnload();
		}

		public Windows.HModule GetNativeModuleHandle() => mNativeModuleHandle;

		public abstract void OnLoad();
		public abstract void OnUnload();
	}
}
