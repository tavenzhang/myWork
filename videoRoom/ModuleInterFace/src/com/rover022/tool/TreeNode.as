package com.rover022.tool
{
	import flash.utils.Dictionary;

	/** 
	 * @Content 
	 * @Author Ever 
	 * @E-mail: ever@kingjoy.co 
	 * @Version 1.0.0 
	 * @Date：2015-4-22 下午1:28:11
	 */
	
	public class TreeNode
	{
		private var childTreeDic:Dictionary;
		private var _isLeaf:Boolean;
		
		/**
		 *是否是敏感词的词尾字，敏感词树的叶子节点必然是词尾字，父节点不一定是
		 */
		public var isEnd:Boolean = false;
		
		public var parent:TreeNode;
		
		public var value:String;
		
		
		public function TreeNode()
		{
			childTreeDic = new Dictionary();
		}
		/**获取单个节点*/
		public function getChild(name:String):TreeNode
		{
			return childTreeDic[name];
		}
		/**添加关键字符*/
		public function addChild(char:String):TreeNode
		{
			var node:TreeNode = new TreeNode();
			childTreeDic[char] = node;
			node.value = char;
			node.parent = this;
			return node;
		}
		/**获得整体字符串*/
		public function getFullWord():String
		{
			var rt:String = this.value;
			var node:TreeNode = this.parent;
			while(node)
			{
				rt = node.value+rt;
				node = node.parent;
			}
			return rt;
		}
		
		/**是否是叶子节点    下面判断有点问题*/
//		public function get isLeaf():Boolean
//		{
//			var index:int = 0;
//			for(var key:String in dataDic)
//			{
//				index++;
//			}
//			_isLeaf = index == 0;
//			return _isLeaf;
//		}
	}
}