package martian.m4gic.graphics.core 
{
	import flash.geom.Point;
	
	public class Spline
	{
		public var points:Array;
		private var _points:Vector.<Number>;
		
		public function Spline(...data)
		{
			points = new Array();
			if (data.length > 0) { for each(var el:Point in data) { points.push(el); } }
		}
		
		private function opened_cubic(x:Vector.<Number>, n:int):Vector.<Cubic>
		{
			var i:int,	gamma:Vector.<Number> = new Vector.<Number>(n + 1),
						delta:Vector.<Number> = new Vector.<Number>(n + 1),
						D:Vector.<Number> = new Vector.<Number>(n + 1);
			
			gamma[0] = 1.0 / 2.0;
			for (i = 1; i < n; i++) { gamma[i] = 1 / (4 - gamma[i - 1]); }
			gamma[n] = 1 / (2 - gamma[n - 1]);
			
			delta[0] = 3 * (x[1] - x[0]) * gamma[0];
			for (i = 1; i < n; i++) { delta[i] = (3 * (x[i + 1] - x[i - 1]) - delta[i - 1]) * gamma[i]; }
			delta[n] = (3 * (x[n] - x[n - 1]) - delta[n - 1]) * gamma[n];
			
			D[n] = delta[n];
			
			for (i = n - 1; i >= 0; i--) { D[i] = delta[i] - gamma[i] * D[i + 1]; }
			
			var C:Vector.<Cubic> = new Vector.<Cubic>(n);
			
			for (i = 0; i < n; i++) 
			{
				C[i] = new Cubic();
					C[i].a = x[i];
					C[i].b = D[i];
					C[i].c = 3 * (x[i + 1] - x[i]) - 2 * D[i] - D[i + 1];
					C[i].d = 2 * (x[i] - x[i + 1]) + D[i] + D[i + 1];
			}
			
			return C;
		}
		
		private function closed_cubic(x:Vector.<Number>, n:int):Vector.<Cubic>
		{
			var k:int,	w:Vector.<Number> = new Vector.<Number>(n + 1),
						v:Vector.<Number> = new Vector.<Number>(n + 1),
						y:Vector.<Number> = new Vector.<Number>(n + 1),
						D:Vector.<Number> = new Vector.<Number>(n + 1),
						z:Number, F:Number, G:Number, H:Number;
			
			w[1] = v[1] = z = 1 / 4;
			y[0] = z * 3 * (x[1] - x[n]);
			H = 4;
			F = 3 * (x[0] - x[n - 1]);
			G = 1;
			
			for (k = 1; k < n; k++) 
			{
				v[k + 1] = z = 1 / (4 - v[k]);
				w[k + 1] = -z * w[k];
				y[k] = z * (3 * (x[k + 1] - x[k - 1]) - y[k - 1]);
				H = H - G * w[k];
				F = F - G * y[k - 1];
				G = -v[k] * G;
			}
			
			H = H - (G + 1) * (v[n] + w[n]);
			y[n] = F - (G + 1) * y[n - 1];
			D[n] = y[n] / H;
			
			D[n - 1] = y[n - 1] - (v[n] + w[n]) * D[n];
			for (k = n - 2; k >= 0; k--) { D[k] = y[k] - v[k + 1] * D[k + 1] - w[k + 1] * D[n]; }
			
			var C:Vector.<Cubic> = new Vector.<Cubic>(n + 1);
			for ( k = 0; k < n; k++) 
			{
				C[k] = new Cubic();
					C[k].a = x[k];
					C[k].b = D[k];
					C[k].c = 3 * (x[k + 1] - x[k]) - 2 * D[k] - D[k + 1];
					C[k].d = 2 * (x[k] - x[k + 1]) + D[k] + D[k + 1];
			}
			
			C[n] = new Cubic();
				C[n].a = x[n];
				C[n].b = D[n];
				C[n].c = 3 * (x[0] - x[n]) - 2 * D[n] - D[0];
				C[n].d = 2 * (x[n] - x[0]) + D[n] + D[0];
				
			return C;
		}
		
		public function compute(steps:int = 4, closed:Boolean = true):Vector.<Number>
		{
			if (points.length < 2) { return null; }
			
			var i:int = 0, j:Number = 0;
			
			var xpoints:Vector.<Number> = new Vector.<Number>(),
				ypoints:Vector.<Number> = new Vector.<Number>();
			
			for (i = 0; i < points.length; i++)
			{
				xpoints.push(points[i].x);
				ypoints.push(points[i].y);
			}
			
			var X:Vector.<Cubic>, Y:Vector.<Cubic>;
			
			if (closed)
			{
				X = closed_cubic(xpoints, points.length - 1);
				Y = closed_cubic(ypoints, points.length - 1);
			}
			else
			{
				X = opened_cubic(xpoints, points.length - 1);
				Y = opened_cubic(ypoints, points.length - 1);
			}
			
			var p:Vector.<Number> = new Vector.<Number>();
				p.push(X[0].eval(0), Y[0].eval(0));
			
			for ( i = 0; i < X.length; i++) 
			{
				for ( j = 1; j <= steps; j++) 
				{
					var u:Number = j / steps;
					p.push(Math.round(X[i].eval(u)), Math.round(Y[i].eval(u)));
				}
			}
			
			return p;
		}
	}
}

internal class Cubic 
{
	public var a:Number, b:Number, c:Number, d:Number;
	public function Cubic(a:Number = NaN, b:Number = NaN, c:Number = NaN, d:Number = NaN) { this.a = a; this.b = b; this.c = c;	this.d = d; }
	  
	public function eval(u:Number):Number { return (((d * u) + c) * u + b) * u + a; }
}