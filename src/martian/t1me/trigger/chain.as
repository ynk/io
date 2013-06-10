package martian.t1me.trigger 
{
	import martian.t1me.interfaces.Stackable;
	import martian.t1me.meta.Sequence;
	
	public function chain(...functions):Stackable 
	{
		var sequence:Sequence = new Sequence();
			for each(var method:Function in functions) { sequence.stack.push(new Call(method)); }
			sequence.stack.push(new Call(sequence.dispose));
			
		return sequence;
	}
}