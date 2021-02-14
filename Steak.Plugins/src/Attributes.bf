using System;

namespace Steak.Plugins
{
	[AttributeUsage(.Class, AlwaysIncludeUser=.AssumeInstantiated)]
	public struct PluginAttribute : Attribute
	{

	}
}
