package net.area80.uikit.component
{
	import flash.events.EventDispatcher;
	import flash.text.StageText;
	
	[Event(name="change",                 type="flash.events.Event")]
	[Event(name="focusIn",                type="flash.events.FocusEvent")]
	[Event(name="focusOut",               type="flash.events.FocusEvent")]
	
	public class UIStageTextResponder extends EventDispatcher
	{
		public var stageText:StageText;
		
		public function UIStageTextResponder(stageText:StageText)
		{
			this.stageText = stageText;
			super(this);
		}
	}
}